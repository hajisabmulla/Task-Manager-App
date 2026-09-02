import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  late final Dio dio;
  final SecureStorageService _storageService;

  // Stream to notify app when refresh fails and user needs to log in
  final StreamController<void> _authFailureController =
      StreamController<void>.broadcast();
  Stream<void> get onAuthFailure => _authFailureController.stream;

  bool _isRefreshing = false;
  final List<Completer<String?>> _refreshCompleters = [];

  ApiClient({SecureStorageService? storageService})
    : _storageService = storageService ?? SecureStorageService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Authorization header if access token exists
          final token = await _storageService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException err, handler) async {
          final statusCode = err.response?.statusCode;
          final requestPath = err.requestOptions.path;

          // Check if 401 and not already an auth endpoint (login/signup/refresh)
          final isAuthEndpoint =
              requestPath.contains('/auth/login') ||
              requestPath.contains('/auth/signup') ||
              requestPath.contains('/auth/refresh');

          if (statusCode == 401 && !isAuthEndpoint) {
            try {
              final newAccessToken = await _refreshToken();
              if (newAccessToken != null) {
                // Retry the original failed request with the new access token
                final options = err.requestOptions;
                options.headers['Authorization'] = 'Bearer $newAccessToken';

                final retryResponse = await dio.fetch(options);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Token refresh failed completely: clear session and broadcast
              await _storageService.clearAll();
              _authFailureController.add(null);
            }
          }

          return handler.next(err);
        },
      ),
    );
  }

  Future<String?> _refreshToken() async {
    if (_isRefreshing) {
      // Queue up pending refresh requests
      final completer = Completer<String?>();
      _refreshCompleters.add(completer);
      return completer.future;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw UnauthorizedException();
      }

      // Use a separate clean Dio instance to avoid infinite loop interceptor
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await _storageService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        if (data['user'] != null) {
          await _storageService.saveUserData(
            data['user'] as Map<String, dynamic>,
          );
        }

        // Resolve queued requests
        for (final c in _refreshCompleters) {
          c.complete(newAccessToken);
        }
        _refreshCompleters.clear();

        return newAccessToken;
      } else {
        throw UnauthorizedException();
      }
    } catch (e) {
      for (final c in _refreshCompleters) {
        c.completeError(e);
      }
      _refreshCompleters.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  // Handle and transform Dio errors into typed ApiExceptions
  ApiException parseError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return NetworkException();
      }

      final response = error.response;
      if (response != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final message =
            data['message'] as String? ?? 'An unexpected error occurred';
        final code = data['code'] as String?;
        final errors = data['errors'] as Map<String, dynamic>?;

        if (response.statusCode == 401) {
          return UnauthorizedException(message: message);
        }
        if (response.statusCode == 422) {
          return ValidationException(message: message, errors: errors);
        }

        return ApiException(
          message: message,
          statusCode: response.statusCode,
          code: code,
          errors: errors,
        );
      }

      return ApiException(
        message: error.message ?? 'Unknown server error',
        statusCode: response?.statusCode,
      );
    }

    if (error is ApiException) return error;

    return ApiException(message: error.toString());
  }

  void dispose() {
    _authFailureController.close();
  }
}

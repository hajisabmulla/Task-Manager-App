import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository({ApiClient? apiClient, SecureStorageService? storageService})
    : _apiClient = apiClient ?? ApiClient(),
      _storageService = storageService ?? SecureStorageService();

  ApiClient get apiClient => _apiClient;

  Future<AuthResponseModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.signup,
        data: {'name': name, 'email': email, 'password': password},
      );

      final authData = AuthResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.saveUserData(authData.user.toJson());

      return authData;
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final authData = AuthResponseModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );

      await _storageService.saveTokens(
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );
      await _storageService.saveUserData(authData.user.toJson());

      return authData;
    } catch (e) {
      throw _apiClient.parseError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post(
          ApiEndpoints.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Proceed with local logout regardless of server errors
    } finally {
      await _storageService.clearAll();
    }
  }

  Future<UserModel?> getCachedUser() async {
    final userData = await _storageService.getUserData();
    final token = await _storageService.getAccessToken();
    if (userData != null && token != null) {
      return UserModel.fromJson(userData);
    }
    return null;
  }
}

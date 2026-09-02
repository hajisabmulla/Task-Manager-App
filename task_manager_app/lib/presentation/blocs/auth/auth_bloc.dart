import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<void>? _authFailureSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignupRequested>(_onAuthSignupRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);

    // Listen to token refresh failures from ApiClient
    _authFailureSubscription = _authRepository.apiClient.onAuthFailure.listen((
      _,
    ) {
      add(const AuthSessionExpired());
    });
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCachedUser();
      if (user != null) {
        emit(Authenticated(user: user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: result.user));
    } on ValidationException catch (e) {
      emit(AuthFailure(message: e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(AuthFailure(message: e.message, errors: e.errors));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onAuthSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await _authRepository.signup(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user: result.user));
    } on ValidationException catch (e) {
      emit(AuthFailure(message: e.message, errors: e.errors));
    } on ApiException catch (e) {
      emit(AuthFailure(message: e.message, errors: e.errors));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  void _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) {
    emit(
      const Unauthenticated(
        message: 'Your session has expired. Please log in again.',
      ),
    );
  }

  @override
  Future<void> close() {
    _authFailureSubscription?.cancel();
    return super.close();
  }
}

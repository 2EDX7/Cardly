import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/api/api_exception.dart';
import 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final UserRepository _repository;

  AuthCubit({required UserRepository repository})
      : _repository = repository,
        super(AuthState.unauthenticated()) {
    checkAuthStatus();
  }

  /// Check if user is already authenticated (token exists)
  Future<void> checkAuthStatus() async {
    // If state is already authenticated (from hydration), verified.
    // But we should verify with backend if token is valid.
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        // Token invalid or expired
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthState.loading());
    try {
      // Backend handles duplicate check and password hashing
      final user = User.create(
        fullName: fullName,
        email: email,
        passwordHash: password, // Send plain password - backend will hash it
      );
      final created = await _repository.createUser(user);
      emit(AuthState.authenticated(created));
    } on ValidationException catch (e) {
      emit(AuthState.error(e.message));
    } on NetworkException catch (e) {
      emit(AuthState.error(e.message));
    } on ServerException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Failed to sign up: $e'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthState.loading());
    try {
      // Send plain password - backend will verify
      final user = await _repository.verifyCredentials(
        email: email,
        passwordHash: password, // Backend verifies plain password
      );
      
      if (user == null) {
        emit(AuthState.error('Invalid email or password'));
        emit(AuthState.unauthenticated());
        return;
      }
      
      emit(AuthState.authenticated(user));
    } on UnauthorizedException catch (e) {
      emit(AuthState.error(e.message));
      emit(AuthState.unauthenticated());
    } on NetworkException catch (e) {
      emit(AuthState.error(e.message));
    } on ServerException catch (e) {
      emit(AuthState.error(e.message));
    } catch (e) {
      emit(AuthState.error('Failed to login: $e'));
      emit(AuthState.unauthenticated());
    }
  }

  Future<void> logout() async {
    // Clear token from storage (handled by repository)
    // If using ApiUserRepository, call logout method
    try {
      // Type check to call logout if it's ApiUserRepository
      if (_repository is dynamic && 
          _repository.runtimeType.toString().contains('ApiUserRepository')) {
        await (_repository as dynamic).logout();
      }
    } catch (e) {
      // Ignore logout errors
    }
    emit(AuthState.unauthenticated());
  }

  /// Reset to guest/unauthenticated state
  void resetToGuest() {
    emit(AuthState.unauthenticated());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      return AuthState.fromMap(json);
    } catch (_) {
      return AuthState.unauthenticated();
    }
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toMap();
  }
}

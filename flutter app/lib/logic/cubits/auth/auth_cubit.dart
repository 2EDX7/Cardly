import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/sqlite_user_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  final UserRepository _repository;

  AuthCubit({UserRepository? repository})
      : _repository = repository ?? SQLiteUserRepository(),
        super(AuthState.unauthenticated());

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    emit(AuthState.loading());
    try {
      final existingUser = await _repository.getUserByEmail(email);
      if (existingUser != null) {
        emit(AuthState.error('User already exists with this email'));
        return;
      }

      final passwordHash = _hashPassword(password);
      final user = User.create(fullName: fullName, email: email, passwordHash: passwordHash);
      final created = await _repository.createUser(user);
      emit(AuthState.authenticated(created));
    } catch (e) {
      emit(AuthState.error('Failed to sign up: $e'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(AuthState.loading());
    try {
      final passwordHash = _hashPassword(password);
      final user = await _repository.verifyCredentials(email: email, passwordHash: passwordHash);
      if (user == null) {
        emit(AuthState.error('Invalid email or password'));
        emit(AuthState.unauthenticated());
        return;
      }
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error('Failed to login: $e'));
    }
  }

  void logout() {
    emit(AuthState.unauthenticated());
  }

  /// Reset to guest/unauthenticated state
  void resetToGuest() {
    emit(AuthState.unauthenticated());
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
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

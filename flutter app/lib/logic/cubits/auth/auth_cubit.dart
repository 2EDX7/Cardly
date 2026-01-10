import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/models/user.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/api_user_repository.dart';
import '../../../data/api/api_exception.dart';
import '../../../data/services/notification_service.dart';
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

      // Register FCM token after successful login
      _registerFCMToken();
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

  /// Register FCM token with backend
  Future<void> _registerFCMToken() async {
    try {
      print('🔔 Attempting to register FCM token...');

      // Check if repository supports FCM token registration
      if (_repository is! ApiUserRepository) {
        print('⚠️ Repository does not support FCM token registration');
        return;
      }

      final apiRepo = _repository as ApiUserRepository;

      await NotificationService().registerToken((token) async {
        print('📱 Got FCM token: $token');
        await apiRepo.registerFCMToken(token);
        print('✅ FCM token registered successfully');
      });
    } catch (e) {
      // Don't fail login if token registration fails
      print('⚠️ Failed to register FCM token: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Remove FCM token before logout
      if (_repository is ApiUserRepository) {
        print('🔔 Removing FCM token...');
        final apiRepo = _repository as ApiUserRepository;
        await NotificationService().registerToken((token) async {
          await apiRepo.removeFCMToken(token);
          print('✅ FCM token removed');
        });
      }
    } catch (e) {
      print('⚠️ Failed to remove FCM token: $e');
    }

    emit(AuthState.unauthenticated());
  }

  /// Update notification preference
  Future<void> updateNotificationPreference(bool receiveNotifications) async {
    final currentState = state;
    if (currentState.status != AuthStatus.authenticated ||
        currentState.user == null) return;

    try {
      // Update locally first
      final updatedUser = currentState.user!.copyWith(
        receiveNotifications: receiveNotifications,
      );
      emit(AuthState.authenticated(updatedUser));

      // Update in local database
      await _repository.updatePreferences(
        receiveNotifications: receiveNotifications,
      );

      // Update in backend if using API repository
      if (_repository is ApiUserRepository) {
        final apiRepo = _repository as ApiUserRepository;
        await apiRepo.updatePreferences(
          receiveNotifications: receiveNotifications,
        );
        print('✅ Notification preference updated in backend');
      }

      print('✅ Notification preference updated: $receiveNotifications');
    } catch (e) {
      print('⚠️ Failed to update notification preference: $e');
      // Revert on error
      emit(currentState);
    }
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

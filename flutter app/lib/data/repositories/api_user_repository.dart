import '../models/user.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../services/token_storage_service.dart';
import 'user_repository.dart';

/// API implementation of UserRepository
/// Matches backend UserRepository pattern
class ApiUserRepository implements UserRepository {
  final ApiClient apiClient;
  final TokenStorageService tokenStorage;

  ApiUserRepository({
    required this.apiClient,
    required this.tokenStorage,
  });

  @override
  Future<User?> getUserByEmail(String email) async {
    // Not needed for API - backend uses JWT for user identity
    // This is only used in SQLite implementation
    throw UnimplementedError(
      'getUserByEmail is not supported in API implementation. Use getCurrentUser instead.',
    );
  }

  @override
  Future<User> createUser(User user) async {
    // Register user on backend
    final response = await apiClient.post(
      Endpoints.register,
      body: {
        'fullName': user.fullName,
        'email': user.email,
        'password': user.passwordHash, // Backend will hash with bcrypt
      },
    );

    // Extract data from response
    final userData = response['data']['user'];
    final token = response['data']['token'];

    // Save token and user ID
    await tokenStorage.saveToken(token);
    await tokenStorage.saveUserId(userData['_id']);

    // Set token in API client
    apiClient.setToken(token);

    // Return user from response
    return User.fromJson(userData);
  }

  @override
  Future<User?> verifyCredentials({
    required String email,
    required String passwordHash,
  }) async {
    // Login user on backend
    final response = await apiClient.post(
      Endpoints.login,
      body: {
        'email': email,
        'password': passwordHash, // Send plain password, backend verifies
      },
    );

    // Extract data from response
    final userData = response['data']['user'];
    final token = response['data']['token'];

    // Save token and user ID
    await tokenStorage.saveToken(token);
    await tokenStorage.saveUserId(userData['_id']);

    // Set token in API client
    apiClient.setToken(token);

    // Return user from response
    return User.fromJson(userData);
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await apiClient.get(Endpoints.me);
      final userData = response['data']['user'];
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Update user preferences
  Future<User> updatePreferences({
    String? themeMode,
    String? language,
    bool? receiveNotifications,
  }) async {
    final response = await apiClient.patch(
      Endpoints.preferences,
      body: {
        if (themeMode != null) 'themeMode': themeMode,
        if (language != null) 'language': language,
        if (receiveNotifications != null)
          'receiveNotifications': receiveNotifications,
      },
    );

    final userData = response['data']['user'];
    return User.fromJson(userData);
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      Endpoints.changePassword,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  /// Logout - clear token
  Future<void> logout() async {
    await tokenStorage.clearAll();
    apiClient.clearToken();
  }

  /// Register FCM token with backend
  Future<void> registerFCMToken(String token) async {
    try {
      await apiClient.post(
        '/notifications/register-token',
        body: {'token': token},
      );
    } catch (e) {
      print('⚠️ Failed to register FCM token with backend: $e');
      rethrow;
    }
  }

  /// Remove FCM token from backend (on logout)
  Future<void> removeFCMToken(String token) async {
    try {
      await apiClient.post(
        '/notifications/remove-token',
        body: {'token': token},
      );
    } catch (e) {
      print('⚠️ Failed to remove FCM token from backend: $e');
    }
  }
}

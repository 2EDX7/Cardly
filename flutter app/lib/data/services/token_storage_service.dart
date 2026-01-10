import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing JWT tokens
class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  
  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get stored token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete stored token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Delete user ID
  Future<void> deleteUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUserId();
  }
}

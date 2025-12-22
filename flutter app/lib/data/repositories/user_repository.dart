import '../models/user.dart';

/// Abstraction for user persistence and lookup.
abstract class UserRepository {
  Future<User?> getUserByEmail(String email);
  Future<User> createUser(User user);
  Future<User?> verifyCredentials({required String email, required String passwordHash});
  Future<User> updatePreferences({String? themeMode, String? language});
  Future<User?> getCurrentUser();
}

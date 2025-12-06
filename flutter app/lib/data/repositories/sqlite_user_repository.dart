import '../database/database_helper.dart';
import '../models/user.dart';
import 'user_repository.dart';

class SQLiteUserRepository implements UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Future<User?> getUserByEmail(String email) {
    return _dbHelper.getUserByEmail(email);
  }

  @override
  Future<User> createUser(User user) async {
    await _dbHelper.insertUser(user);
    // Return freshly loaded user to ensure DB values are used.
    return (await _dbHelper.getUserByEmail(user.email)) ?? user;
  }

  @override
  Future<User?> verifyCredentials({required String email, required String passwordHash}) {
    return _dbHelper.getUserByCredentials(email: email, passwordHash: passwordHash);
  }
}

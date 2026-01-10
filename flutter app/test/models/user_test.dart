import 'package:flutter_test/flutter_test.dart';
import 'package:cardly/data/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User creation with required fields', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.fullName, 'Test User');
    });

    test('User copyWith updates fields correctly', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        receiveNotifications: true,
      );

      final updatedUser = user.copyWith(
        fullName: 'Updated User',
        receiveNotifications: false,
      );

      expect(updatedUser.fullName, 'Updated User');
      expect(updatedUser.receiveNotifications, false);
      expect(updatedUser.id, '123'); // unchanged
      expect(updatedUser.email, 'test@example.com'); // unchanged
    });

    test('User with default notification preference', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        fullName: 'Test User',
        passwordHash: 'hashed_password',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(user.receiveNotifications, true); // default should be true
    });
  });
}

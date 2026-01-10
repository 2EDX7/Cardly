library;

/// API endpoint definitions
/// Centralizes all backend API endpoints

class Endpoints {
  // Base paths
  static const String auth = '/auth';
  static const String users = '/users';
  static const String profileCard = '/profile-card';
  static const String cards = '/cards';

  // Authentication endpoints
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String me = '$auth/me';
  static const String changePassword = '$auth/change-password';

  // User endpoints
  static const String preferences = '$users/preferences';

  // Profile card endpoints
  static String shareCard(String shareableId) =>
      '$profileCard/share/$shareableId';

  // Card endpoints
  static const String cardStats = '$cards/stats';
  static String card(String cardId) => '$cards/$cardId';
  static String collectCard(String shareableId) =>
      '$cards/collect/$shareableId';
}

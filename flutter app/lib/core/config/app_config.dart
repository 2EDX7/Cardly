/// Application configuration
class AppConfig {
  /// API base URL - can be overridden via environment variable
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue:
        'http://10.229.150.61:3000/api', // Physical device - use PC IP
    // Use 'http://10.229.150.61:3000/api' for Android emulator
    // Use 'http://localhost:3000/api' for iOS simulator
  );

  /// HTTP request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Maximum retry attempts for failed requests
  static const int maxRetries = 3;

  /// Debug mode
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);
}

/// Application configuration
class AppConfig {
  /// API base URL - can be overridden via environment variable
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api', // Android emulator localhost
    // Use 'http://localhost:3000/api' for iOS simulator
    // Use actual IP for physical devices
  );

  /// HTTP request timeout
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Maximum retry attempts for failed requests
  static const int maxRetries = 3;

  /// Debug mode
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);
}

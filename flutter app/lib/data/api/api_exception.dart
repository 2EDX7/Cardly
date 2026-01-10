library;

/// Custom exception classes for API errors
/// Provides typed exceptions for better error handling

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, [this.statusCode, this.data]);

  @override
  String toString() => message;
}

/// Thrown when authentication fails (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized. Please login again.'])
      : super(message, 401);
}

/// Thrown when resource is not found (404)
class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, 404);
}

/// Thrown when validation fails (400, 422)
class ValidationException extends ApiException {
  ValidationException(String message, [dynamic data])
      : super(message, 400, data);
}

/// Thrown when network request fails
class NetworkException extends ApiException {
  NetworkException([String message = 'Network error. Please check your connection.'])
      : super(message);
}

/// Thrown when server returns 500+ status
class ServerException extends ApiException {
  ServerException([String message = 'Server error. Please try again later.'])
      : super(message, 500);
}

/// Thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException([String message = 'Request timed out. Please try again.'])
      : super(message);
}

/// Thrown for other HTTP errors
class HttpException extends ApiException {
  HttpException(String message, int statusCode) : super(message, statusCode);
}

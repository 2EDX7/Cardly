library;

import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

/// HTTP client wrapper with authentication and error handling
class ApiClient {
  final String baseUrl;
  final http.Client client;
  final Duration timeout;
  
  String? _authToken;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 30),
  }) : client = client ?? http.Client();

  /// Set authentication token
  void setToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token (logout)
  void clearToken() {
    _authToken = null;
  }

  /// Check if client has a token
  bool get hasToken => _authToken != null;

  /// Build headers with authentication if available
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Parse and handle HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    // Try to parse response body
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (e) {
      // Response is not JSON
      data = {'message': response.body};
    }

    // Handle different status codes
    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    // Extract error message
    final message = data is Map
        ? (data['message'] ?? 'An error occurred')
        : 'An error occurred';

    // Throw appropriate exception
    switch (statusCode) {
      case 400:
      case 422:
        throw ValidationException(message, data);
      case 401:
        _authToken = null; // Clear token on unauthorized
        throw UnauthorizedException(message);
      case 404:
        throw NotFoundException(message);
      case 500:
      case 502:
      case 503:
        throw ServerException(message);
      default:
        throw HttpException(message, statusCode);
    }
  }

  /// Handle network/timeout errors
  ApiException _handleError(dynamic error) {
    if (error is SocketException) {
      return NetworkException('No internet connection');
    }
    if (error is async.TimeoutException) {
      return TimeoutException();
    }
    if (error is ApiException) {
      return error;
    }
    return ApiException('An unexpected error occurred: $error');
  }

  /// GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl$endpoint');
      
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      final response = await client
          .get(uri, headers: _buildHeaders(additionalHeaders: headers))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client
          .post(
            uri,
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client
          .put(
            uri,
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client
          .patch(
            uri,
            headers: _buildHeaders(additionalHeaders: headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client
          .delete(uri, headers: _buildHeaders(additionalHeaders: headers))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Dispose client
  void dispose() {
    client.close();
  }
}

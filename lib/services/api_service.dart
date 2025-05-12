import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.0.200:8080/';
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Add auth token to headers when user is logged in
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }
  
  // Remove auth token when user logs out
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  // GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParams,
      );
      
      final response = await http.get(uri, headers: _defaultHeaders);
      return _processResponse(response);
    } catch (e) {
      debugPrint('GET request error: $e');
      rethrow;
    }
  }

  // POST request
  Future<dynamic> post(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      debugPrint('POST request error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<dynamic> put(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      debugPrint('PUT request error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<dynamic> delete(String endpoint, {dynamic body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(
        uri,
        headers: _defaultHeaders,
        body: body != null ? jsonEncode(body) : null,
      );
      return _processResponse(response);
    } catch (e) {
      debugPrint('DELETE request error: $e');
      rethrow;
    }
  }

  // Process the response and handle errors
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Success
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      }
      return null;
    } else {
      // Error
      throw ApiException(
        code: response.statusCode,
        message: response.body.isNotEmpty ? response.body : 'Unknown error occurred',
      );
    }
  }
}

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException: [$code] $message';
} 
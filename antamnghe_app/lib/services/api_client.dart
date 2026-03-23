import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, String>> _defaultHeaders() async {
    final token = await _storage.read(key: 'jwt');
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> post(String path, Map body) async {
    final headers = await _defaultHeaders();
    return http.post(_uri(path), body: jsonEncode(body), headers: headers);
  }

  Future<http.Response> get(String path) async {
    final headers = await _defaultHeaders();
    return http.get(_uri(path), headers: headers);
  }

  Future<http.Response> put(String path, Map body) async {
    final headers = await _defaultHeaders();
    return http.put(_uri(path), body: jsonEncode(body), headers: headers);
  }

  Future<http.Response> delete(String path) async {
    final headers = await _defaultHeaders();
    return http.delete(_uri(path), headers: headers);
  }

  // Add convenience methods here (auth, spam, calllog, dashboard)
}

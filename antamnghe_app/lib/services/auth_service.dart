import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'config.dart';

class AuthService {
  AuthService._private() : _api = ApiClient(baseUrl: ServiceConfig.baseUrl);

  static final AuthService instance = AuthService._private();

  final ApiClient _api;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Register a new user. Expects map with keys 'phone', 'password', 'name', 'email'.
  /// Returns decoded user map on success, throws Exception on error.
  Future<Map<String, dynamic>> register(
    String phone,
    String password, {
    String? name,
    String? email,
  }) async {
    final body = {
      'phone': phone,
      'password': password,
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
    };
    final resp = await _api.post('/api/auth/register', body);

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }

    throw Exception('Register failed: ${resp.statusCode} ${resp.body}');
  }

  /// Login with phone + password. Returns user map on success.
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final body = {'phone': phone, 'password': password};
    final resp = await _api.post('/api/auth/login', body);

    // DEBUG: log response for troubleshooting
    print('[LOGIN] status: ${resp.statusCode}');
    print('[LOGIN] body: ${resp.body}');

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      // expected response: { token: '...', user: { id, phone } }
      final token = map['token'] as String?;
      final user = map['user'] as Map<String, dynamic>?;
      if (token != null) await _saveTokenLocal(token);
      if (user != null) await _saveUserLocal(user);
      return user ?? <String, dynamic>{};
    }

    if (resp.statusCode == 401) {
      throw Exception('Unauthorized');
    }

    throw Exception('Login failed: ${resp.statusCode} ${resp.body}');
  }

  // Persist user map locally
  Future<void> _saveUserLocal(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user));
  }

  Future<void> _saveTokenLocal(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  Future<Map<String, dynamic>?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('user');
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final resp = await _api.get('/api/auth/me');

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      await _saveUserLocal(map);
      return map;
    }

    if (resp.statusCode == 401) {
      await logout();
      throw Exception('Unauthorized');
    }

    throw Exception('Fetch profile failed: ${resp.statusCode} ${resp.body}');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final body = {'name': name, 'email': email, 'phone': phone};
    final resp = await _api.put('/api/auth/me', body);

    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      await _saveUserLocal(map);
      return map;
    }

    if (resp.statusCode == 401) {
      await logout();
      throw Exception('Unauthorized');
    }

    if (resp.statusCode == 409) {
      throw Exception('Conflict');
    }

    throw Exception('Update profile failed: ${resp.statusCode} ${resp.body}');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await _storage.delete(key: 'jwt');
  }
}

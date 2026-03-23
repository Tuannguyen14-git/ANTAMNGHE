import 'dart:convert';
import 'api_client.dart';
import 'config.dart';

class DashboardService {
  DashboardService._private()
    : _api = ApiClient(baseUrl: ServiceConfig.baseUrl);

  static final DashboardService instance = DashboardService._private();

  final ApiClient _api;

  Future<Map<String, dynamic>> getStats() async {
    final resp = await _api.get('/api/dashboard');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Get dashboard stats failed: ${resp.statusCode}');
  }
}

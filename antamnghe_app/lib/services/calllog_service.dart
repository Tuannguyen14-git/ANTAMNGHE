import 'dart:convert';
import 'api_client.dart';
import 'config.dart';

class CallLogService {
  CallLogService._private() : _api = ApiClient(baseUrl: ServiceConfig.baseUrl);

  static final CallLogService instance = CallLogService._private();

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> getAll() async {
    final resp = await _api.get('/api/calllog');
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load call logs: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> add(Map<String, dynamic> log) async {
    final resp = await _api.post('/api/calllog', log);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Add call log failed: ${resp.statusCode} ${resp.body}');
  }
}

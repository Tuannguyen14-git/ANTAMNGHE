import 'dart:convert';
import 'api_client.dart';
import 'config.dart';

class SpamService {
  SpamService._private() : _api = ApiClient(baseUrl: ServiceConfig.baseUrl);

  static final SpamService instance = SpamService._private();

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> getAll() async {
    final resp = await _api.get('/api/spam');
    if (resp.statusCode == 200) {
      final List list = jsonDecode(resp.body) as List;
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load spam list: ${resp.statusCode}');
  }

  Future<bool> check(String phone) async {
    final resp = await _api.get('/api/spam/check/$phone');
    if (resp.statusCode == 200) {
      final map = jsonDecode(resp.body) as Map<String, dynamic>;
      return map['isSpam'] == true;
    }
    throw Exception('Check spam failed: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> add(Map<String, dynamic> model) async {
    final resp = await _api.post('/api/spam', model);
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Add spam failed: ${resp.statusCode} ${resp.body}');
  }

  Future<Map<String, dynamic>> update(
    int id,
    Map<String, dynamic> model,
  ) async {
    final resp = await _api.put('/api/spam/$id', model);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Update spam failed: ${resp.statusCode}');
  }

  Future<void> delete(int id) async {
    final resp = await _api.delete('/api/spam/$id');
    if (resp.statusCode == 200) return;
    throw Exception('Delete spam failed: ${resp.statusCode}');
  }

  Future<Map<String, dynamic>> getById(int id) async {
    final resp = await _api.get('/api/spam/$id');
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Get spam by id failed: ${resp.statusCode}');
  }
}

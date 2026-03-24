import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:antamnghe_app/services/call_detection.dart';

class ReportStore {
  static const String _key = 'community_reports';

  /// Increment report count for a number.
  static Future<void> addReport(String number) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _getMap(prefs);
    final norm = CallDetection.normalizeNumber(number);
    map[norm] = (map[norm] ?? 0) + 1;
    await prefs.setString(_key, jsonEncode(map));
  }

  /// Get report count for a number.
  static Future<int> getReportCount(String number) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _getMap(prefs);
    final norm = CallDetection.normalizeNumber(number);
    return map[norm] ?? 0;
  }

  static Map<String, int> _getMap(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }
    return {};
  }
}

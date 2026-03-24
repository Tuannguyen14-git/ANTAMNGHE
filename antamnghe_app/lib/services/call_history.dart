import 'dart:convert';
import 'dart:core';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:antamnghe_app/services/call_detection.dart';

class CallHistoryStore {
  static const String _key = 'call_history_events';

  /// Append a call event to local history (simple SharedPreferences backing).
  static Future<void> addEvent(CallEvent e) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(
      jsonEncode({
        'number': e.number,
        'timestamp': e.timestamp.toIso8601String(),
        'duration': e.durationSeconds,
      }),
    );
    await prefs.setStringList(_key, list);
  }

  /// Retrieve history for `number`. If `window` is provided, only return events within it.
  static Future<List<CallEvent>> getHistoryForNumber(
    String number, {
    Duration? window,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final now = DateTime.now().toUtc();
    final normalized = CallDetection.normalizeNumber(number);
    final out = <CallEvent>[];
    for (final s in list) {
      try {
        final m = jsonDecode(s) as Map<String, dynamic>;
        final num = m['number'] as String;
        final ts = DateTime.parse(m['timestamp']).toUtc();
        // Robust duration parsing for int, double, String, or null
        final rawDur = m['duration'];
        int? dur;
        if (rawDur is int) {
          dur = rawDur;
        } else if (rawDur is double) {
          dur = rawDur.toInt();
        } else if (rawDur is String) {
          dur = int.tryParse(rawDur);
        } else {
          dur = null;
        }
        if (CallDetection.normalizeNumber(num) != normalized) continue;
        if (window != null && now.difference(ts) > window) continue;
        out.add(CallEvent(num, ts, durationSeconds: dur));
      } catch (_) {
        continue;
      }
    }
    out.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return out;
  }
}

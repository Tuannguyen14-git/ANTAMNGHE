import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'call_screening_channel.dart';

class FocusModeSnapshot {
  final bool isEnabled;
  final DateTime? until;

  const FocusModeSnapshot({required this.isEnabled, required this.until});

  Duration? get remaining {
    if (!isEnabled || until == null) return null;
    final diff = until!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }
}

class FocusModeService {
  static const String _focusUntilKey = 'focus_mode_until_ms';
  static const String _emergencyKeywordsKey = 'emergency_keywords';

  static bool get _supportsNativeAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<FocusModeSnapshot> currentState() async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_focusUntilKey);
    if (untilMs == null) {
      return const FocusModeSnapshot(isEnabled: false, until: null);
    }

    final until = DateTime.fromMillisecondsSinceEpoch(untilMs);
    if (until.isBefore(DateTime.now())) {
      await prefs.remove(_focusUntilKey);
      if (_supportsNativeAndroid) {
        await CallScreeningChannel.clearFocusMode();
      }
      return const FocusModeSnapshot(isEnabled: false, until: null);
    }

    return FocusModeSnapshot(isEnabled: true, until: until);
  }

  static Future<FocusModeSnapshot> enableFor(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(duration);
    await prefs.setInt(_focusUntilKey, until.millisecondsSinceEpoch);
    if (_supportsNativeAndroid) {
      await CallScreeningChannel.setFocusMode(duration.inMinutes);
    }
    return FocusModeSnapshot(isEnabled: true, until: until);
  }

  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_focusUntilKey);
    if (_supportsNativeAndroid) {
      await CallScreeningChannel.clearFocusMode();
    }
  }

  static List<String> normalizeKeywords(Iterable<String> keywords) {
    final result = <String>[];
    for (final keyword in keywords) {
      final normalized = keyword.trim().toLowerCase();
      if (normalized.isEmpty || result.contains(normalized)) continue;
      result.add(normalized);
    }
    return result;
  }

  static Future<List<String>> getEmergencyKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_emergencyKeywordsKey) ?? <String>[];
    return normalizeKeywords(stored);
  }

  static Future<void> saveEmergencyKeywords(List<String> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = normalizeKeywords(keywords);
    await prefs.setStringList(_emergencyKeywordsKey, normalized);
    if (_supportsNativeAndroid) {
      await CallScreeningChannel.setEmergencyKeywords(normalized);
    }
  }

  static String describe(FocusModeSnapshot snapshot) {
    if (!snapshot.isEnabled || snapshot.until == null) {
      return 'Đang tắt';
    }

    final remaining = snapshot.remaining ?? Duration.zero;
    final totalMinutes = remaining.inMinutes;
    if (totalMinutes <= 0) {
      return 'Sắp kết thúc';
    }
    if (totalMinutes < 60) {
      return 'Đang bật, còn $totalMinutes phút';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (minutes == 0) {
      return 'Đang bật, còn $hours giờ';
    }
    return 'Đang bật, còn $hours giờ $minutes phút';
  }
}

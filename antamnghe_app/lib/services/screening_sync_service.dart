import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

import 'call_detection.dart';
import 'call_screening_channel.dart';

class ScreeningSyncService {
  static const String _communitySpamKey = 'community_spam_numbers';
  static const String _blockedSpamKey = 'blocked_spam_numbers';
  static const String _vipKey = 'vip_numbers';

  static bool get _supportsNativeAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static List<String> _normalizeNumbers(Iterable<String> numbers) {
    final result = <String>[];
    for (final number in numbers) {
      final trimmed = number.trim();
      if (trimmed.isEmpty) continue;
      final normalized = CallDetection.normalizeNumber(trimmed);
      if (!result.contains(normalized)) {
        result.add(normalized);
      }
    }
    return result;
  }

  static Future<void> setCommunitySpamNumbers(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_communitySpamKey, _normalizeNumbers(numbers));
    await syncToNative();
  }

  static Future<void> setBlockedNumbers(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_blockedSpamKey, _normalizeNumbers(numbers));
    await syncToNative();
  }

  static Future<void> setVipNumbers(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_vipKey, _normalizeNumbers(numbers));
    await syncToNative();
  }

  static Future<List<String>> getEffectiveSpamNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final merged = <String>{
      ...(prefs.getStringList(_communitySpamKey) ?? <String>[]),
      ...(prefs.getStringList(_blockedSpamKey) ?? <String>[]),
    };
    return merged.toList()..sort();
  }

  static Future<List<String>> getVipNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    final vip = prefs.getStringList(_vipKey) ?? <String>[];
    return vip.toList()..sort();
  }

  static Future<bool> syncToNative() async {
    if (!_supportsNativeAndroid) return false;
    final spam = await getEffectiveSpamNumbers();
    final vip = await getVipNumbers();
    final spamOk = await CallScreeningChannel.setSpamList(spam);
    final vipOk = await CallScreeningChannel.setVipList(vip);
    return spamOk && vipOk;
  }
}

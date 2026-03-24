import 'package:flutter/services.dart';

class CallScreeningChannel {
  static const MethodChannel _channel = MethodChannel(
    'com.example.antamnghe_app/call_screening',
  );

  /// Send spam number list to native CallScreeningService prototype
  static Future<bool> setSpamList(List<String> numbers) async {
    try {
      final res = await _channel.invokeMethod('setSpamList', {
        'numbers': numbers,
      });
      return res == true;
    } catch (_) {
      return false;
    }
  }

  /// Send VIP number list to native CallScreeningService prototype
  static Future<bool> setVipList(List<String> numbers) async {
    try {
      final res = await _channel.invokeMethod('setVipList', {
        'numbers': numbers,
      });
      return res == true;
    } catch (_) {
      return false;
    }
  }

  /// Open app settings (Android) to let user enable Call Screening / permissions
  static Future<bool> openAppSettings() async {
    try {
      final res = await _channel.invokeMethod('openAppSettings');
      return res == true;
    } catch (_) {
      return false;
    }
  }
}

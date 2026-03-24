import 'package:flutter/services.dart';

class FocusWidgetStatus {
  final bool isPinned;
  final bool canRequestPin;
  final String message;

  const FocusWidgetStatus({
    required this.isPinned,
    required this.canRequestPin,
    required this.message,
  });

  factory FocusWidgetStatus.fromMap(Map<Object?, Object?> map) {
    return FocusWidgetStatus(
      isPinned: map['isPinned'] == true,
      canRequestPin: map['canRequestPin'] == true,
      message: (map['message'] ?? '').toString(),
    );
  }
}

class ScreeningSetupStatus {
  final bool callScreeningSupported;
  final bool callScreeningEnabled;
  final bool smsPermissionsGranted;
  final bool notificationsGranted;
  final String supportMessage;

  const ScreeningSetupStatus({
    required this.callScreeningSupported,
    required this.callScreeningEnabled,
    required this.smsPermissionsGranted,
    required this.notificationsGranted,
    required this.supportMessage,
  });

  bool get isReady =>
      callScreeningSupported &&
      callScreeningEnabled &&
      smsPermissionsGranted &&
      notificationsGranted;

  bool get isLimitedMode => !callScreeningSupported;

  factory ScreeningSetupStatus.fromMap(Map<Object?, Object?> map) {
    return ScreeningSetupStatus(
      callScreeningSupported: map['callScreeningSupported'] == true,
      callScreeningEnabled: map['callScreeningEnabled'] == true,
      smsPermissionsGranted: map['smsPermissionsGranted'] == true,
      notificationsGranted: map['notificationsGranted'] == true,
      supportMessage: (map['supportMessage'] ?? '').toString(),
    );
  }
}

class CallScreeningChannel {
  static const MethodChannel _channel = MethodChannel(
    'com.example.antamnghe_app/call_screening',
  );

  static Future<ScreeningSetupStatus?> getSetupStatus() async {
    try {
      final res = await _channel.invokeMapMethod<Object?, Object?>(
        'getSetupStatus',
      );
      if (res == null) return null;
      return ScreeningSetupStatus.fromMap(res);
    } catch (_) {
      return null;
    }
  }

  static Future<FocusWidgetStatus?> getFocusWidgetStatus() async {
    try {
      final res = await _channel.invokeMapMethod<Object?, Object?>(
        'getFocusWidgetStatus',
      );
      if (res == null) return null;
      return FocusWidgetStatus.fromMap(res);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> requestPinFocusWidget() async {
    try {
      final res = await _channel.invokeMethod('requestPinFocusWidget');
      return res == true;
    } catch (_) {
      return false;
    }
  }

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

  static Future<bool> setFocusMode(int durationMinutes) async {
    try {
      final res = await _channel.invokeMethod('setFocusMode', {
        'durationMinutes': durationMinutes,
      });
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clearFocusMode() async {
    try {
      final res = await _channel.invokeMethod('clearFocusMode');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setEmergencyKeywords(List<String> keywords) async {
    try {
      final res = await _channel.invokeMethod('setEmergencyKeywords', {
        'keywords': keywords,
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

  static Future<bool> openDefaultAppsSettings() async {
    try {
      final res = await _channel.invokeMethod('openDefaultAppsSettings');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openLauncherSettings() async {
    try {
      final res = await _channel.invokeMethod('openLauncherSettings');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestCallScreeningRole() async {
    try {
      final res = await _channel.invokeMethod('requestCallScreeningRole');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestSmsPermissions() async {
    try {
      final res = await _channel.invokeMethod('requestSmsPermissions');
      return res == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      final res = await _channel.invokeMethod('requestNotificationPermission');
      return res == true;
    } catch (_) {
      return false;
    }
  }
}

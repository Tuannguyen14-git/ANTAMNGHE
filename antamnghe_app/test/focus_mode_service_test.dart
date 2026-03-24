import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antamnghe_app/services/focus_mode_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.antamnghe_app/call_screening');
  final calls = <MethodCall>[];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    calls.clear();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('enable and disable focus mode syncs with native channel', () async {
    final enabled = await FocusModeService.enableFor(const Duration(minutes: 30));

    expect(enabled.isEnabled, isTrue);
    expect(enabled.until, isNotNull);
    expect(calls.single.method, 'setFocusMode');
    expect(calls.single.arguments, {'durationMinutes': 30});

    final current = await FocusModeService.currentState();
    expect(current.isEnabled, isTrue);

    await FocusModeService.disable();
    expect(calls.last.method, 'clearFocusMode');

    final disabled = await FocusModeService.currentState();
    expect(disabled.isEnabled, isFalse);
  });

  test('emergency keywords are normalized and deduplicated', () async {
    await FocusModeService.saveEmergencyKeywords([
      ' Khan Cap ',
      'khan cap',
      'GOI LAI',
      '',
    ]);

    final keywords = await FocusModeService.getEmergencyKeywords();
    expect(keywords, ['khan cap', 'goi lai']);
    expect(calls.single.method, 'setEmergencyKeywords');
    expect(calls.single.arguments, {
      'keywords': ['khan cap', 'goi lai'],
    });
  });
}

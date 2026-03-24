import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:antamnghe_app/services/screening_sync_service.dart';

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

  test('community spam and blocked numbers are merged before syncing', () async {
    await ScreeningSyncService.setCommunitySpamNumbers([
      '090-123-4567',
      '0901234567',
    ]);
    await ScreeningSyncService.setBlockedNumbers([
      '+84 901 111 222',
      '0901234567',
    ]);
    await ScreeningSyncService.setVipNumbers([
      '0988 888 888',
    ]);

    final spam = await ScreeningSyncService.getEffectiveSpamNumbers();
    final vip = await ScreeningSyncService.getVipNumbers();

    expect(spam, ['+84901111222', '+84901234567']);
    expect(vip, ['+84988888888']);
    expect(calls.last.method, 'setVipList');
    expect(calls.last.arguments, {
      'numbers': ['+84988888888'],
    });

    final spamCalls = calls.where((call) => call.method == 'setSpamList').toList();
    expect(spamCalls.last.arguments, {
      'numbers': ['+84901111222', '+84901234567'],
    });
  });
}

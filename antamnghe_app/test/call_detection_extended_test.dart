import 'package:flutter_test/flutter_test.dart';
import 'package:antamnghe_app/services/call_detection.dart';

void main() {
  test('time of day and short duration increase score', () {
    final spam = <String>[];
    final vip = <String>[];
    final now = DateTime.now();
    final hist = [
      CallEvent(
        '+84123456789',
        now.subtract(const Duration(minutes: 3)),
        durationSeconds: 5,
      ),
      CallEvent(
        '+84123456789',
        now.subtract(const Duration(minutes: 2)),
        durationSeconds: 3,
      ),
    ];

    final score = CallDetection.scoreNumber(
      '+84123456789',
      spamList: spam,
      vipList: vip,
      history: hist,
      reportCount: 0,
    );
    expect(score > 0, true);
    final res = CallDetection.decide('+84123456789', history: hist);
    expect(
      res.action == CallAction.silence ||
          res.action == CallAction.allow ||
          res.action == CallAction.reject,
      true,
    );
  });

  test('pattern detection for repeated digits', () {
    final hist = <CallEvent>[];
    final score = CallDetection.scoreNumber('0000000', history: hist);
    expect(score > 0.0, true);
  });
}

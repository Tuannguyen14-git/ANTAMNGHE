import 'package:flutter_test/flutter_test.dart';
import 'package:antamnghe_app/services/call_detection.dart';

void main() {
  test('normalize number local to E.164 +84', () {
    expect(CallDetection.normalizeNumber('0123456789'), '+84123456789');
    expect(CallDetection.normalizeNumber('84901234567'), '+84901234567');
    expect(CallDetection.normalizeNumber('+84 901 234 567'), '+84901234567');
  });

  test('score and decide for VIP and spam', () {
    final vip = ['+84987654321'];
    final spam = ['+84123456789'];

    // VIP -> score 0
    var res = CallDetection.decide('+84987654321', vipList: vip);
    expect(res.score, 0.0);
    expect(res.action, CallAction.allow);

    // Exact spam -> high score -> reject
    res = CallDetection.decide('+84123456789', spamList: spam, reportCount: 5);
    expect(res.score >= 0.55, true);
    expect(
      res.action == CallAction.reject || res.action == CallAction.silence,
      true,
    );
  });
}

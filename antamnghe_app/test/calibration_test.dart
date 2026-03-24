import 'package:flutter_test/flutter_test.dart';
import 'package:antamnghe_app/tools/calibration.dart';

void main() {
  test('calibration suggests thresholds in reasonable range', () async {
    final res = await Calibration.runCalibration(
      seed: 42,
      spamCount: 80,
      hamCount: 320,
    );
    final s = res['silence']!;
    final r = res['reject']!;
    expect(s >= 0.2 && s <= 0.8, isTrue);
    expect(r > s && r <= 0.99, isTrue);
  });
}

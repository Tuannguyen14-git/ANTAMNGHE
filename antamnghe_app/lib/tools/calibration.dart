import 'dart:math';

import 'package:antamnghe_app/services/call_detection.dart';

/// Simple calibration harness to tune `thresholdSilence` and `thresholdReject`
/// for the `CallDetection.decide` function using synthetic data.
class Calibration {
  /// Generate a reproducible synthetic dataset containing spam and ham numbers.
  /// Each entry is a map: { 'number': String, 'isSpam': bool, 'history': List<CallEvent>, 'reports': int }
  static List<Map<String, Object>> generateDataset({
    int spamCount = 200,
    int hamCount = 800,
    int callsPerNumber = 6,
    int seed = 42,
  }) {
    final rng = Random(seed);
    final List<Map<String, Object>> out = [];

    String randomNumber(bool spam) {
      // spam numbers more likely to be short or repeating digits
      if (spam) {
        if (rng.nextDouble() < 0.3)
          return '+849' + List.generate(6, (_) => rng.nextInt(10)).join();
        if (rng.nextDouble() < 0.2)
          return '+84123' + List.generate(3, (_) => '3').join();
        return '+84' + List.generate(9, (_) => rng.nextInt(10)).join();
      } else {
        return '+84' +
            (9 + rng.nextInt(10)).toString() +
            List.generate(8, (_) => rng.nextInt(10)).join();
      }
    }

    DateTime now = DateTime.now().toUtc();

    // create spam entries
    for (var i = 0; i < spamCount; i++) {
      final num = randomNumber(true);
      final reports = 1 + rng.nextInt(10); // more reports for spam
      final history = <CallEvent>[];
      for (var c = 0; c < callsPerNumber; c++) {
        final ts = now.subtract(Duration(minutes: rng.nextInt(60 * 24)));
        final duration = (rng.nextDouble() < 0.7)
            ? rng.nextInt(8)
            : 20 + rng.nextInt(120);
        history.add(CallEvent(num, ts, durationSeconds: duration));
      }
      out.add({
        'number': num,
        'isSpam': true,
        'history': history,
        'reports': reports,
      });
    }

    // create ham entries
    for (var i = 0; i < hamCount; i++) {
      final num = randomNumber(false);
      final reports = rng.nextInt(2); // rare reports for ham
      final history = <CallEvent>[];
      for (var c = 0; c < callsPerNumber; c++) {
        final ts = now.subtract(
          Duration(days: rng.nextInt(14), minutes: rng.nextInt(60 * 24)),
        );
        final duration = 20 + rng.nextInt(300);
        history.add(CallEvent(num, ts, durationSeconds: duration));
      }
      out.add({
        'number': num,
        'isSpam': false,
        'history': history,
        'reports': reports,
      });
    }

    return out;
  }

  /// Run a grid search over thresholds and return the best pair.
  /// Returns a map: { 'silence': double, 'reject': double, 'score': double }
  static Future<Map<String, double>> runCalibration({
    int seed = 42,
    int spamCount = 200,
    int hamCount = 800,
  }) async {
    final data = generateDataset(
      spamCount: spamCount,
      hamCount: hamCount,
      seed: seed,
    );

    // helper to evaluate a threshold pair
    double evaluate(double tSilence, double tReject) {
      int tp = 0; // spam detected (silence or reject)
      int fp = 0; // ham flagged
      int spamTotal = 0;
      int hamTotal = 0;
      for (final e in data) {
        final num = e['number'] as String;
        final isSpam = e['isSpam'] as bool;
        final history = (e['history'] as List).cast<CallEvent>();
        final reports = e['reports'] as int;
        final res = CallDetection.decide(
          num,
          history: history,
          reportCount: reports,
          thresholdSilence: tSilence,
          thresholdReject: tReject,
        );
        final flagged = res.action != CallAction.allow;
        if (isSpam) {
          spamTotal++;
          if (flagged) tp++;
        } else {
          hamTotal++;
          if (flagged) fp++;
        }
      }
      final tpr = spamTotal == 0 ? 0.0 : tp / spamTotal; // recall for spam
      final fpr = hamTotal == 0 ? 0.0 : fp / hamTotal;
      // scoring: prioritize high TPR while penalizing FPR
      return tpr - 0.6 * fpr;
    }

    double bestScore = double.negativeInfinity;
    double bestSilence = 0.5;
    double bestReject = 0.85;

    for (double s = 0.2; s <= 0.75; s += 0.05) {
      for (double r = (s + 0.05); r <= 0.98; r += 0.05) {
        final sc = evaluate(s, r);
        if (sc > bestScore) {
          bestScore = sc;
          bestSilence = double.parse(s.toStringAsFixed(3));
          bestReject = double.parse(r.toStringAsFixed(3));
        }
      }
    }

    return {'silence': bestSilence, 'reject': bestReject, 'score': bestScore};
  }
}

void main() async {
  final res = await Calibration.runCalibration();
  print(
    'Recommended thresholds -> silence: ${res['silence']}, reject: ${res['reject']}, score: ${res['score']}',
  );
}

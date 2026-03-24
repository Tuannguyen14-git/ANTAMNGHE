// Simple, testable heuristics for call detection.
// This module is platform-agnostic and suitable for unit testing
// before integrating with native CallScreeningService.

import 'dart:math';

class CallEvent {
  final String number; // raw/normalized number expected
  final DateTime timestamp;
  final int? durationSeconds; // optional call duration in seconds

  CallEvent(this.number, this.timestamp, {this.durationSeconds});
}

enum CallAction { allow, silence, reject }

class DetectionResult {
  final double score; // 0.0..1.0, higher == more likely spam
  final CallAction action;

  DetectionResult(this.score, this.action);
}

class CallDetection {
  // Normalize a phone number to a simple E.164-like string.
  // This is a lightweight normalizer for unit testing and heuristics.
  // For production consider using libphonenumber via platform or package.
  static String normalizeNumber(
    String input, {
    String defaultCountryCode = '+84',
  }) {
    var s = input.trim();
    // remove common separators
    s = s.replaceAll(RegExp(r'[ \-().]'), '');
    if (s.startsWith('00')) s = '+' + s.substring(2);
    if (s.startsWith('0') && !s.startsWith('00')) {
      // local national format, replace leading 0 with country code
      s = defaultCountryCode + s.substring(1);
    }
    if (!s.startsWith('+')) s = '+' + s;
    return s;
  }

  // Count occurrences of a number in call history within window
  static int countRecentCalls(
    String number,
    List<CallEvent> history,
    Duration window,
  ) {
    final now = DateTime.now();
    return history
        .where(
          (e) => e.number == number && now.difference(e.timestamp) <= window,
        )
        .length;
  }

  // Basic scoring heuristic combining multiple signals.
  // Inputs:
  // - spamList, vipList: lists of normalized numbers
  // - history: recent call events (normalized numbers)
  // - reportCount: optional count of community reports
  // Returns score in [0,1].
  static double scoreNumber(
    String number, {
    List<String>? spamList,
    List<String>? vipList,
    List<CallEvent>? history,
    int reportCount = 0,
  }) {
    final n = normalizeNumber(number);
    final spam = spamList ?? <String>[];
    final vip = vipList ?? <String>[];
    final hist = history ?? <CallEvent>[];

    if (vip.contains(n)) return 0.0; // VIP -> always allow

    double score = 0.0;

    // Strong signal: exact spam list membership
    if (spam.contains(n)) score += 0.5;

    // Frequency signal: repeated calls in last 30 minutes
    final repeats = countRecentCalls(n, hist, const Duration(minutes: 30));
    score += (min(repeats, 6) / 6) * 0.15; // up to +0.15

    // Community reports
    score += (min(reportCount, 10) / 10) * 0.15; // up to +0.15

    // Pattern heuristics: short numbers, repeated digits, suspicious prefixes
    double patternScore = 0.0;
    final digitsOnly = n.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 8) patternScore += 0.06; // short number
    if (RegExp(r'(\d)\1{4,}').hasMatch(digitsOnly))
      patternScore += 0.08; // repeated digits
    if (digitsOnly.startsWith('190') ||
        digitsOnly.startsWith('180') ||
        digitsOnly.startsWith('123'))
      patternScore += 0.04;
    score += patternScore; // up to ~0.18

    // Time of day heuristic: calls in late-night hours slightly more suspicious
    double timeScore = 0.0;
    if (hist.isNotEmpty) {
      // use last call's hour as proxy
      final last = hist.last.timestamp.toUtc().hour;
      if (last >= 0 && last <= 5)
        timeScore = 0.05;
      else if (last >= 22)
        timeScore = 0.02;
    }
    score += timeScore;

    // Duration heuristic: previous short calls indicate spammy behavior
    final shortCalls = hist
        .where(
          (e) =>
              e.durationSeconds != null &&
              e.durationSeconds! < 10 &&
              e.number == n,
        )
        .length;
    score += (min(shortCalls, 3) / 3) * 0.05; // up to +0.05

    // Clamp
    if (score > 1.0) score = 1.0;
    if (score < 0.0) score = 0.0;
    return score;
  }

  // Decide action based on score and thresholds.
  // thresholdReject: >= reject
  // thresholdSilence: >= silence (and < reject)
  static DetectionResult decide(
    String number, {
    List<String>? spamList,
    List<String>? vipList,
    List<CallEvent>? history,
    int reportCount = 0,
    double thresholdSilence = 0.5,
    double thresholdReject = 0.85,
  }) {
    final s = scoreNumber(
      number,
      spamList: spamList,
      vipList: vipList,
      history: history,
      reportCount: reportCount,
    );
    if (s >= thresholdReject) return DetectionResult(s, CallAction.reject);
    if (s >= thresholdSilence) return DetectionResult(s, CallAction.silence);
    return DetectionResult(s, CallAction.allow);
  }
}

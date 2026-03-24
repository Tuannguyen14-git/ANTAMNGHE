import 'package:shared_preferences/shared_preferences.dart';
import 'call_screening_channel.dart';
import 'package:antamnghe_app/services/call_detection.dart';
import 'package:antamnghe_app/services/call_history.dart';
import 'package:antamnghe_app/services/report_store.dart';

class ScreeningStorage {
  static const String _spamKey = 'screening_spam_list';
  static const String _vipKey = 'screening_vip_list';

  static Future<List<String>> getSpamList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_spamKey) ?? <String>[];
  }

  static Future<List<String>> getVipList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_vipKey) ?? <String>[];
  }

  static Future<void> saveSpamList(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_spamKey, numbers);
  }

  static Future<void> saveVipList(List<String> numbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_vipKey, numbers);
  }

  /// Sync stored lists to native screening service via MethodChannel.
  static Future<bool> syncToNative() async {
    final spam = await getSpamList();
    final vip = await getVipList();
    // Run local detection to filter low-risk spam before syncing to native.
    final filteredSpam = <String>[];
    for (final n in spam) {
      try {
        // Gather history and report count for more accurate scoring
        final hist = await CallHistoryStore.getHistoryForNumber(
          n,
          window: Duration(days: 30),
        );
        final reports = await ReportStore.getReportCount(n);
        final res = CallDetection.decide(
          n,
          spamList: spam,
          vipList: vip,
          history: hist,
          reportCount: reports,
        );
        if (res.action != CallAction.allow) filteredSpam.add(n);
      } catch (_) {
        // on any error, fallback to including the number so we don't lose data
        filteredSpam.add(n);
      }
    }
    final sOk = await CallScreeningChannel.setSpamList(filteredSpam);
    final vOk = await CallScreeningChannel.setVipList(vip);
    return sOk && vOk;
  }

  /// Helper: save lists and sync immediately
  static Future<bool> saveAndSync({
    List<String>? spam,
    List<String>? vip,
  }) async {
    if (spam != null) await saveSpamList(spam);
    if (vip != null) await saveVipList(vip);
    return syncToNative();
  }
}

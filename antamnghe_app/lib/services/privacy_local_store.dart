import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'call_detection.dart';
import 'call_history.dart';
import 'report_store.dart';
import 'screening_sync_service.dart';

class LocalVipEntry {
  final String id;
  final String phoneNumber;
  final String? name;

  const LocalVipEntry({
    required this.id,
    required this.phoneNumber,
    this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'name': name,
      };

  factory LocalVipEntry.fromJson(Map<String, dynamic> json) => LocalVipEntry(
        id: (json['id'] ?? '').toString(),
        phoneNumber: (json['phoneNumber'] ?? '').toString(),
        name: json['name']?.toString(),
      );
}

class LocalBlockedEntry {
  final String id;
  final String phoneNumber;
  final String? note;

  const LocalBlockedEntry({
    required this.id,
    required this.phoneNumber,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'note': note,
      };

  factory LocalBlockedEntry.fromJson(Map<String, dynamic> json) => LocalBlockedEntry(
        id: (json['id'] ?? '').toString(),
        phoneNumber: (json['phoneNumber'] ?? '').toString(),
        note: json['note']?.toString(),
      );
}

class LocalEmergencyContact {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? note;
  final DateTime createdAt;

  const LocalEmergencyContact({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'name': name,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalEmergencyContact.fromJson(Map<String, dynamic> json) => LocalEmergencyContact(
        id: (json['id'] ?? '').toString(),
        phoneNumber: (json['phoneNumber'] ?? '').toString(),
        name: json['name']?.toString(),
        note: json['note']?.toString(),
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      );
}

class LocalCallHistoryEntry {
  final String id;
  final String phoneNumber;
  final String? note;
  final DateTime callTime;

  const LocalCallHistoryEntry({
    required this.id,
    required this.phoneNumber,
    this.note,
    required this.callTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'note': note,
        'callTime': callTime.toIso8601String(),
      };

  factory LocalCallHistoryEntry.fromJson(Map<String, dynamic> json) => LocalCallHistoryEntry(
        id: (json['id'] ?? '').toString(),
        phoneNumber: (json['phoneNumber'] ?? '').toString(),
        note: json['note']?.toString(),
        callTime: DateTime.tryParse((json['callTime'] ?? '').toString()) ?? DateTime.now(),
      );
}

class PrivacyLocalStore {
  static const String _vipKey = 'privacy_local_vips';
  static const String _blockedKey = 'privacy_local_blocked';
  static const String _emergencyKey = 'privacy_local_emergency_contacts';
  static const String _historyKey = 'privacy_local_history_entries';

  static Future<List<LocalVipEntry>> getVipEntries() => _readList(
        _vipKey,
        LocalVipEntry.fromJson,
      );

  static Future<void> saveVipEntries(List<LocalVipEntry> entries) async {
    final normalized = <String>{};
    final deduped = <LocalVipEntry>[];
    for (final entry in entries) {
      final phone = CallDetection.normalizeNumber(entry.phoneNumber);
      if (phone.isEmpty || normalized.contains(phone)) continue;
      normalized.add(phone);
      deduped.add(LocalVipEntry(id: entry.id, phoneNumber: phone, name: entry.name));
    }
    await _writeList(_vipKey, deduped.map((entry) => entry.toJson()).toList());
    await ScreeningSyncService.setVipNumbers(deduped.map((entry) => entry.phoneNumber).toList());
  }

  static Future<List<LocalBlockedEntry>> getBlockedEntries() => _readList(
        _blockedKey,
        LocalBlockedEntry.fromJson,
      );

  static Future<void> saveBlockedEntries(List<LocalBlockedEntry> entries) async {
    final normalized = <String>{};
    final deduped = <LocalBlockedEntry>[];
    for (final entry in entries) {
      final phone = CallDetection.normalizeNumber(entry.phoneNumber);
      if (phone.isEmpty || normalized.contains(phone)) continue;
      normalized.add(phone);
      deduped.add(LocalBlockedEntry(id: entry.id, phoneNumber: phone, note: entry.note));
    }
    await _writeList(_blockedKey, deduped.map((entry) => entry.toJson()).toList());
    await ScreeningSyncService.setBlockedNumbers(deduped.map((entry) => entry.phoneNumber).toList());
  }

  static Future<List<LocalEmergencyContact>> getEmergencyContacts() => _readList(
        _emergencyKey,
        LocalEmergencyContact.fromJson,
      );

  static Future<void> saveEmergencyContacts(List<LocalEmergencyContact> entries) async {
    final normalized = <String>{};
    final deduped = <LocalEmergencyContact>[];
    for (final entry in entries) {
      final phone = CallDetection.normalizeNumber(entry.phoneNumber);
      if (phone.isEmpty || normalized.contains(phone)) continue;
      normalized.add(phone);
      deduped.add(
        LocalEmergencyContact(
          id: entry.id,
          phoneNumber: phone,
          name: entry.name,
          note: entry.note,
          createdAt: entry.createdAt,
        ),
      );
    }
    await _writeList(_emergencyKey, deduped.map((entry) => entry.toJson()).toList());
  }

  static Future<List<LocalCallHistoryEntry>> getHistoryEntries() => _readList(
        _historyKey,
        LocalCallHistoryEntry.fromJson,
      );

  static Future<void> saveHistoryEntries(List<LocalCallHistoryEntry> entries) async {
    final normalizedEntries = entries
        .map(
          (entry) => LocalCallHistoryEntry(
            id: entry.id,
            phoneNumber: CallDetection.normalizeNumber(entry.phoneNumber),
            note: entry.note,
            callTime: entry.callTime,
          ),
        )
        .where((entry) => entry.phoneNumber.isNotEmpty)
        .toList()
      ..sort((a, b) => b.callTime.compareTo(a.callTime));

    await _writeList(_historyKey, normalizedEntries.map((entry) => entry.toJson()).toList());
  }

  static Future<void> addSpamReport(String phoneNumber) async {
    final normalized = CallDetection.normalizeNumber(phoneNumber);
    if (normalized.isEmpty) return;
    await ReportStore.addReport(normalized);
  }

  static Future<void> addCallHistoryEvent(String phoneNumber, {String? note}) async {
    final normalized = CallDetection.normalizeNumber(phoneNumber);
    if (normalized.isEmpty) return;

    await CallHistoryStore.addEvent(CallEvent(normalized, DateTime.now().toUtc()));

    final current = await getHistoryEntries();
    final updated = [
      LocalCallHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        phoneNumber: normalized,
        note: note,
        callTime: DateTime.now(),
      ),
      ...current,
    ];
    await saveHistoryEntries(updated);
  }

  static Future<List<T>> _readList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(key) ?? <String>[];
    return rawList
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .map(fromJson)
        .toList();
  }

  static Future<void> _writeList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      items.map((item) => jsonEncode(item)).toList(),
    );
  }
}

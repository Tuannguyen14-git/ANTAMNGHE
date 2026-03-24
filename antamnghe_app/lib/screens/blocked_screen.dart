import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'report_spam_screen.dart';

// Replace these URLs with your actual backend endpoints if different.
const String apiUrl = 'https://localhost:7295/api/Blocked';
const String apiUrlSpam = 'https://localhost:7295/api/SpamReports';

class BlockedNumber {
  final int id;
  final String phoneNumber;
  final String? note;

  BlockedNumber({required this.id, required this.phoneNumber, this.note});

  factory BlockedNumber.fromJson(Map<String, dynamic> json) => BlockedNumber(
    id: json['id'] as int,
    phoneNumber: json['phoneNumber'] as String,
    note: json['note'] as String?,
  );
}

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({Key? key}) : super(key: key);

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  bool isLoading = false;
  List<BlockedNumber> blockedList = [];

  @override
  void initState() {
    super.initState();
    _fetchBlockedList();
  }

  Future<void> _fetchBlockedList() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as List<dynamic>;
        blockedList = data
            .map((e) => BlockedNumber.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _addBlocked(String phone, [String? note]) async {
    final res = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 201 || res.statusCode == 200) _fetchBlockedList();
  }

  Future<void> _removeBlocked(int id) async {
    final res = await http.delete(Uri.parse('$apiUrl/$id'));
    if (res.statusCode == 204 || res.statusCode == 200) {
      setState(() => blockedList.removeWhere((v) => v.id == id));
    }
  }

  Future<void> _updateBlocked(int id, String phone, [String? note]) async {
    final res = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 200) _fetchBlockedList();
  }

  Future<void> _reportSpam(String phone) async {
    try {
      final res = await http.post(
        Uri.parse(apiUrlSpam),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phone,
          'reason': 'reported from app',
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.statusCode == 201 || res.statusCode == 200
                ? 'Đã báo cáo số spam'
                : 'Báo cáo thất bại',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lỗi kết nối')));
    }
  }

  void _showEditDialog(BlockedNumber blocked) {
    final phoneCtl = TextEditingController(text: blocked.phoneNumber);
    final noteCtl = TextEditingController(text: blocked.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa số chặn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              controller: phoneCtl,
              decoration: const InputDecoration(hintText: 'Nhập số điện thoại'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtl,
              decoration: const InputDecoration(
                hintText: 'Ghi chú (không bắt buộc)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final phone = phoneCtl.text.trim();
              final note = noteCtl.text.trim();
              if (phone.isNotEmpty) _updateBlocked(blocked.id, phone, note);
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final phoneCtl = TextEditingController();
    final noteCtl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm số chặn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              controller: phoneCtl,
              decoration: const InputDecoration(hintText: 'Nhập số điện thoại'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteCtl,
              decoration: const InputDecoration(
                hintText: 'Ghi chú (không bắt buộc)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final phone = phoneCtl.text.trim();
              final note = noteCtl.text.trim();
              if (phone.isNotEmpty) _addBlocked(phone, note);
              Navigator.pop(ctx);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách chặn'),
        actions: [
          IconButton(
            tooltip: 'Báo cáo spam',
            icon: const Icon(Icons.report),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ReportSpamScreen())),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedList.isEmpty
          ? const Center(child: Text('Chưa có số chặn nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: blockedList.length,
              itemBuilder: (ctx, i) {
                final b = blockedList[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.red.shade50,
                            child: const Icon(
                              Icons.block,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.phoneNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (b.note != null && b.note!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    b.note!,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.report_problem,
                                  color: Colors.purple,
                                ),
                                onPressed: () => _reportSpam(b.phoneNumber),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showEditDialog(b),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeBlocked(b.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BlockedNumber {
  final int id;
  final String phoneNumber;
  final String? note;

  BlockedNumber({required this.id, required this.phoneNumber, this.note});

  factory BlockedNumber.fromJson(Map<String, dynamic> json) {
    return BlockedNumber(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      note: json['note'],
    );
  }
}

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({super.key});

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen> {
  List<BlockedNumber> blockedList = [];
  bool isLoading = false;
  final String apiUrl =
      'https://localhost:7295/api/Blocked'; // Đổi lại nếu backend chạy port khác

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
        final List data = json.decode(res.body);
        setState(() {
          blockedList = data.map((e) => BlockedNumber.fromJson(e)).toList();
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _addBlocked(String phone, [String? note]) async {
    final res = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 201) {
      _fetchBlockedList();
    }
  }

  Future<void> _removeBlocked(int id) async {
    final res = await http.delete(Uri.parse('$apiUrl/$id'));
    if (res.statusCode == 204) {
      setState(() {
        blockedList.removeWhere((v) => v.id == id);
      });
    }
  }

  Future<void> _updateBlocked(int id, String phone, [String? note]) async {
    final res = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 200) {
      _fetchBlockedList();
    }
  }

  void _showEditDialog(BlockedNumber blocked) {
    String phone = blocked.phoneNumber;
    String note = blocked.note ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa số chặn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Nhập số điện thoại'),
              controller: TextEditingController(text: phone),
              onChanged: (val) => phone = val,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ghi chú (không bắt buộc)',
              ),
              controller: TextEditingController(text: note),
              onChanged: (val) => note = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phone.trim().isNotEmpty)
                _updateBlocked(blocked.id, phone.trim(), note.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String phone = '';
    String note = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm số chặn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: 'Nhập số điện thoại'),
              onChanged: (val) => phone = val,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Ghi chú (không bắt buộc)',
              ),
              onChanged: (val) => note = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phone.trim().isNotEmpty)
                _addBlocked(phone.trim(), note.trim());
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
      appBar: AppBar(title: const Text('Blocked List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedList.isEmpty
          ? const Center(child: Text('Chưa có số chặn nào.'))
          : ListView.builder(
              itemCount: blockedList.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.block, color: Colors.redAccent),
                title: Text(blockedList[i].phoneNumber),
                subtitle:
                    blockedList[i].note != null &&
                        blockedList[i].note!.isNotEmpty
                    ? Text(blockedList[i].note!)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditDialog(blockedList[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeBlocked(blockedList[i].id),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

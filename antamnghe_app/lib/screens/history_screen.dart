import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'report_spam_screen.dart';

class CallHistory {
  final int id;
  final String phoneNumber;
  final String? note;
  final DateTime callTime;

  CallHistory({
    required this.id,
    required this.phoneNumber,
    this.note,
    required this.callTime,
  });

  factory CallHistory.fromJson(Map<String, dynamic> json) {
    return CallHistory(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      note: json['note'],
      callTime: DateTime.parse(json['callTime']),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CallHistory> historyList = [];
  bool isLoading = false;
  final String apiUrl =
      'https://localhost:7295/api/CallHistory'; // Đổi lại nếu backend chạy port khác
  final String? token = null; // Gán token ở đây hoặc truyền từ ngoài vào

  @override
  void initState() {
    super.initState();
    _fetchHistoryList();
  }

  Map<String, String> getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  Future<void> _fetchHistoryList() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(apiUrl), headers: getHeaders());
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          historyList = data.map((e) => CallHistory.fromJson(e)).toList();
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _addHistory(String phone, [String? note]) async {
    final res = await http.post(
      Uri.parse(apiUrl),
      headers: getHeaders(),
      body: json.encode({'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 201) {
      _fetchHistoryList();
    }
  }

  Future<void> _removeHistory(int id) async {
    final res = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: getHeaders(),
    );
    if (res.statusCode == 204) {
      setState(() {
        historyList.removeWhere((v) => v.id == id);
      });
    }
  }

  Future<void> _updateHistory(int id, String phone, [String? note]) async {
    final res = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: getHeaders(),
      body: json.encode({'id': id, 'phoneNumber': phone, 'note': note}),
    );
    if (res.statusCode == 200) {
      _fetchHistoryList();
    }
  }

  void _showEditDialog(CallHistory item) {
    String phone = item.phoneNumber;
    String note = item.note ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa lịch sử gọi'),
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
                _updateHistory(item.id, phone.trim(), note.trim());
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
        title: const Text('Thêm lịch sử gọi'),
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
                _addHistory(phone.trim(), note.trim());
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
      appBar: AppBar(title: const Text('Lịch sử cuộc gọi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyList.isEmpty
          ? const Center(child: Text('Chưa có lịch sử nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: historyList.length,
              itemBuilder: (ctx, i) {
                final h = historyList[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blueGrey.shade50,
                            child: const Icon(
                              Icons.history,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  h.phoneNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Thời gian: ${h.callTime}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                if (h.note != null && h.note!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    h.note!,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.report_problem,
                                  color: Colors.purple,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReportSpamScreen(
                                        initialPhone: h.phoneNumber,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showEditDialog(h),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeHistory(h.id),
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

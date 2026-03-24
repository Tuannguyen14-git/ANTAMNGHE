import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Vip {
  final int id;
  final String phoneNumber;
  final String? name;

  Vip({required this.id, required this.phoneNumber, this.name});

  factory Vip.fromJson(Map<String, dynamic> json) {
    return Vip(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
    );
  }
}

class VipListScreen extends StatefulWidget {
  const VipListScreen({super.key});

  @override
  State<VipListScreen> createState() => _VipListScreenState();
}

class _VipListScreenState extends State<VipListScreen> {
  List<Vip> vipList = [];
  bool isLoading = false;
  final String apiUrl =
      'https://localhost:7295/api/VipList'; // Đổi lại nếu backend chạy port khác

  @override
  void initState() {
    super.initState();
    _fetchVipList();
  }

  Future<void> _fetchVipList() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(apiUrl));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          vipList = data.map((e) => Vip.fromJson(e)).toList();
        });
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _addVip(String phone, [String? name]) async {
    final res = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneNumber': phone, 'name': name}),
    );
    if (res.statusCode == 201) {
      _fetchVipList();
    }
  }

  Future<void> _removeVip(int id) async {
    final res = await http.delete(Uri.parse('$apiUrl/$id'));
    if (res.statusCode == 204) {
      setState(() {
        vipList.removeWhere((v) => v.id == id);
      });
    }
  }

  Future<void> _updateVip(int id, String phone, [String? name]) async {
    final res = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'phoneNumber': phone, 'name': name}),
    );
    if (res.statusCode == 200) {
      _fetchVipList();
    }
  }

  void _showEditDialog(Vip vip) {
    String phone = vip.phoneNumber;
    String name = vip.name ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa số ưu tiên'),
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
                hintText: 'Tên (không bắt buộc)',
              ),
              controller: TextEditingController(text: name),
              onChanged: (val) => name = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phone.trim().isNotEmpty)
                _updateVip(vip.id, phone.trim(), name.trim());
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
    String name = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm số ưu tiên'),
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
                hintText: 'Tên (không bắt buộc)',
              ),
              onChanged: (val) => name = val,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (phone.trim().isNotEmpty) _addVip(phone.trim(), name.trim());
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
      appBar: AppBar(title: const Text('Danh bạ ưu tiên')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vipList.isEmpty
          ? const Center(child: Text('Chưa có số ưu tiên nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vipList.length,
              itemBuilder: (ctx, i) {
                final vip = vipList[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(
                            0xFF4A4E69,
                          ), // gray-blue avatar
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vip.name ?? vip.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A), // main text
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vip.phoneNumber,
                                style: const TextStyle(
                                  color: Color(0xFFADB5BD), // secondary text
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.call),
                              color: const Color(0xFF6C757D), // neutral gray
                              onPressed: () {},
                              splashRadius: 24,
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              color: const Color(0xFF6C757D),
                              onPressed: () => _showEditDialog(vip),
                              splashRadius: 24,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              color: const Color(0xFF6C757D),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xác nhận'),
                                    content: const Text(
                                      'Bạn có chắc muốn xóa mục này?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          'Xóa',
                                          style: TextStyle(
                                            color: Color(0xFFE63946),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  _removeVip(vip.id);
                                }
                              },
                              splashRadius: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFE63946),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

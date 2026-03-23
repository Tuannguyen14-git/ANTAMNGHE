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
      appBar: AppBar(title: const Text('VIP List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vipList.isEmpty
          ? const Center(child: Text('Chưa có số ưu tiên nào.'))
          : ListView.builder(
              itemCount: vipList.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.person, color: Colors.blueAccent),
                title: Text(vipList[i].phoneNumber),
                subtitle: vipList[i].name != null && vipList[i].name!.isNotEmpty
                    ? Text(vipList[i].name!)
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditDialog(vipList[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeVip(vipList[i].id),
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

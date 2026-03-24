import 'package:flutter/material.dart';

import '../services/privacy_local_store.dart';

class EmergencyContact {
  final String id;
  final String phoneNumber;
  final String? name;
  final String? note;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.note,
    required this.createdAt,
  });

  factory EmergencyContact.fromEntry(LocalEmergencyContact entry) => EmergencyContact(
    id: entry.id,
    phoneNumber: entry.phoneNumber,
    name: entry.name,
    note: entry.note,
    createdAt: entry.createdAt,
  );

  LocalEmergencyContact toEntry() => LocalEmergencyContact(
    id: id,
    phoneNumber: phoneNumber,
    name: name,
    note: note,
    createdAt: createdAt,
  );
}

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<EmergencyContact> emergencyList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchEmergencyList();
  }

  Future<void> _fetchEmergencyList() async {
    setState(() => isLoading = true);
    try {
      final entries = await PrivacyLocalStore.getEmergencyContacts();
      setState(() {
        emergencyList = entries.map(EmergencyContact.fromEntry).toList();
      });
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> _addEmergency(String phone, [String? name, String? note]) async {
    final updated = [
      ...emergencyList,
      EmergencyContact(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        phoneNumber: phone,
        name: name,
        note: note,
        createdAt: DateTime.now(),
      ),
    ];
    await PrivacyLocalStore.saveEmergencyContacts(updated.map((item) => item.toEntry()).toList());
    await _fetchEmergencyList();
  }

  Future<void> _removeEmergency(String id) async {
    setState(() {
      emergencyList.removeWhere((v) => v.id == id);
    });
    await PrivacyLocalStore.saveEmergencyContacts(emergencyList.map((item) => item.toEntry()).toList());
  }

  Future<void> _updateEmergency(
    String id,
    String phone, [
    String? name,
    String? note,
  ]) async {
    final updated = emergencyList
        .map(
          (item) => item.id == id
              ? EmergencyContact(
                  id: item.id,
                  phoneNumber: phone,
                  name: name,
                  note: note,
                  createdAt: item.createdAt,
                )
              : item,
        )
        .toList();
    await PrivacyLocalStore.saveEmergencyContacts(updated.map((item) => item.toEntry()).toList());
    await _fetchEmergencyList();
  }

  void _showEditDialog(EmergencyContact item) {
    String phone = item.phoneNumber;
    String name = item.name ?? '';
    String note = item.note ?? '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa liên hệ khẩn cấp'),
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
                _updateEmergency(
                  item.id,
                  phone.trim(),
                  name.trim(),
                  note.trim(),
                );
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
    String note = '';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thêm liên hệ khẩn cấp'),
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
                _addEmergency(phone.trim(), name.trim(), note.trim());
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
      appBar: AppBar(title: const Text('Liên hệ khẩn cấp')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : emergencyList.isEmpty
          ? const Center(child: Text('Chưa có liên hệ nào.'))
          : ListView.builder(
              itemCount: emergencyList.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.orange),
                title: Text(emergencyList[i].phoneNumber),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (emergencyList[i].name != null &&
                        emergencyList[i].name!.isNotEmpty)
                      Text(emergencyList[i].name!),
                    if (emergencyList[i].note != null &&
                        emergencyList[i].note!.isNotEmpty)
                      Text(emergencyList[i].note!),
                    Text('Tạo lúc: ' + emergencyList[i].createdAt.toString()),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _showEditDialog(emergencyList[i]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeEmergency(emergencyList[i].id),
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

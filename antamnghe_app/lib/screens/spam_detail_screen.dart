import 'package:flutter/material.dart';
import '../services/spam_service.dart';

class SpamDetailScreen extends StatefulWidget {
  const SpamDetailScreen({super.key});

  @override
  State<SpamDetailScreen> createState() => _SpamDetailScreenState();
}

class _SpamDetailScreenState extends State<SpamDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _item;
  int? _id;
  String? _phone;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadFromArgs);
  }

  Future<void> _loadFromArgs() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['id'] != null) _id = args['id'] as int?;
      if (args['phone'] != null) _phone = args['phone']?.toString();
    }

    try {
      if (_id != null) {
        final data = await SpamService.instance.getById(_id!);
        if (!mounted) return;
        setState(() => _item = data);
      } else if (_phone != null) {
        final list = await SpamService.instance.getAll();
        final found = list.firstWhere(
          (e) => e['phone']?.toString() == _phone,
          orElse: () => <String, dynamic>{},
        );
        if (!mounted) return;
        if (found.isNotEmpty) {
          setState(() {
            _item = Map<String, dynamic>.from(found);
            _id = _item?['id'] as int?;
          });
        } else {
          setState(() => _item = {'phone': _phone});
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải chi tiết: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _report() async {
    final phone = _item?['phone']?.toString();
    if (phone == null || phone.isEmpty) return;
    try {
      await SpamService.instance.add({
        'phone': phone,
        'type': 'user',
        'reportCount': 1,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo')));
      _loadFromArgs();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi báo cáo: ${e.toString()}')),
      );
    }
  }

  Future<void> _delete() async {
    if (_id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa mục này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await SpamService.instance.delete(_id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi xóa: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết số')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: _item == null
                  ? const Center(child: Text('Không tìm thấy dữ liệu'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(_item?['phone']?.toString() ?? ''),
                          subtitle: Text('Loại: ${_item?['type'] ?? '—'}'),
                        ),
                        const SizedBox(height: 8),
                        Text('Số lượt báo cáo: ${_item?['reportCount'] ?? 0}'),
                        const SizedBox(height: 16),
                        if (_item?['note'] != null) ...[
                          const Text(
                            'Ghi chú:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(_item?['note']?.toString() ?? ''),
                          const SizedBox(height: 16),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _report,
                                icon: const Icon(Icons.report),
                                label: const Text('Báo cáo'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _delete,
                                icon: const Icon(Icons.delete),
                                label: const Text('Xóa'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
    );
  }
}

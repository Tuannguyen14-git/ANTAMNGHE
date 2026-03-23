import 'package:flutter/material.dart';
import '../services/spam_service.dart';
import '../services/auth_service.dart';
import '../widgets/list_item_spam.dart';

class ProtectionScreen extends StatefulWidget {
  const ProtectionScreen({super.key});

  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  final _checkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoad();
  }

  Future<void> _checkLoginAndLoad() async {
    final user = await AuthService.instance.currentUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    await _load();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await SpamService.instance.getAll();
      if (!mounted) return;
      setState(() => _items = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _check() async {
    final phone = _checkController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nhập số điện thoại để kiểm tra')),
      );
      return;
    }
    try {
      final isSpam = await SpamService.instance.check(phone);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isSpam ? 'Số này được báo spam' : 'Số này sạch'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi kiểm tra: ${e.toString()}')));
    }
  }

  Future<void> _report(String phone) async {
    try {
      final model = {'phone': phone, 'type': 'user', 'reportCount': 1};
      await SpamService.instance.add(model);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gửi báo cáo')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi báo cáo: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      appBar: AppBar(title: const Text('Bảo vệ khỏi Spam')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, Theme.of(context).colorScheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // illustration placeholder
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: onPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.smartphone,
                          size: 72,
                          color: onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Kiểm tra số điện thoại spam:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _checkController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nhập số điện thoại',
                        labelStyle: TextStyle(color: Colors.white70),
                        hintStyle: TextStyle(color: Colors.white38),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _check,
                    child: const Text('Kiểm tra'),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // List of reports
              if (_loading)
                const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('Không có dữ liệu')),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final phone = item['phone']?.toString() ?? '';
                    final label = 'Báo cáo: ${item['reportCount'] ?? 0}';
                    return ListItemSpam(
                      phone: phone,
                      label: label,
                      onTap: () async {
                        final result = await Navigator.of(context).pushNamed(
                          '/spam_detail',
                          arguments: {'id': item['id'], 'phone': phone},
                        );
                        if (!mounted) return;
                        if (result == true) _load();
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

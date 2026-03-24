import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/call_screening_channel.dart';
import '../services/spam_service.dart';
import '../theme/app_theme.dart';

class ProtectionScreen extends StatefulWidget {
  const ProtectionScreen({super.key});

  @override
  State<ProtectionScreen> createState() => _ProtectionScreenState();
}

class _ProtectionScreenState extends State<ProtectionScreen> {
  bool _loading = true;
  bool _autoBlockEnabled = false;
  List<Map<String, dynamic>> _items = [];
  final _checkController = TextEditingController();

  bool get _supportsNativeScreening => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoad();
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
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
          content: Text(isSpam ? 'Số này được báo spam' : 'Số này hiện chưa bị báo spam'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi kiểm tra: ${e.toString()}')),
      );
    }
  }

  Future<void> _enableProtection() async {
    if (!_supportsNativeScreening) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tính năng chặn cuộc gọi chỉ hỗ trợ trên Android.')),
      );
      return;
    }

    final ok = await CallScreeningChannel.openAppSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Đã mở cài đặt để bật chặn cuộc gọi.' : 'Không thể mở cài đặt ứng dụng.'),
      ),
    );
  }

  Future<void> _toggleProtection(bool value) async {
    setState(() => _autoBlockEnabled = value);
    if (value) {
      await _enableProtection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textTitle,
        title: const Text('Bảo vệ khỏi Spam'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _HeroProtectionCard(
              supportsNativeScreening: _supportsNativeScreening,
              onPressed: _enableProtection,
            ),
            const SizedBox(height: 20),
            _ProtectionTile(
              icon: Icons.shield_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Tự động chặn spam',
              subtitle: _supportsNativeScreening
                  ? 'Bật chặn cuộc gọi và chuyển sang cài đặt Android'
                  : 'Chỉ khả dụng trên Android',
              trailing: Switch.adaptive(
                value: _autoBlockEnabled,
                onChanged: _toggleProtection,
                activeColor: const Color(0xFF2C7DFF),
              ),
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.pin_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Chuỗi số',
              subtitle: 'Nhận diện mẫu số lặp và số nghi ngờ từ heuristics',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng này đang được hoàn thiện.')),
                );
              },
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.block_outlined,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Danh sách chặn',
              subtitle: 'Xem và quản lý các số bạn đã chặn',
              onTap: () => Navigator.pushNamed(context, '/blocked'),
            ),
            const SizedBox(height: 12),
            _ProtectionTile(
              icon: Icons.star_border,
              iconBackground: const Color(0xFFFF4D3D),
              title: 'Danh bạ ưu tiên',
              subtitle: 'Luôn cho phép các số quan trọng đi qua bộ lọc',
              onTap: () => Navigator.pushNamed(context, '/vip-list'),
            ),
            const SizedBox(height: 22),
            const Text(
              'Kiểm tra số điện thoại spam',
              style: TextStyle(
                color: AppTheme.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checkController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppTheme.textTitle),
                    decoration: InputDecoration(
                      hintText: 'Nhập số điện thoại',
                      hintStyle: const TextStyle(color: AppTheme.placeholder),
                      fillColor: AppTheme.searchBackground,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _check,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                    ),
                    child: const Text('Kiểm tra'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Báo cáo cộng đồng gần đây',
              style: TextStyle(
                color: AppTheme.textTitle,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              )
            else if (_items.isEmpty)
              const _EmptyProtectionState()
            else
              ..._items.take(8).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CommunityReportTile(item: item),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroProtectionCard extends StatelessWidget {
  final bool supportsNativeScreening;
  final VoidCallback onPressed;

  const _HeroProtectionCard({
    required this.supportsNativeScreening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.headerGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          const _PhoneShieldArt(),
          const SizedBox(height: 18),
          const Text(
            'ID Người gọi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            supportsNativeScreening
                ? 'Bật bộ lọc cuộc gọi để nhận cảnh báo và chặn spam theo thời gian thực.'
                : 'Giao diện này đã sẵn sàng, nhưng tính năng chặn cuộc gọi hiện chỉ hoạt động trên Android.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFCECEE),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.textTitle,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(supportsNativeScreening ? 'Nhận cuộc gọi ngay' : 'Xem trên Android'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneShieldArt extends StatelessWidget {
  const _PhoneShieldArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _FloatingChip(offset: Offset(-118, -50), color: Color(0xFFFFD35A), angle: -0.8),
          const _FloatingChip(offset: Offset(-98, 10), color: Color(0xFFFFA37C), angle: -0.55),
          const _FloatingChip(offset: Offset(108, -44), color: Color(0xFFFFE6D9), angle: -0.48),
          const _FloatingChip(offset: Offset(116, 22), color: Color(0xFFFFC742), angle: 0.6),
          const _FloatingChip(offset: Offset(-44, 78), color: Color(0xFFFFD9A8), angle: -0.45),
          const _FloatingChip(offset: Offset(72, 88), color: Color(0xFFFFC0AF), angle: 0.22),
          Positioned(
            bottom: 14,
            child: Container(
              width: 132,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Container(
            width: 126,
            height: 168,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8F70), Color(0xFFE63946)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0x1A1D1D1F),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 42,
                  left: 18,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: const Color(0xFFFFD8B8),
                    child: Icon(Icons.person, size: 14, color: Colors.brown.shade700),
                  ),
                ),
                Positioned(
                  top: 44,
                  left: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1EB),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 44,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8B2A3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 26,
                  bottom: 28,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD166),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 26,
                  bottom: 28,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 74,
            top: 82,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2ED6A1), Color(0xFF16B987)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 52),
            ),
          ),
          const Positioned(
            top: 6,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFFFD166),
            ),
          ),
          const Positioned(
            right: 34,
            bottom: 76,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFFFF1EB),
            ),
          ),
          const Positioned(
            right: 18,
            top: 78,
            child: CircleAvatar(
              radius: 7,
              backgroundColor: Color(0xFFFFE6D9),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  final Offset offset;
  final Color color;
  final double angle;

  const _FloatingChip({
    required this.offset,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 18,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}

class _ProtectionTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _ProtectionTile({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textTitle,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                const Icon(Icons.chevron_right, color: AppTheme.arrowColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityReportTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _CommunityReportTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final phone = item['phone']?.toString() ?? '';
    final label = 'Báo cáo: ${item['reportCount'] ?? 0}';
    final accent = _badgeColor(phone);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          final result = await Navigator.of(context).pushNamed(
            '/spam_detail',
            arguments: {'id': item['id'], 'phone': phone},
          );
          if (context.mounted && result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật chi tiết số điện thoại.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: accent,
                  child: Text(
                    phone.length >= 2 ? phone.substring(phone.length - 2) : phone,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone,
                      style: const TextStyle(
                        color: AppTheme.textTitle,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Chi tiết',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right, color: Color(0xFF8B93A7)),
                  const Icon(Icons.chevron_right, color: AppTheme.arrowColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _badgeColor(String phone) {
    final code = phone.isNotEmpty ? phone.codeUnitAt(phone.length - 1) : 0;
    const colors = [
      Color(0xFFFF6B6B),
      Color(0xFFFFA94D),
      Color(0xFFFFC94D),
      Color(0xFF4DABF7),
      Color(0xFF51CF66),
    ];
    return colors[code % colors.length];
  }
}

class _EmptyProtectionState extends StatelessWidget {
  const _EmptyProtectionState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.forum_outlined, color: AppTheme.primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Chưa có báo cáo mới từ cộng đồng. Hãy kiểm tra số hoặc bật chặn cuộc gọi để bắt đầu.',
              style: TextStyle(color: AppTheme.textBody, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

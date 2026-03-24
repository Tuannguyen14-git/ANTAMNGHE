// --- Section và Tile dùng chung cho Home và Profile ---
import 'package:antamnghe_app/widgets/avatar_badge.dart';
import 'package:antamnghe_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'protection_screen.dart';
import 'premium_screen.dart';
import 'profile_viewers_screen.dart';
import 'notification_screen.dart';

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF121214),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  const _Tile({required this.text, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withOpacity(0.12),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final List<String> _recent = [];
  static const String _kHistoryKey = 'search_history';
  String? _userName;
  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadHistory();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr) as Map<String, dynamic>;
        if (!mounted) return;
        setState(() {
          _userName = user['name'] ?? '';
        });
      }
    } catch (_) {
      // ignore errors
    }
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_kHistoryKey) ?? [];
      if (!mounted) return;
      setState(() {
        _recent.clear();
        _recent.addAll(history);
      });
    } catch (_) {
      // ignore errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'truecaller',
                  style: TextStyle(
                    color: primary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/profile'),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: const AvatarBadge(
                        initials: 'MN',
                        square: true,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Xin chào,',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _userName ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // Banner
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kích hoạt ID Người gọi',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Xác định mọi cuộc gọi và xem ai đang gọi cho bạn',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cta,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 18,
                            ),
                          ),
                          child: const Text(
                            'Nhận ngay',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.9),
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar (thanh tìm kiếm) — white card with larger radius and subtle shadow
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.searchBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000), // rgba(0,0,0,0.05)
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.mutedIcon, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _searchFocus,
                      style: TextStyle(color: AppTheme.textTitle, fontSize: 16),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tìm kiếm một số điện thoại',
                        hintStyle: TextStyle(
                          color: AppTheme.textBody,
                          fontSize: 16,
                        ),
                        isCollapsed: true,
                      ),
                      cursorColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Section Cài đặt (đã xóa mục Xem Hồ sơ)
            // _Section(
            //   title: 'Cài đặt',
            //   children: [
            //     _Tile(
            //       text: 'Xem Hồ sơ',
            //       icon: Icons.remove_red_eye,
            //       onTap: () {
            //         Navigator.of(context).pushNamed('/profile');
            //       },
            //     ),
            //   ],
            // ),

            // Search Placeholder (Kính lúp)
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          offset: Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Chưa có tìm kiếm nào',
                    style: TextStyle(
                      color: AppTheme.textTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tìm kiếm của bạn sẽ xuất hiện ở đây',
                    style: TextStyle(color: AppTheme.textBody, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Khám phá',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _ExploreCard(
                  icon: Icons.person,
                  label: 'VIP List',
                  bgColor: AppTheme.card,
                  iconColor: Colors.white,
                  circleColor: AppTheme.primary,
                  onTap: () {
                    Navigator.of(context).pushNamed('/vip-list');
                  },
                ),
                _ExploreCard(
                  icon: Icons.block,
                  label: 'Blocked',
                  bgColor: AppTheme.card,
                  iconColor: Colors.white,
                  circleColor: AppTheme.primary,
                  onTap: () {
                    Navigator.of(context).pushNamed('/blocked');
                  },
                ),
                _ExploreCard(
                  icon: Icons.history,
                  label: 'History',
                  bgColor: AppTheme.card,
                  iconColor: Colors.white,
                  circleColor: AppTheme.primary,
                  onTap: () {
                    Navigator.of(context).pushNamed('/history');
                  },
                ),
                _ExploreCard(
                  icon: Icons.error_outline,
                  label: 'Emergency',
                  bgColor: AppTheme.card,
                  iconColor: Colors.white,
                  circleColor: AppTheme.primary,
                  onTap: () {
                    Navigator.of(context).pushNamed('/emergency');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color circleColor;
  final VoidCallback? onTap;
  const _ExploreCard({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.circleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 16) / 2;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textTitle,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomeContent(),
    ProtectionScreen(),
    PremiumScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Protection',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Premium'),
        ],
      ),
    );
  }
}

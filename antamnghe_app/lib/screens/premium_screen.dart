import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Gói Premium'), elevation: 0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nâng cấp Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Mở khóa nhận diện cuộc gọi, chặn spam nâng cao và trải nghiệm không quảng cáo.',
                          style: TextStyle(
                            color: Color(0xFFFCECEE),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0x26FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: PageView(
              controller: PageController(viewportFraction: 0.86),
              children: const [
                PremiumCard(
                  title: 'Premium',
                  badge: 'Phổ biến',
                  accent: AppTheme.primary,
                  monthly: '28.000đ/tháng',
                  yearly: '195.000đ/năm',
                  description: 'Dành cho cá nhân muốn lọc spam và nhận diện cuộc gọi ổn định mỗi ngày.',
                  features: [
                    'ID Người gọi theo thời gian thực',
                    'Tự động chặn spam',
                    'Không quảng cáo',
                    'Cảnh báo cuộc gọi nghi ngờ',
                    'Đồng bộ danh sách ưu tiên',
                  ],
                ),
                PremiumCard(
                  title: 'Family',
                  badge: 'Gia đình',
                  accent: Color(0xFFFF8A5B),
                  monthly: '65.000đ/tháng',
                  yearly: '455.000đ/năm',
                  description: 'Chia sẻ quyền lợi cho cả nhà và bảo vệ nhiều thiết bị trong cùng tài khoản.',
                  features: [
                    'Toàn bộ tính năng Premium',
                    'Chia sẻ trong gia đình',
                    'Quản lý nhiều thiết bị',
                    'Ưu tiên hỗ trợ kỹ thuật',
                    'Bộ lọc nâng cao cho trẻ em và người lớn tuổi',
                  ],
                ),
                PremiumCard(
                  title: 'Gold',
                  badge: 'Cao cấp',
                  accent: AppTheme.accent,
                  monthly: 'Gói cao cấp',
                  yearly: 'Liên hệ',
                  description: 'Gói dành cho người dùng cần hỗ trợ VIP và tính năng ưu tiên chuyên sâu.',
                  features: [
                    'Tất cả tính năng Family',
                    'Ưu đãi VIP',
                    'Hỗ trợ cao cấp',
                    'Tư vấn thiết lập riêng',
                    'Ưu tiên tính năng mới',
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Text(
              'So sánh gói để chọn mức bảo vệ phù hợp cho bạn.',
              style: TextStyle(color: AppTheme.textBody),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final Color accent;
  final String monthly;
  final String yearly;
  final String badge;
  final String description;

  const PremiumCard({
    super.key,
    required this.title,
    required this.features,
    required this.accent,
    required this.monthly,
    required this.yearly,
    required this.badge,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: radius,
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.iconBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.workspace_premium, color: accent, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textTitle,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textBody,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent.withValues(alpha: 0.14), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gói tháng',
                            style: TextStyle(
                              color: AppTheme.textBody,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            monthly,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Ưu đãi',
                        style: TextStyle(
                          color: accent.computeLuminance() > 0.5 ? AppTheme.textTitle : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.iconBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            features[idx],
                            style: const TextStyle(
                              color: AppTheme.textTitle,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Chọn gói $yearly',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

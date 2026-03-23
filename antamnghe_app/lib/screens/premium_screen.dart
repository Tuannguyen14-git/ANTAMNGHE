import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Gói Premium'), elevation: 0),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: PageController(viewportFraction: 0.82),
              children: [
                PremiumCard(
                  title: 'Premium',
                  accent: Colors.blue.shade700,
                  gradient: const [Color(0xFF1E88FF), Color(0xFF2563EB)],
                  monthly: '28.000đ/tháng',
                  yearly: '195.000đ/năm',
                  features: const [
                    'ID Người gọi',
                    'Tự động chặn spam',
                    'Ko quảng cáo',
                    'Cảnh Báo Cuộc Gọi',
                    'Biểu tượng tắt Siri',
                  ],
                ),
                PremiumCard(
                  title: 'Family',
                  accent: const Color(0xFF8B5CF6),
                  gradient: const [Color(0xFFE9D5FF), Color(0xFFD6BCFA)],
                  monthly: '65.000đ/tháng',
                  yearly: '455.000đ/năm',
                  features: const [
                    'ID Người gọi',
                    'Tự động chặn spam',
                    'Ko quảng cáo',
                    'Cảnh Báo Cuộc Gọi',
                    'Chia sẻ trong Gia đình',
                  ],
                ),
                PremiumCard(
                  title: 'Gold',
                  accent: const Color(0xFFF59E0B),
                  gradient: const [Color(0xFFFFE082), Color(0xFFF59E0B)],
                  monthly: 'Gói cao cấp',
                  yearly: 'Liên hệ',
                  features: const [
                    'ID Người gọi',
                    'Tự động chặn spam',
                    'Ưu đãi VIP',
                    'Hỗ trợ cao cấp',
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Text(
              'Tìm hiểu các tính năng và so sánh các gói',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
      backgroundColor: bg,
    );
  }
}

class PremiumCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final List<Color> gradient;
  final Color accent;
  final String monthly;
  final String yearly;

  const PremiumCard({
    super.key,
    required this.title,
    required this.features,
    required this.gradient,
    required this.accent,
    required this.monthly,
    required this.yearly,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20.0);
    final textOnAccent = Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Material(
        elevation: 8,
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: radius,
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Truecaller',
                style: TextStyle(
                  color: textOnAccent.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: textOnAccent,
                ),
              ),
              const SizedBox(height: 10),
              // features
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: features.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check,
                          size: 18,
                          color: textOnAccent.withOpacity(0.95),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            features[idx],
                            style: TextStyle(
                              color: textOnAccent.withOpacity(0.95),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              // price area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gói tháng',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthly,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Giảm giá',
                        style: TextStyle(
                          color: textOnAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: gradient.first,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    yearly,
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

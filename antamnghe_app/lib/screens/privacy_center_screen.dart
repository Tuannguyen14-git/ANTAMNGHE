import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/call_screening_channel.dart';
import '../theme/app_theme.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  bool get _supportsAndroidControls =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Trung tâm Quyền riêng tư'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dữ liệu nhạy cảm được ưu tiên xử lý trên thiết bị',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'An Tâm Nghe dùng quyền cuộc gọi và SMS để lọc việc gấp, không phải để đọc đời tư của bạn. Mục tiêu của màn này là nói rõ ứng dụng đang dùng quyền gì, xử lý gì, và giới hạn ở đâu.',
                  style: TextStyle(
                    color: Color(0xFFFCECEE),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _PrivacySectionCard(
            icon: Icons.phone_in_talk_outlined,
            title: 'Những gì được xử lý trên thiết bị',
            lines: [
              'Danh sách spam cộng đồng sau khi đồng bộ sẽ được dùng cục bộ để quyết định chặn hay im lặng cuộc gọi.',
              'Trạng thái Smart Focus, danh sách chặn, lịch sử cục bộ và whitelist tạm thời đều được lưu trên máy.',
              'SMS khẩn cấp chỉ được quét trên Android để tìm từ khóa bạn tự cấu hình, sau đó mở quyền ưu tiên tạm thời cho số gửi.',
            ],
          ),
          const SizedBox(height: 14),
          const _PrivacySectionCard(
            icon: Icons.cloud_off_outlined,
            title: 'Những gì không nên bị tải lên máy chủ',
            lines: [
              'Nội dung SMS khẩn cấp không cần gửi về backend để tính năng hoạt động.',
              'Lịch sử quyết định lọc cuộc gọi và whitelist tạm thời không cần đồng bộ server trong luồng bảo vệ cốt lõi.',
              'Các quyền nhạy cảm chỉ nên được dùng để ra quyết định tại máy người dùng.',
              'Danh sách ưu tiên có thể được lưu ở backend nếu bạn chọn mô hình đồng bộ tài khoản, nhưng không cần chứa nội dung SMS hay lịch sử cuộc gọi.',
            ],
          ),
          const SizedBox(height: 14),
          const _PrivacySectionCard(
            icon: Icons.rule_folder_outlined,
            title: 'Quyền hệ thống ứng dụng đang dùng',
            lines: [
              'Call Screening: cho phép Android dùng An Tâm Nghe như bộ lọc cuộc gọi.',
              'SMS: chỉ phục vụ cơ chế từ khóa khẩn cấp trên Android.',
              'Thông báo: báo khi có SMS khẩn cấp hoặc thay đổi trạng thái ưu tiên.',
            ],
          ),
          const SizedBox(height: 14),
          _PrivacySectionCard(
            icon: _supportsAndroidControls ? Icons.android_rounded : Icons.info_outline,
            title: 'Giới hạn nền tảng',
            lines: _supportsAndroidControls
                ? const [
                    'Android hiện là nền tảng hỗ trợ đầy đủ nhất cho Smart Focus, gọi lặp lại và từ khóa SMS khẩn cấp.',
                    'Một số launcher không hỗ trợ ghim widget trực tiếp, nhưng bạn vẫn có thể thêm thủ công từ màn hình chính.',
                  ]
                : const [
                    'Bản hiện tại ưu tiên Android cho các tính năng quyền sâu của hệ điều hành.',
                    'iOS và web cần một tập tính năng suy giảm hợp lý vì hạn chế quyền hệ thống.',
                  ],
          ),
          const SizedBox(height: 18),
          if (_supportsAndroidControls)
            _QuickActionCard(
              onOpenAppSettings: () => _openAction(
                context,
                CallScreeningChannel.openAppSettings,
                successMessage: 'Đã mở cài đặt ứng dụng.',
                failureMessage: 'Không thể mở cài đặt ứng dụng trên thiết bị này.',
              ),
              onOpenDefaultApps: () => _openAction(
                context,
                CallScreeningChannel.openDefaultAppsSettings,
                successMessage: 'Đã mở cài đặt ứng dụng mặc định.',
                failureMessage: 'Không thể mở cài đặt ứng dụng mặc định trên thiết bị này.',
              ),
            )
          else
            const _PlatformNoticeCard(),
        ],
      ),
    );
  }

  Future<void> _openAction(
    BuildContext context,
    Future<bool> Function() action, {
    required String successMessage,
    required String failureMessage,
  }) async {
    final ok = await action();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? successMessage : failureMessage)),
    );
  }
}

class _PrivacySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _PrivacySectionCard({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 8, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: AppTheme.textBody,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final Future<void> Function() onOpenAppSettings;
  final Future<void> Function() onOpenDefaultApps;

  const _QuickActionCard({
    required this.onOpenAppSettings,
    required this.onOpenDefaultApps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lối tắt kiểm tra quyền',
            style: TextStyle(
              color: AppTheme.textTitle,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nếu bạn muốn tự kiểm tra lại quyền hoặc thay đổi ứng dụng mặc định, dùng các lối tắt dưới đây.',
            style: TextStyle(
              color: AppTheme.textBody,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOpenAppSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Mở cài đặt ứng dụng'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onOpenDefaultApps,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textTitle,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Mở ứng dụng mặc định'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformNoticeCard extends StatelessWidget {
  const _PlatformNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Text(
        'Các lối tắt vào quyền hệ thống hiện chỉ hữu ích trên Android. Với nền tảng khác, màn này đóng vai trò giải thích phạm vi xử lý dữ liệu và giới hạn tính năng.',
        style: TextStyle(
          color: AppTheme.textBody,
          fontSize: 14,
          height: 1.45,
        ),
      ),
    );
  }
}

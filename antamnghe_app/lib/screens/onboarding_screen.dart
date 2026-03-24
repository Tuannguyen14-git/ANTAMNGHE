import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/call_screening_channel.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bật chặn cuộc gọi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Cho phép ứng dụng chặn cuộc gọi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textTitle,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Để bật tính năng chặn cuộc gọi, bạn cần cấp quyền và đặt ứng dụng là "Call Screening app" trong cài đặt hệ thống. Sau khi bật, ứng dụng sẽ có thể từ chối cuộc gọi từ số spam theo danh sách bạn đã đồng bộ.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              'Các bước:',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('1. Mở Cài đặt ứng dụng (App settings).'),
            const Text(
              '2. Chọn Quyền (Permissions) hoặc Call Screening (tuỳ thiết bị).',
            ),
            const Text(
              '3. Đặt ứng dụng này làm ứng dụng chặn cuộc gọi mặc định.',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
              ),
              onPressed: () async {
                final ok = await CallScreeningChannel.openAppSettings();
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không thể mở cài đặt.')),
                  );
                }
              },
              child: const Text('Mở cài đặt ứng dụng'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đã xong, quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

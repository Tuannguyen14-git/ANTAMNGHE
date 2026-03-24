import 'package:flutter/material.dart';
import 'package:antamnghe_app/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: AppTheme.darkSurface,
        foregroundColor: AppTheme.darkOnSurfaceText,
      ),
      backgroundColor: AppTheme.darkSurface,
      body: const Center(
        child: Text(
          'Chưa có thông báo nào.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

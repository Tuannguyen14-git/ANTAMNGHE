import 'package:flutter/material.dart';

class ProfileViewersScreen extends StatelessWidget {
  const ProfileViewersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for now
    final List<Map<String, String>> viewers = [
      {'name': 'Nguyễn Văn A', 'time': '2 phút trước'},
      {'name': 'Trần Thị B', 'time': '10 phút trước'},
      {'name': 'Lê Văn C', 'time': '1 giờ trước'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ai đã xem hồ sơ của tôi'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF181820),
      body: viewers.isEmpty
          ? const Center(
              child: Text(
                'Chưa có ai xem hồ sơ của bạn.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewers.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final viewer = viewers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  title: Text(
                    viewer['name'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    viewer['time'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                );
              },
            ),
    );
  }
}

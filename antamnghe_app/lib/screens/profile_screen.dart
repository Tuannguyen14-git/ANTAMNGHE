import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/avatar_badge.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _checkAndLoadUser();
    _loadAvatarImage();
  }

  Future<void> _loadAvatarImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatar_image');
    if (path != null && path.isNotEmpty && mounted) {
      setState(() {
        _avatarImage = File(path);
      });
    }
  }

  Future<void> _pickAvatarImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _avatarImage = File(picked.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_image', picked.path);
    }
  }

  bool _showProfileDetails = false;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _loading = true;

  Future<void> _checkAndLoadUser() async {
    final user = await AuthService.instance.currentUser();
    if (!mounted) return;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    _name.text = user['name'] ?? '';
    _phone.text = user['phone'] ?? '';
    _email.text = user['email'] ?? '';
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Hoàn thành',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      _avatarImage != null
                          ? CircleAvatar(
                              radius: 48,
                              backgroundImage: FileImage(_avatarImage!),
                            )
                          : AvatarBadge(initials: 'MN', size: 96),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAvatarImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name.text,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _phone.text,
                          style: const TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Chỉnh sửa'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _Section(
                title: 'Cài đặt',
                children: [
                  _Tile(
                    text: 'Xem Hồ sơ',
                    icon: Icons.remove_red_eye,
                    onTap: () {
                      setState(() {
                        _showProfileDetails = !_showProfileDetails;
                      });
                    },
                  ),
                ],
              ),

              _Section(
                title: 'Cài đặt chi tiết',
                children: [
                  _Tile(
                    text: 'Trung tâm Quyền riêng tư',
                    icon: Icons.privacy_tip,
                  ),
                  _Tile(text: 'Thông báo', icon: Icons.notifications),
                  _Tile(text: 'Thay đổi Ngôn ngữ', icon: Icons.language),
                ],
              ),

              const SizedBox(height: 12),

              if (_showProfileDetails) ...[
                const Text(
                  'Hồ sơ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _name,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

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

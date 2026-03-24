import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _avatarImage;
  bool _showProfileDetails = true;
  bool _isEditing = false;
  bool _loading = true;
  bool _saving = false;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadAvatarImage();
    await _checkAndLoadUser();
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

  Future<void> _checkAndLoadUser() async {
    final localUser = await AuthService.instance.currentUser();
    if (!mounted) return;

    if (localUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _applyUser(localUser);
    setState(() => _loading = false);

    try {
      final remoteUser = await AuthService.instance.fetchProfile();
      if (!mounted) return;
      setState(() {
        _applyUser(remoteUser);
      });
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('Unauthorized')) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đồng bộ hồ sơ từ máy chủ.')),
      );
    }
  }

  void _applyUser(Map<String, dynamic> user) {
    _name.text = (user['name'] ?? '').toString();
    _phone.text = (user['phone'] ?? '').toString();
    _email.text = (user['email'] ?? '').toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _showProfileDetails = true);
      return;
    }

    setState(() => _saving = true);
    try {
      final updatedUser = await AuthService.instance.updateProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _applyUser(updatedUser);
        _isEditing = false;
        _showProfileDetails = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().contains('Conflict')
          ? 'Số điện thoại này đã được sử dụng.'
          : e.toString().contains('Unauthorized')
          ? 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'
          : 'Không thể cập nhật hồ sơ.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      if (e.toString().contains('Unauthorized')) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancelEditing() async {
    final user = await AuthService.instance.currentUser();
    if (user != null && mounted) {
      setState(() {
        _applyUser(user);
        _isEditing = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Tài khoản'),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : _isEditing
                ? _saveProfile
                : () => Navigator.of(context).maybePop(),
            child: Text(
              _isEditing ? 'Lưu' : 'Hoàn thành',
              style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 28),
              _Section(
                title: '',
                children: [
                  _Tile(
                    text: _showProfileDetails ? 'Ẩn Hồ sơ' : 'Xem Hồ sơ',
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
                title: 'Cài đặt',
                children: [
                  _Tile(
                    text: 'Trung tâm Quyền riêng tư',
                    icon: Icons.privacy_tip,
                    onTap: () => Navigator.pushNamed(context, '/privacy-center'),
                  ),
                  const _Tile(text: 'Thông báo', icon: Icons.notifications),
                  const _Tile(text: 'Thay đổi Ngôn ngữ', icon: Icons.language),
                ],
              ),
              _Section(
                title: 'Tài khoản',
                children: [
                  _Tile(
                    text: _isEditing ? 'Đang chỉnh sửa hồ sơ' : 'Chỉnh sửa hồ sơ',
                    icon: Icons.edit_outlined,
                    onTap: () {
                      setState(() {
                        _showProfileDetails = true;
                        _isEditing = true;
                      });
                    },
                  ),
                  _Tile(
                    text: 'Đăng xuất',
                    icon: Icons.logout,
                    iconColor: const Color(0xFFD92D20),
                    onTap: _logout,
                  ),
                ],
              ),
              if (_showProfileDetails) ...[
                const SizedBox(height: 8),
                Text(
                  'Hồ sơ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textTitle,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProfileCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            _avatarImage != null
                ? Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(_avatarImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppTheme.avatarBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _pickAvatarImage,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: Colors.white,
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
                _name.text.isNotEmpty ? _name.text : 'Người dùng',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textTitle,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _phone.text,
                style: const TextStyle(
                  color: AppTheme.textBody,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_email.text.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _email.text,
                  style: const TextStyle(
                    color: AppTheme.textBody,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 44,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _showProfileDetails = true;
                _isEditing = true;
              });
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              foregroundColor: AppTheme.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: const Text('Chỉnh sửa'),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Chỉnh sửa thông tin' : 'Thông tin cá nhân',
            style: const TextStyle(
              color: AppTheme.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _name,
            label: 'Tên hiển thị',
            hint: 'Nhập tên hiển thị',
            readOnly: !_isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phone,
            label: 'Số điện thoại',
            hint: 'Nhập số điện thoại',
            readOnly: !_isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _email,
            label: 'Email',
            hint: 'Nhập email',
            readOnly: !_isEditing,
            keyboardType: TextInputType.emailAddress,
          ),
          if (_isEditing) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _cancelEditing,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textTitle,
                      side: const BorderSide(color: Color(0xFFD7DEE8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(_saving ? 'Đang lưu...' : 'Lưu thay đổi'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool readOnly,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        color: AppTheme.textTitle,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: readOnly
            ? const Color(0xFFF8FAFC)
            : const Color(0xFFF1F5F9),
        labelStyle: const TextStyle(
          color: AppTheme.textBody,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: AppTheme.placeholder),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: readOnly
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFD7DEE8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
        if (title.isNotEmpty) ...[
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textTitle,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                offset: Offset(0, 6),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _Tile({
    required this.text,
    required this.icon,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? AppTheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: text != 'Đăng xuất' ? const Color(0xFFF1F5F9) : Colors.transparent,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: resolvedIconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: AppTheme.textTitle,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.arrowColor),
            ],
          ),
        ),
      ),
    );
  }
}

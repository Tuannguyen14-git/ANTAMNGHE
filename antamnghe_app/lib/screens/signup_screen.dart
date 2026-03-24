import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    nameController.dispose();
    emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (phone.isEmpty || password.isEmpty || name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        phone,
        password,
        name: name,
        email: email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      final msg =
          e.toString().contains('409') || e.toString().contains('Conflict')
          ? 'Số điện thoại đã tồn tại, vui lòng đăng nhập!'
          : 'Lỗi đăng ký: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8FAFC);
    const cardShadow = Color(0x140F172A);
    const fieldBackground = Color(0xFFF1F5F9);
    const fieldBorder = Color(0xFFD7DEE8);
    const focusColor = Color(0xFFE63946);
    const titleColor = Color(0xFF0F172A);
    const bodyColor = Color(0xFF334155);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        title: const Text(
          'Đăng Ký',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: cardShadow,
                        blurRadius: 32,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'Tạo tài khoản mới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Điền đầy đủ thông tin để tạo tài khoản và bắt đầu sử dụng.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: bodyColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInputField(
                        controller: nameController,
                        focusNode: _nameFocus,
                        label: 'Họ tên',
                        hintText: 'Nhập họ tên',
                        icon: Icons.person,
                        fieldBackground: fieldBackground,
                        fieldBorder: fieldBorder,
                        focusColor: focusColor,
                        titleColor: titleColor,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _emailFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: emailController,
                        focusNode: _emailFocus,
                        label: 'Email',
                        hintText: 'Nhập email',
                        icon: Icons.email,
                        fieldBackground: fieldBackground,
                        fieldBorder: fieldBorder,
                        focusColor: focusColor,
                        titleColor: titleColor,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _phoneFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: phoneController,
                        focusNode: _phoneFocus,
                        label: 'Số điện thoại',
                        hintText: 'Nhập số điện thoại',
                        icon: Icons.phone,
                        fieldBackground: fieldBackground,
                        fieldBorder: fieldBorder,
                        focusColor: focusColor,
                        titleColor: titleColor,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: passwordController,
                        focusNode: _passwordFocus,
                        label: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        icon: Icons.lock,
                        fieldBackground: fieldBackground,
                        fieldBorder: fieldBorder,
                        focusColor: focusColor,
                        titleColor: titleColor,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _register(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: bodyColor,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33E11D48),
                                blurRadius: 18,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: Text(_loading ? 'Đang xử lý...' : 'Đăng Ký'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    required Color fieldBackground,
    required Color fieldBorder,
    required Color focusColor,
    required Color titleColor,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final isFocused = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isFocused
                ? const [
                    BoxShadow(
                      color: Color(0x1FE63946),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onSubmitted: onSubmitted,
            style: TextStyle(
              color: titleColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              filled: true,
              fillColor: fieldBackground,
              prefixIcon: Icon(icon, color: titleColor.withOpacity(0.75)),
              suffixIcon: suffixIcon,
              labelStyle: TextStyle(
                color: isFocused ? focusColor : titleColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: fieldBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: focusColor, width: 1.5),
              ),
            ),
          ),
        );
      },
    );
  }
}

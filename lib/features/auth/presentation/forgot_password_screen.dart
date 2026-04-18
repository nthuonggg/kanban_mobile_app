import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/widgets/glass.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[700],
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Vui lòng nhập email';
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Email không hợp lệ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: GlassContainer(
            borderRadius: 24,
            blur: 28,
            opacity: 0.92,
            padding: const EdgeInsets.all(24),
            child: _sent ? _buildSuccess() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: GlassPalette.primaryContainer.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.lock_reset,
            size: 32,
            color: GlassPalette.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: GlassPalette.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Nhập email tài khoản. Chúng tôi sẽ gửi đường dẫn '
          'để đặt lại mật khẩu cho bạn.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: GlassPalette.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: _validateEmail,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GlassButton(
          primary: true,
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text('Gửi email đặt lại'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.check_circle, size: 36, color: Colors.green[700]),
        ),
        const SizedBox(height: 16),
        const Text(
          'Đã gửi email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            color: GlassPalette.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Kiểm tra hộp thư của ${_emailCtrl.text.trim()} '
          '(và mục Spam nếu không thấy). Nhấn vào đường dẫn '
          'trong email để đặt lại mật khẩu.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: GlassPalette.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        GlassButton(
          primary: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Quay lại đăng nhập'),
        ),
      ],
    );
  }
}

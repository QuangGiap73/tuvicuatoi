import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/mystic_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});
  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  int _passwordStrength = -1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;
    return AuthLayout(
      onClose: () => context.go(AppRoute.welcome),
      title: 'Đăng ký ',
      accentTitle: 'nhanh',
      subtitle:
          'Chỉ mất 5 giây để tạo tài khoản và lưu trữ lá số không giới hạn',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthSwitcher(
                isLogin: false,
                onLogin: isLoading ? null : () => context.go(AppRoute.login),
                onRegister: null,
              ),
              const SizedBox(height: 13),
              GoogleAuthButton(onPressed: isLoading ? null : _signInWithGoogle),
              const SizedBox(height: 12),
              const AuthDivider(),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _nameController,
                label: 'Họ và tên',
                hint: 'Ví dụ: Nguyễn Văn An',
                icon: Icons.person_outline,
                required: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: _required,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _emailController,
                label: 'Địa chỉ email',
                hint: 'tenban@gmail.com',
                icon: Icons.email_outlined,
                required: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.newUsername,
                  AutofillHints.email,
                ],
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Tối thiểu 8 ký tự',
                icon: Icons.lock_outline,
                required: true,
                textInputAction: TextInputAction.next,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.newPassword],
                validator: _passwordValidator,
                onChanged: _updatePasswordStrength,
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              if (_passwordStrength >= 0) ...[
                const SizedBox(height: 7),
                _PasswordStrength(value: _passwordStrength),
              ],
              const SizedBox(height: 14),
              AuthTextField(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                icon: Icons.lock_outline,
                required: true,
                textInputAction: TextInputAction.done,
                obscureText: _obscureConfirmation,
                autofillHints: const [AutofillHints.newPassword],
                validator: _confirmPasswordValidator,
                suffixIcon: IconButton(
                  tooltip: _obscureConfirmation
                      ? 'Hiện mật khẩu'
                      : 'Ẩn mật khẩu',
                  onPressed: () => setState(
                    () => _obscureConfirmation = !_obscureConfirmation,
                  ),
                  icon: Icon(
                    _obscureConfirmation
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              if (auth.hasError) ...[
                const SizedBox(height: 12),
                Text(
                  auth.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: MysticColors.error),
                ),
              ],
              const SizedBox(height: 22),
              AuthPrimaryButton(
                label: isLoading
                    ? 'Đang khởi tạo...'
                    : 'Đăng ký & đăng nhập ngay',
                onPressed: isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty
      ? 'Vui lòng nhập thông tin này'
      : null;
  String? _emailValidator(String? value) {
    if (_required(value) case final error?) return error;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())
        ? null
        : 'Email chưa đúng định dạng';
  }

  String? _passwordValidator(String? value) {
    if (_required(value) case final error?) return error;
    return value!.length >= 8 ? null : 'Mật khẩu cần ít nhất 8 ký tự';
  }

  String? _confirmPasswordValidator(String? value) {
    if (_required(value) case final error?) return error;
    return value == _passwordController.text
        ? null
        : 'Mật khẩu xác nhận chưa khớp';
  }

  void _updatePasswordStrength(String value) {
    if (value.isEmpty) {
      if (_passwordStrength != -1) setState(() => _passwordStrength = -1);
      return;
    }
    var score = 0;
    if (value.length >= 8) score++;
    if (RegExp('[A-Z]').hasMatch(value)) score++;
    if (RegExp('[0-9]').hasMatch(value)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
    if (score != _passwordStrength) setState(() => _passwordStrength = score);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() =>
      ref.read(authControllerProvider.notifier).loginWithGoogle();
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final color = switch (value) {
      0 || 1 => const Color(0xFFFF4055),
      2 => const Color(0xFFFFA726),
      3 => const Color(0xFFE0B52D),
      _ => const Color(0xFF45C486),
    };
    final label = switch (value) {
      0 || 1 => 'Yếu',
      2 => 'Trung bình',
      3 => 'Khá',
      _ => 'Mạnh',
    };
    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < 3; index++) ...[
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: index < value.clamp(1, 3)
                        ? color
                        : const Color(0xFF394158),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (index < 2) const SizedBox(width: 4),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Độ mạnh mật khẩu:',
              style: TextStyle(color: Color(0xFF8C92A0), fontSize: 9),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label (Cần dài hơn hoặc thêm chữ hoa/số)',
                textAlign: TextAlign.end,
                style: TextStyle(color: color, fontSize: 9),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

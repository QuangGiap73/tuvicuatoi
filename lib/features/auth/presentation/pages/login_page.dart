import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/mystic_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;
    return AuthLayout(
      onClose: () => context.go(AppRoute.welcome),
      title: 'Đăng nhập ',
      accentTitle: 'tài khoản',
      subtitle: 'Đăng nhập để đồng bộ lá số và nhận lời luận giải từ AI',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthSwitcher(
                isLogin: true,
                onLogin: null,
                onRegister: isLoading
                    ? null
                    : () => context.go(AppRoute.register),
              ),
              const SizedBox(height: 13),
              GoogleAuthButton(onPressed: isLoading ? null : _signInWithGoogle),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : _signInWithGoogle,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE0B52D),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Đổi hoặc chọn tài khoản Google khác'),
              ),
              const AuthDivider(),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _emailController,
                label: 'Email hoặc tên đăng nhập',
                hint: "Email hoặc 'admin'",
                icon: Icons.mail_outline,
                required: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                validator: _required,
              ),
              const SizedBox(height: 14),
              AuthTextField(
                controller: _passwordController,
                label: 'Mật khẩu',
                hint: 'Nhập mật khẩu (Ví dụ: admin)',
                icon: Icons.lock_outline,
                required: true,
                textInputAction: TextInputAction.done,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                validator: _required,
                trailingLabel: TextButton(
                  onPressed: isLoading ? null : _showForgotPasswordNotice,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: MysticColors.paleGold,
                    textStyle: const TextStyle(
                      fontSize: 10,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  child: const Text('Quên mật khẩu?'),
                ),
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
                label: isLoading ? 'Đang đăng nhập...' : 'Đăng nhập ngay',
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() =>
      ref.read(authControllerProvider.notifier).loginWithGoogle();

  void _showForgotPasswordNotice() =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Luồng quên mật khẩu và OTP sẽ được triển khai ở bước tiếp theo.',
          ),
        ),
      );
}

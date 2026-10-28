import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/mystic_colors.dart';
import '../controllers/forgot_password_controller.dart';
import '../state/forgot_password_state.dart';
import '../widgets/auth_layout.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({this.initialEmail = '', super.key});

  final String initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordControllerProvider);
    return AuthLayout(
      onClose: () =>
          context.canPop() ? context.pop() : context.go(AppRoute.login),
      title: 'Khôi phục ',
      accentTitle: 'mật khẩu',
      subtitle: _subtitle(state),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIndicator(step: state.step),
            const SizedBox(height: 18),
            ..._fieldsFor(state),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MysticColors.error),
              ),
            ],
            const SizedBox(height: 20),
            AuthPrimaryButton(
              label: state.isSubmitting ? 'Đang xử lý...' : _buttonLabel(state),
              onPressed: state.isSubmitting ? null : () => _submit(state),
            ),
            if (state.step != ForgotPasswordStep.email) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => ref
                          .read(forgotPasswordControllerProvider.notifier)
                          .back(),
                child: const Text('Quay lại bước trước'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _fieldsFor(ForgotPasswordState state) => switch (state.step) {
    ForgotPasswordStep.email => [
      AuthTextField(
        controller: _emailController,
        label: 'Email đăng ký',
        hint: 'Nhập email tài khoản của bạn',
        icon: Icons.mail_outline_rounded,
        required: true,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        validator: _emailValidator,
      ),
    ],
    ForgotPasswordStep.otp => [
      AuthTextField(
        controller: _otpController,
        label: 'Mã OTP 6 số',
        hint: 'Nhập mã được gửi tới ${state.email}',
        icon: Icons.verified_user_outlined,
        required: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        validator: (value) => RegExp(r'^\d{6}$').hasMatch(value ?? '')
            ? null
            : 'Vui lòng nhập đúng mã OTP 6 số',
      ),
      if (state.expiresInMinutes != null) ...[
        const SizedBox(height: 10),
        Text(
          'Mã có hiệu lực trong ${state.expiresInMinutes} phút.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF9EA4B3), fontSize: 11),
        ),
      ],
    ],
    ForgotPasswordStep.newPassword => [
      AuthTextField(
        controller: _passwordController,
        label: 'Mật khẩu mới',
        hint: 'Tối thiểu 8 ký tự',
        icon: Icons.lock_outline_rounded,
        required: true,
        obscureText: _obscure,
        textInputAction: TextInputAction.next,
        validator: (value) =>
            (value?.length ?? 0) < 8 ? 'Mật khẩu cần ít nhất 8 ký tự' : null,
        suffixIcon: _visibilityButton(),
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _confirmController,
        label: 'Nhập lại mật khẩu mới',
        hint: 'Nhập lại mật khẩu',
        icon: Icons.lock_reset_rounded,
        required: true,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        validator: (value) => value == _passwordController.text
            ? null
            : 'Mật khẩu xác nhận chưa khớp',
        suffixIcon: _visibilityButton(),
      ),
    ],
  };

  Widget _visibilityButton() => IconButton(
    onPressed: () => setState(() => _obscure = !_obscure),
    icon: Icon(
      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    ),
  );

  String _subtitle(ForgotPasswordState state) => switch (state.step) {
    ForgotPasswordStep.email => 'Nhập email để nhận mã OTP bảo mật từ hệ thống',
    ForgotPasswordStep.otp => 'Kiểm tra email và nhập mã xác thực 6 số',
    ForgotPasswordStep.newPassword => 'Tạo mật khẩu mới cho tài khoản của bạn',
  };

  String _buttonLabel(ForgotPasswordState state) => switch (state.step) {
    ForgotPasswordStep.email => 'Gửi mã xác thực',
    ForgotPasswordStep.otp => 'Xác minh mã OTP',
    ForgotPasswordStep.newPassword => 'Đặt lại mật khẩu',
  };

  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Email chưa hợp lệ';
  }

  Future<void> _submit(ForgotPasswordState state) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final controller = ref.read(forgotPasswordControllerProvider.notifier);
    final success = switch (state.step) {
      ForgotPasswordStep.email => await controller.sendCode(
        _emailController.text,
      ),
      ForgotPasswordStep.otp => await controller.verifyCode(
        _otpController.text,
      ),
      ForgotPasswordStep.newPassword => await controller.resetPassword(
        _passwordController.text,
      ),
    };
    if (!mounted || !success || state.step != ForgotPasswordStep.newPassword) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoute.login);
    }
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Đặt lại mật khẩu thành công. Bạn có thể đăng nhập ngay.',
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});
  final ForgotPasswordStep step;

  @override
  Widget build(BuildContext context) {
    final active = step.index;
    return Row(
      children: [
        for (var index = 0; index < 3; index++) ...[
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index <= active
                  ? MysticColors.gold
                  : const Color(0xFF252D42),
              border: Border.all(color: MysticColors.gold),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: index <= active
                    ? const Color(0xFF171109)
                    : MysticColors.paleGold,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          if (index < 2)
            Expanded(
              child: Container(
                height: 1,
                color: index < active
                    ? MysticColors.gold
                    : const Color(0xFF3C4357),
              ),
            ),
        ],
      ],
    );
  }
}

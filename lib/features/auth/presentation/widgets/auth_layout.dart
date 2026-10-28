import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../../core/theme/mystic_colors.dart';

const _cardColor = Color(0xFF10182D);
const _fieldColor = Color(0xFF090F20);
const _mutedText = Color(0xFF9EA4B3);
const _borderColor = Color(0xFF3C4357);

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.accentTitle,
    required this.subtitle,
    required this.child,
    required this.onClose,
    super.key,
  });

  final String title;
  final String accentTitle;
  final String subtitle;
  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    resizeToAvoidBottomInset: true,
    body: _AuthBackdrop(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              13,
              28,
              13,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 52,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: MysticColors.gold.withValues(alpha: .72),
                        width: 1.25,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MysticColors.gold.withValues(alpha: .09),
                          blurRadius: 28,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 18, 15, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const _MemberBadge(),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Quay lại',
                                  onPressed: onClose,
                                  icon: const Icon(
                                    Icons.close,
                                    color: MysticColors.paleGold,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: title),
                                TextSpan(
                                  text: accentTitle,
                                  style: const TextStyle(
                                    color: MysticColors.paleGold,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFF4F0E7),
                              fontFamily: 'serif',
                              fontSize: 25,
                              height: 1.15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          child,
                          const SizedBox(height: 14),
                          const Text(
                            'Bảo mật thông tin 100% theo tiêu chuẩn mã hóa SSL.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF8C92A0),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cacheWidth = (mediaQuery.size.width * mediaQuery.devicePixelRatio)
        .round();

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF020305)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ImageFiltered only processes this static image. It is cheaper than
          // applying BackdropFilter over the scrolling authentication form.
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Transform.scale(
              scale: 1.04,
              child: Image.asset(
                MysticAssets.welcomeBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.low,
              ),
            ),
          ),
          const ColoredBox(color: Color(0xA6000000)),
          const Align(
            alignment: Alignment(0, -.65),
            child: SizedBox.square(
              dimension: 360,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x182C4268), Color(0x00000000)],
                    stops: [0, 1],
                  ),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment(.7, .85),
            child: SizedBox.square(
              dimension: 260,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0x122E2207), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge();
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: const Color(0xFF17213B),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: MysticColors.gold.withValues(alpha: .32)),
    ),
    child: const Padding(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: MysticColors.paleGold, size: 13),
          SizedBox(width: 6),
          Text(
            'TỬ VI THÀNH VIÊN',
            style: TextStyle(
              color: MysticColors.paleGold,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.35,
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthSwitcher extends StatelessWidget {
  const AuthSwitcher({
    required this.isLogin,
    required this.onLogin,
    required this.onRegister,
    super.key,
  });
  final bool isLogin;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  @override
  Widget build(BuildContext context) => Container(
    height: 39,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: _fieldColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _borderColor),
    ),
    child: Row(
      children: [
        Expanded(
          child: _SwitchItem(
            label: 'Đăng Nhập',
            selected: isLogin,
            onTap: onLogin,
          ),
        ),
        Expanded(
          child: _SwitchItem(
            label: 'Đăng Ký Nhanh',
            selected: !isLogin,
            onTap: onRegister,
          ),
        ),
      ],
    ),
  );
}

class _SwitchItem extends StatelessWidget {
  const _SwitchItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? MysticColors.gold : Colors.transparent,
    borderRadius: BorderRadius.circular(15),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFFAAA59B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({required this.onPressed, super.key});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(42),
      foregroundColor: const Color(0xFFD8DBE3),
      side: const BorderSide(color: _borderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: 12),
        Flexible(
          child: Text(
            'Tiếp tục sử dụng dịch vụ bằng Google',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: _borderColor)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'HOẶC DÙNG EMAIL',
          style: TextStyle(color: _mutedText, fontSize: 9, letterSpacing: .9),
        ),
      ),
      Expanded(child: Divider(color: _borderColor)),
    ],
  );
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.required = false,
    this.trailingLabel,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    super.key,
  });
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool required, obscureText;
  final Widget? trailingLabel, suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: MysticColors.paleGold,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: .55,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: Color(0xFFE76C62), fontSize: 11),
            ),
          const Spacer(),
          ?trailingLabel,
        ],
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        validator: validator,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Color(0xFFE5E8EF), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF657087), fontSize: 14),
          prefixIcon: Icon(icon, color: MysticColors.paleGold, size: 18),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: _fieldColor,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MysticColors.gold, width: 1.2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MysticColors.error),
          ),
        ),
      ),
    ],
  );
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: onPressed == null
            ? const [Color(0xFF69614B), Color(0xFF7A6A3A)]
            : const [Color(0xFF8D6700), Color(0xFFE0B52D), Color(0xFFC4941A)],
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: MysticColors.gold.withValues(alpha: .22),
          blurRadius: 16,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.transparent,
        disabledBackgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
        ],
      ),
    ),
  );
}

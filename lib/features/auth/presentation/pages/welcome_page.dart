import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/assets/mystic_assets.dart';
import '../../../../core/theme/mystic_colors.dart';
import '../controllers/auth_controller.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isLoading = auth.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final pixelRatio = MediaQuery.devicePixelRatioOf(context);
          final cacheWidth = (constraints.maxWidth * pixelRatio).round();
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                MysticAssets.welcomeBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.transparent, Color(0xA6000000), Color(0xE8000000)],
                    stops: [0, .56, .76, 1],
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 410),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        if (auth.hasError) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(color: const Color(0xCC241014), borderRadius: BorderRadius.circular(12)),
                            child: Text(auth.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: MysticColors.error, fontSize: 11)),
                          ),
                        ],
                        _WelcomeButton.primary(
                          label: 'Đăng nhập',
                          onPressed: isLoading ? null : () => context.go(AppRoute.login),
                        ),
                        const SizedBox(height: 11),
                        _WelcomeButton.outlined(
                          label: 'Đăng ký nhanh',
                          onPressed: isLoading ? null : () => context.go(AppRoute.register),
                        ),
                        const SizedBox(height: 11),
                        _GoogleWelcomeButton(
                          isLoading: isLoading,
                          onPressed: isLoading ? null : () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
                        ),
                        const SizedBox(height: 25),
                        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.cloud_done_outlined, size: 13, color: Color(0xFFC9B77B)),
                          SizedBox(width: 6),
                          Text('Đồng bộ lá số trên mọi thiết bị', style: TextStyle(color: Color(0xFFC7C2B4), fontSize: 10.5, letterSpacing: .1)),
                        ]),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton._({required this.label, required this.onPressed, required this.primary});
  factory _WelcomeButton.primary({required String label, required VoidCallback? onPressed}) => _WelcomeButton._(label: label, onPressed: onPressed, primary: true);
  factory _WelcomeButton.outlined({required String label, required VoidCallback? onPressed}) => _WelcomeButton._(label: label, onPressed: onPressed, primary: false);

  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: primary ? const LinearGradient(colors: [Color(0xFF8C6600), Color(0xFFE1B62E), Color(0xFFB7830C)]) : null,
      color: primary ? null : const Color(0xB20A0D12),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(color: primary ? const Color(0xFFE4C35B) : const Color(0xFF8D7536), width: 1),
      boxShadow: primary ? const [BoxShadow(color: Color(0x558E6A05), blurRadius: 16, offset: Offset(0, 5))] : null,
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(49),
        foregroundColor: primary ? const Color(0xFF1B1608) : const Color(0xFFF3EEDC),
        disabledForegroundColor: const Color(0xFF77736A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    ),
  );
}

class _GoogleWelcomeButton extends StatelessWidget {
  const _GoogleWelcomeButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(49),
      foregroundColor: const Color(0xFFF1EEE4),
      backgroundColor: const Color(0xD90A0D12),
      side: const BorderSide(color: Color(0xFF8D7536)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 19, fontWeight: FontWeight.w900)),
      const SizedBox(width: 12),
      Text(isLoading ? 'Đang kết nối...' : 'Tiếp tục với Google'),
    ]),
  );
}

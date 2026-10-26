import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/mystic_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class GlobalAiChatLauncher extends ConsumerStatefulWidget {
  const GlobalAiChatLauncher({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<GlobalAiChatLauncher> createState() =>
      _GlobalAiChatLauncherState();
}

class _GlobalAiChatLauncherState extends ConsumerState<GlobalAiChatLauncher>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _launcherSize = Size(122, 55);
  static const _edgeMargin = 7.0;

  late final AnimationController _pulseController;
  bool _reduceMotion = false;
  bool _authenticated = false;
  Offset? _position;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    ref.listenManual(
      authControllerProvider.select((state) => state.asData?.value != null),
      (_, authenticated) {
        _authenticated = authenticated;
        if (authenticated && !_reduceMotion) {
          _pulseController.repeat();
        } else {
          _pulseController.stop();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) {
      if (_authenticated && !_reduceMotion && !_pulseController.isAnimating) {
        _pulseController.repeat();
      }
      return;
    }
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _pulseController
        ..stop()
        ..value = 0;
    } else if (_authenticated) {
      _pulseController.repeat();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_reduceMotion) return;
    if (state == AppLifecycleState.resumed && _authenticated) {
      _pulseController.repeat();
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(
      authControllerProvider.select((state) => state.asData?.value != null),
    );
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final router = ref.watch(appRouterProvider);

    return ListenableBuilder(
      listenable: router.routeInformationProvider,
      builder: (context, _) {
        final hideOnPalaceDetail = router
            .routeInformationProvider
            .value
            .uri
            .path
            .contains('palace-detail');
        return LayoutBuilder(
          builder: (context, constraints) {
            final minX = _edgeMargin;
            final maxX = math.max(
              minX,
              constraints.maxWidth - _launcherSize.width - _edgeMargin,
            );
            final minY = media.padding.top + _edgeMargin;
            final maxY = math.max(
              minY,
              constraints.maxHeight -
                  _launcherSize.height -
                  media.padding.bottom -
                  84,
            );
            final defaultPosition = Offset(maxX, maxY);
            final rawPosition = _position ?? defaultPosition;
            final position = Offset(
              rawPosition.dx.clamp(minX, maxX),
              rawPosition.dy.clamp(minY, maxY),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                widget.child,
                if (isAuthenticated && !keyboardOpen && !hideOnPalaceDetail)
                  Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onPanUpdate: (details) {
                        final current = _position ?? position;
                        setState(() {
                          _position = Offset(
                            (current.dx + details.delta.dx).clamp(minX, maxX),
                            (current.dy + details.delta.dy).clamp(minY, maxY),
                          );
                        });
                      },
                      onDoubleTap: () =>
                          setState(() => _position = defaultPosition),
                      child: RepaintBoundary(
                        child: Semantics(
                          button: true,
                          label:
                              'Mở trợ lý Chat AI, cố vấn 24 trên 7. Có thể kéo để di chuyển.',
                          child: _ChatAiPill(
                            pulse: _pulseController,
                            onTap: () => _openChat(isAuthenticated),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _openChat(bool isAuthenticated) {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để trò chuyện cùng Tử Vi AI.'),
        ),
      );
      ref.read(appRouterProvider).go(AppRoute.login);
      return;
    }
    ref.read(appRouterProvider).go(AppRoute.chat);
  }
}

class _ChatAiPill extends StatelessWidget {
  const _ChatAiPill({required this.pulse, required this.onTap});

  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: pulse,
    builder: (context, child) {
      final wave = Curves.easeInOut.transform(pulse.value);
      return CustomPaint(
        painter: _ChatGlowPainter(progress: wave),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            child!,
            Positioned(
              right: -3,
              top: -5,
              child: Transform.scale(
                scale: .82 + wave * .18,
                child: Opacity(
                  opacity: .5 + wave * .5,
                  child: const _OnlineDot(),
                ),
              ),
            ),
          ],
        ),
      );
    },
    child: Material(
      color: const Color(0xFF51401C),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 122,
          height: 55,
          padding: const EdgeInsets.fromLTRB(8, 5, 9, 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF695520), Color(0xFF3A2D14)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFC99A2B), width: 1.2),
          ),
          child: const Row(
            children: [
              _ChatMark(),
              SizedBox(width: 7),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Chat AI',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: Color(0xFFFFF4CF),
                              fontFamily: 'serif',
                              fontSize: 14,
                              height: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.auto_awesome,
                            color: MysticColors.paleGold,
                            size: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Cố Vấn 24/7',
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFFD9C98E),
                        fontSize: 9.5,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ChatMark extends StatelessWidget {
  const _ChatMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF79642B),
      border: Border.all(color: const Color(0xFFAD914B)),
      boxShadow: const [BoxShadow(color: Color(0x55E5BA45), blurRadius: 8)],
    ),
    child: const Text(
      '@',
      style: TextStyle(
        color: Color(0xFFFFE6A3),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 14,
    height: 14,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF25D79A),
      border: Border.all(color: const Color(0xFFD7FFF2), width: 1.8),
      boxShadow: const [
        BoxShadow(color: Color(0xDD19D69B), blurRadius: 9, spreadRadius: 1),
      ],
    ),
  );
}

class _ChatGlowPainter extends CustomPainter {
  const _ChatGlowPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MysticColors.gold.withValues(alpha: .08 + progress * .1)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + progress * 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          -2 - progress * 2,
          -2,
          size.width + 4 + progress * 3,
          size.height + 4,
        ),
        const Radius.circular(30),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ChatGlowPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

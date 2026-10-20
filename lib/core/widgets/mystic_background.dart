import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';

class MysticBackground extends StatelessWidget {
  const MysticBackground({required this.child, this.decoration, super.key});
  final Widget child;
  final Widget? decoration;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(0, -.55),
        radius: 1.18,
        colors: [
          MysticColors.jade,
          MysticColors.deepOcean,
          MysticColors.midnight,
        ],
        stops: [0, .46, 1],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: _StarPattern()),
        if (decoration != null) RepaintBoundary(child: decoration!),
        child,
      ],
    ),
  );
}

class _StarPattern extends StatelessWidget {
  const _StarPattern();
  @override
  Widget build(BuildContext context) =>
      const IgnorePointer(child: CustomPaint(painter: _StarPatternPainter()));
}

class _StarPatternPainter extends CustomPainter {
  const _StarPatternPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = MysticColors.paleGold.withValues(alpha: .11);
    const gap = 48.0;
    for (double y = 24; y < size.height; y += gap) {
      final offset = ((y / gap).round().isEven) ? 20.0 : 44.0;
      for (double x = offset; x < size.width; x += gap) {
        canvas.drawCircle(Offset(x, y), .8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarPatternPainter oldDelegate) => false;
}

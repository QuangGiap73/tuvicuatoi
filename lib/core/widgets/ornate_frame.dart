import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';

class OrnateFrame extends StatelessWidget {
  const OrnateFrame({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    super.key,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _OrnateBorderPainter(radius: borderRadius),
    child: Padding(padding: padding, child: child),
  );
}

class _OrnateBorderPainter extends CustomPainter {
  const _OrnateBorderPainter({required this.radius});
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = MysticColors.gold,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(5), Radius.circular(radius - 4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7
        ..color = MysticColors.paleGold.withValues(alpha: .38),
    );
  }

  @override
  bool shouldRepaint(covariant _OrnateBorderPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

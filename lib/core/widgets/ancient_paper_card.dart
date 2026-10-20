import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';

class AncientPaperCard extends StatelessWidget {
  const AncientPaperCard({required this.child, this.padding, super.key});
  final Widget child;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: MysticColors.antiquePaper,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: MysticColors.gold.withValues(alpha: .75)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: MysticColors.ink, height: 1.45),
        child: IconTheme.merge(
          data: const IconThemeData(color: MysticColors.ink),
          child: child,
        ),
      ),
    ),
  );
}

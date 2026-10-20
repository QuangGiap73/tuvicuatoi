import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';

class MysticLoading extends StatelessWidget {
  const MysticLoading({this.label = 'Đang an sao...', super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: MysticColors.gold,
          ),
        ),
        const SizedBox(height: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import '../theme/mystic_colors.dart';
import 'golden_button.dart';
import 'ornate_frame.dart';

class MysticDialog extends StatelessWidget {
  const MysticDialog({
    required this.title,
    required this.content,
    this.confirmLabel = 'Xác nhận',
    this.onConfirm,
    super.key,
  });
  final String title;
  final Widget content;
  final String confirmLabel;
  final VoidCallback? onConfirm;
  static Future<T?> show<T>(BuildContext context, {required Widget dialog}) =>
      showDialog<T>(context: context, builder: (_) => dialog);
  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: MysticColors.deepOcean,
    insetPadding: const EdgeInsets.all(24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: OrnateFrame(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 14),
            content,
            const SizedBox(height: 22),
            GoldenButton(
              label: confirmLabel,
              onPressed: onConfirm ?? () => Navigator.of(context).pop(),
              expanded: true,
            ),
          ],
        ),
      ),
    ),
  );
}

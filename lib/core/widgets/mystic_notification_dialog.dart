import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets/mystic_assets.dart';

class MysticNotificationItem {
  const MysticNotificationItem(
    this.text, {
    this.icon = Icons.check_circle_outline_rounded,
    this.color = const Color(0xFF287B63),
  });

  final String text;
  final IconData icon;
  final Color color;
}

class MysticNotificationDialog extends StatelessWidget {
  const MysticNotificationDialog({
    required this.header,
    required this.title,
    required this.confirmLabel,
    required this.onConfirm,
    this.description,
    this.leading,
    this.priceLabel,
    this.priceText,
    this.priceNote,
    this.items = const [],
    this.extraContent,
    this.cancelLabel = 'Hủy',
    this.onCancel,
    this.isLoading = false,
    super.key,
  });

  final String header;
  final String title;
  final String? description;
  final Widget? leading;
  final String? priceLabel;
  final String? priceText;
  final String? priceNote;
  final List<MysticNotificationItem> items;
  final Widget? extraContent;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback? onCancel;
  final VoidCallback onConfirm;
  final bool isLoading;

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget dialog,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: const Color(0xB3000000),
    builder: (_) => dialog,
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = math.min(size.width - 24, 382.0);
    final naturalHeight = width * 1328 / 1091;
    final height = math.min(naturalHeight, size.height * .84);
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: Image.asset(
                MysticAssets.notificationFrame,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(29, 35, 29, 27),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 35),
                      Expanded(
                        child: Text(
                          header,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF493019),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: isLoading
                            ? null
                            : onCancel ?? () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: const Color(0xFF65482F),
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(5, 5, 5, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (leading != null) ...[
                            Center(child: leading!),
                            const SizedBox(height: 7),
                          ],
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF3F2815),
                              fontFamily: 'serif',
                              fontSize: 20,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (description?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text(
                              description!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF735B40),
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                          if (priceText != null) ...[
                            const Divider(color: Color(0x559A6D31), height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    priceLabel ?? 'Chi phí mở khóa',
                                    style: const TextStyle(
                                      color: Color(0xFF513821),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      priceText!,
                                      style: const TextStyle(
                                        color: Color(0xFF9C2D23),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    if (priceNote != null)
                                      Text(
                                        priceNote!,
                                        style: const TextStyle(
                                          color: Color(0xFF796247),
                                          fontSize: 9.5,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                          if (items.isNotEmpty) ...[
                            const SizedBox(height: 13),
                            for (final item in items)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      item.icon,
                                      color: item.color,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        item.text,
                                        style: const TextStyle(
                                          color: Color(0xFF624E37),
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          if (extraContent != null) ...[
                            const SizedBox(height: 8),
                            extraContent!,
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogButton(
                          label: cancelLabel,
                          onPressed: isLoading
                              ? null
                              : onCancel ?? () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: _DialogButton(
                          label: confirmLabel,
                          emphasized: true,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : onConfirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool emphasized;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: emphasized
          ? const LinearGradient(
              colors: [Color(0xFFD99718), Color(0xFF84510A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : const LinearGradient(
              colors: [Color(0xFFB8A486), Color(0xFF8D7A5D)],
            ),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: emphasized ? const Color(0xFFE5B747) : const Color(0xFF9A876B),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x44000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFFF0C6),
        minimumSize: const Size.fromHeight(45),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: isLoading
          ? const SizedBox.square(
              dimension: 17,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFFE8AA),
              ),
            )
          : FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    ),
  );
}

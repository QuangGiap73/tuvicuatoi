import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';

class MysticProfileSaveButton extends StatelessWidget {
  const MysticProfileSaveButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.icon = Icons.check_rounded,
    super.key,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: isLoading ? 'Đang xử lý' : label,
    child: SizedBox(
      width: double.infinity,
      height: 56,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pixelRatio = MediaQuery.devicePixelRatioOf(context);
          final cacheWidth = (constraints.maxWidth * pixelRatio).round();
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                MysticAssets.bottomFrameA,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 7,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPressed,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 19,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFE7A5),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    color: const Color(0xFFFFF0C2),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    label.toUpperCase(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: Color(0xFFFFF4D7),
                                      fontSize: 14,
                                      height: 1,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: .25,
                                      shadows: [
                                        Shadow(
                                          color: Color(0xCC000000),
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

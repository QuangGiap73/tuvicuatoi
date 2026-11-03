import 'package:flutter/material.dart';

import '../assets/mystic_assets.dart';

class MysticFrameButton extends StatelessWidget {
  const MysticFrameButton({
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.icon,
    this.loading = false,
    this.height = 48,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool selected;
  final IconData? icon;
  final bool loading;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    enabled: onPressed != null,
    label: label,
    child: SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cacheWidth =
              (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                  .round();
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: selected
                      ? const [
                          BoxShadow(color: Color(0x66E7C14D), blurRadius: 6),
                        ]
                      : null,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 170),
                      opacity: selected
                          ? 1
                          : onPressed == null
                          ? .58
                          : .42,
                      child: Image.asset(
                        MysticAssets.bottomFrameB,
                        fit: BoxFit.fill,
                        cacheWidth: cacheWidth,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (loading)
                              const SizedBox.square(
                                dimension: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFFFE7A4),
                                ),
                              )
                            else if (icon != null)
                              Icon(
                                icon,
                                size: 17,
                                color: const Color(0xFFFFD66E),
                              ),
                            if (loading || icon != null)
                              const SizedBox(width: 7),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: selected
                                        ? const Color(0xFFFFE7A4)
                                        : const Color(0xFFC7B891),
                                    fontSize: 11.5,
                                    fontWeight: selected
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

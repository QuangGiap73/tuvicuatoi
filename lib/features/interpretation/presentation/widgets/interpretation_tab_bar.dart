import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/interpretation_models.dart';

class InterpretationTabBar extends StatelessWidget {
  const InterpretationTabBar({
    required this.selectedTab,
    required this.onChanged,
    super.key,
  });

  final InterpretationTab selectedTab;
  final ValueChanged<InterpretationTab> onChanged;

  static const _labels = <InterpretationTab, String>{
    InterpretationTab.overview: 'Tổng quan',
    InterpretationTab.palaces: '12 cung',
    InterpretationTab.fortunes: 'Vận hạn',
    InterpretationTab.guidance: 'Ứng dụng',
  };

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: 'Các phần luận giải',
    child: SizedBox(
      height: 48,
      child: Row(
        children: InterpretationTab.values
            .map(
              (tab) => Expanded(
                child: _TabButton(
                  label: _labels[tab]!,
                  selected: tab == selectedTab,
                  onPressed: tab == selectedTab ? null : () => onChanged(tab),
                ),
              ),
            )
            .toList(growable: false),
      ),
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
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
                      BoxShadow(
                        color: Color(0x88E7C14D),
                        blurRadius: 7,
                        spreadRadius: .3,
                      ),
                      BoxShadow(
                        color: Color(0x5521D8D0),
                        blurRadius: 9,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 170),
                  opacity: selected ? 1 : .42,
                  child: RepaintBoundary(
                    child: Image.asset(
                      MysticAssets.bottomFrameB,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
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
                            Shadow(color: Colors.black, blurRadius: 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

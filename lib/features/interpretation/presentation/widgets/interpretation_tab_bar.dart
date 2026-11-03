import 'package:flutter/material.dart';

import '../../../../core/widgets/mystic_frame_button.dart';
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
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: MysticFrameButton(
      label: label,
      selected: selected,
      onPressed: onPressed,
    ),
  );
}

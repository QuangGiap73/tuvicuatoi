import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/top_up_providers.dart';
import '../state/top_up_state.dart';

class TopUpTabs extends ConsumerWidget {
  const TopUpTabs({required this.selectedTab, super.key});
  final TopUpTab selectedTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xE6081524),
      border: Border.all(color: const Color(0xFF9B7425)),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        _TabButton(
          icon: Icons.monetization_on_rounded,
          label: 'Gói Mua Xu',
          selected: selectedTab == TopUpTab.coins,
          onTap: () => ref
              .read(topUpControllerProvider.notifier)
              .selectTab(TopUpTab.coins),
        ),
        _TabButton(
          icon: Icons.workspace_premium_rounded,
          label: 'Gói Hội Viên',
          selected: selectedTab == TopUpTab.membership,
          onTap: () => ref
              .read(topUpControllerProvider.notifier)
              .selectTab(TopUpTab.membership),
        ),
      ],
    ),
  );
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? const Color(0xFFFFD66B) : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? const Color(0xFF442911) : Colors.white70,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? const Color(0xFF442911) : Colors.white70,
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/mystic_colors.dart';
import '../../core/widgets/mystic_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    MysticNavItem('Trang chủ', Icons.home_outlined, Icons.home_rounded),
    MysticNavItem(
      'Lá số',
      Icons.auto_awesome_outlined,
      Icons.auto_awesome_rounded,
    ),
    MysticNavItem(
      'AI Chat',
      Icons.chat_bubble_outline_rounded,
      Icons.chat_bubble_rounded,
    ),
    MysticNavItem(
      'Ví Xu',
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_rounded,
    ),
    MysticNavItem(
      'Cá nhân',
      Icons.person_outline_rounded,
      Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MysticColors.midnight,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: MysticBottomNav(
        currentIndex: navigationShell.currentIndex,
        showBackgroundThrough: navigationShell.currentIndex == 4,
        items: _items,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

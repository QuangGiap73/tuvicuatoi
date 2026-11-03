import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/mystic_colors.dart';
import '../../core/widgets/mystic_bottom_nav.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/login_required_dialog.dart';
import 'auth_route_policy.dart';

class AppShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: MysticColors.midnight,
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: MysticBottomNav(
        currentIndex: navigationShell.currentIndex,
        showBackgroundThrough: navigationShell.currentIndex == 4,
        items: _items,
        onTap: (index) async {
          final isAuthenticated =
              ref.read(authControllerProvider).asData?.value != null;
          if ((index == 2 || index == 3 || index == 4) && !isAuthenticated) {
            final isChat = index == 2;
            final isWallet = index == 3;
            final shouldLogin = await showLoginRequiredDialog(
              context,
              icon: isChat
                  ? Icons.chat_bubble_outline_rounded
                  : isWallet
                  ? Icons.account_balance_wallet_outlined
                  : Icons.account_circle_outlined,
              message: isChat
                  ? 'Đăng nhập để hỏi Tử Vi AI, sử dụng lá số cá nhân và lưu lại lịch sử trò chuyện.'
                  : isWallet
                  ? 'Đăng nhập để xem số dư Xu, điểm danh, làm nhiệm vụ và quản lý giao dịch của bạn.'
                  : 'Đăng nhập để xem hồ sơ, quản lý lá số đã lưu và đồng bộ dữ liệu của bạn.',
            );
            if (shouldLogin == true && context.mounted) {
              context.push(
                AuthRoutePolicy.loginLocation(
                  isChat
                      ? '/ai-chat'
                      : isWallet
                      ? '/wallet'
                      : '/profile',
                ),
              );
            }
            return;
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

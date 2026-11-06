import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_colors.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../../core/widgets/mystic_notification_dialog.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../../auth/presentation/login_required_dialog.dart';
import '../../../app/router/auth_route_policy.dart';
import 'providers/home_providers.dart';
import 'widgets/home_daily_message_card.dart';
import 'widgets/home_destiny_discovery_card.dart';
import 'widgets/home_featured_grid.dart';
import 'widgets/home_mystic_app_bar.dart';
import 'widgets/home_menu_sheet.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MysticScaffold(
    extendBodyBehindAppBar: true,
    background: Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round()
                    .clamp(1, 854),
            filterQuality: FilterQuality.medium,
          ),
        ),
        const ColoredBox(color: Color(0x58020812)),
      ],
    ),
    appBar: _HomeAppBarConnector(
      onMenuPressed: () => _openMenu(context, ref),
      onWalletPressed: () => _openWallet(context, ref),
      onAddCoinPressed: () => _openWallet(context, ref),
    ),
    body: RefreshIndicator(
      color: MysticColors.gold,
      backgroundColor: MysticColors.midnight,
      onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              MysticSpacing.md,
              0,
              MysticSpacing.md,
              MysticSpacing.md,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                const SliverToBoxAdapter(child: _HomeHeroGreeting()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: MysticSpacing.sm),
                ),
                SliverToBoxAdapter(
                  child: HomeDestinyDiscoveryCard(
                    onPressed: () => context.push(AppRoute.horoscope),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: MysticSpacing.xs),
                ),
                const SliverToBoxAdapter(child: _HomeDailyMessageConnector()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: MysticSpacing.xs),
                ),
                HomeFeaturedGrid(
                  onChartPressed: () => context.push(AppRoute.horoscope),
                  onTodayPressed: () => context.push(AppRoute.dailyFortune),
                  onChatPressed: () => _openChat(context, ref),
                  onArticlesPressed: () => context.push(AppRoute.articles),
                  onViewAllPressed: () => _showComingSoon(context, 'Tính năng'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _showComingSoon(BuildContext context, String feature) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature sẽ được hoàn thiện ở bước tiếp theo.'),
        ),
      );

  Future<void> _openMenu(BuildContext context, WidgetRef ref) {
    final session = ref.read(authControllerProvider).asData?.value;
    final user = session?.user;
    return showHomeMenuSheet(
      context,
      isAuthenticated: user != null,
      userName: user?.fullName ?? '',
      coinBalance: user?.coinBalance ?? 0,
      onLogin: () => context.push(AuthRoutePolicy.loginLocation(AppRoute.home)),
      onProfile: () => _openProtected(
        context,
        ref,
        destination: AppRoute.profile,
        icon: Icons.person_outline_rounded,
        message:
            'Đăng nhập để xem hồ sơ, quyền lợi thành viên và đồng bộ dữ liệu của bạn.',
      ),
      onHoroscope: () => context.push(AppRoute.horoscope),
      onInterpretation: () => context.push(AppRoute.interpretation),
      onDailyFortune: () => context.push(AppRoute.dailyFortune),
      onArticles: () => context.push(AppRoute.articles),
      onWallet: () => _openWallet(context, ref),
      onSavedCharts: () => _openProtected(
        context,
        ref,
        destination: AppRoute.myCharts,
        icon: Icons.history_rounded,
        message: 'Đăng nhập để xem và quản lý các lá số bạn đã lưu.',
      ),
      onSettings: () => _openProtected(
        context,
        ref,
        destination: AppRoute.accountSettings,
        icon: Icons.settings_outlined,
        message: 'Đăng nhập để quản lý bảo mật và cài đặt tài khoản.',
      ),
      onPremium: () => _openProtected(
        context,
        ref,
        destination: '${AppRoute.coinPackages}?tab=membership',
        icon: Icons.workspace_premium_outlined,
        message: 'Đăng nhập để xem và nâng cấp quyền lợi thành viên Premium.',
      ),
      onSupport: () => _showComingSoon(context, 'Trung tâm hỗ trợ'),
      onPolicy: () => _showComingSoon(context, 'Chính sách sử dụng'),
      onLogout: () => _confirmLogout(context, ref),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await MysticNotificationDialog.show<bool>(
      context,
      dialog: MysticNotificationDialog(
        header: 'TÀI KHOẢN',
        title: 'Đăng xuất tài khoản?',
        description:
            'Bạn vẫn có thể đăng nhập lại để tiếp tục sử dụng dữ liệu đã đồng bộ.',
        leading: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFA13A2C),
          size: 38,
        ),
        cancelLabel: 'HỦY',
        confirmLabel: 'ĐĂNG XUẤT',
        onCancel: () => Navigator.pop(context, false),
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<void> _openProtected(
    BuildContext context,
    WidgetRef ref, {
    required String destination,
    required IconData icon,
    required String message,
  }) async {
    if (ref.read(authControllerProvider).asData?.value != null) {
      context.push(destination);
      return;
    }
    final shouldLogin = await showLoginRequiredDialog(
      context,
      icon: icon,
      message: message,
    );
    if (shouldLogin == true && context.mounted) {
      context.push(AuthRoutePolicy.loginLocation(destination));
    }
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref) async {
    if (ref.read(authControllerProvider).asData?.value != null) {
      context.push(AppRoute.chat);
      return;
    }
    final shouldLogin = await showLoginRequiredDialog(
      context,
      icon: Icons.chat_bubble_outline_rounded,
      message:
          'Đăng nhập để hỏi Tử Vi AI, sử dụng lá số cá nhân và lưu lại lịch sử trò chuyện.',
    );
    if (shouldLogin == true && context.mounted) {
      context.push(AuthRoutePolicy.loginLocation(AppRoute.chat));
    }
  }

  Future<void> _openWallet(BuildContext context, WidgetRef ref) async {
    if (ref.read(authControllerProvider).asData?.value != null) {
      context.push(AppRoute.wallet);
      return;
    }
    final shouldLogin = await showLoginRequiredDialog(
      context,
      icon: Icons.account_balance_wallet_outlined,
      message:
          'Đăng nhập để xem số dư Xu, điểm danh, làm nhiệm vụ và quản lý giao dịch của bạn.',
    );
    if (shouldLogin == true && context.mounted) {
      context.push(AuthRoutePolicy.loginLocation(AppRoute.wallet));
    }
  }
}

class _HomeAppBarConnector extends ConsumerWidget
    implements PreferredSizeWidget {
  const _HomeAppBarConnector({
    this.onMenuPressed,
    this.onWalletPressed,
    this.onAddCoinPressed,
  });

  final VoidCallback? onMenuPressed;
  final VoidCallback? onWalletPressed;
  final VoidCallback? onAddCoinPressed;

  @override
  Size get preferredSize => const Size.fromHeight(66);

  @override
  Widget build(BuildContext context, WidgetRef ref) => HomeMysticAppBar(
    coinBalance: ref.watch(homeCoinBalanceProvider),
    onMenuPressed: onMenuPressed,
    onWalletPressed: onWalletPressed,
    onAddCoinPressed: onAddCoinPressed,
  );
}

class _HomeDailyMessageConnector extends ConsumerWidget {
  const _HomeDailyMessageConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) => HomeDailyMessageCard(
    message: ref.watch(homeDailyMessageProvider),
    year: ref.watch(homeAuspiciousYearProvider),
  );
}

class _HomeHeroGreeting extends StatelessWidget {
  const _HomeHeroGreeting();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 108,
    child: Align(
      alignment: Alignment.topLeft,
      child: FractionallySizedBox(
        widthFactor: .72,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại',
                style: TextStyle(
                  color: Color(0xFFD7D0C1),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: .15,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Khám phá\nvận mệnh của bạn',
                maxLines: 2,
                softWrap: false,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFFFFE4A8),
                  fontFamily: 'serif',
                  fontSize: 25,
                  height: 1.08,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(color: Color(0xB3000000), blurRadius: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ignore: unused_element
class _LegacyDailyMessageCard extends StatelessWidget {
  const _LegacyDailyMessageCard();

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF071829), Color(0xFF03101E)],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE0B85F), width: 1.5),
      boxShadow: const [
        BoxShadow(color: Color(0x664B3515), blurRadius: 12),
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 14,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x55F2D48A), width: .7),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 0,
            top: 0,
            child: Opacity(
              opacity: .34,
              child: Icon(
                Icons.dark_mode_outlined,
                size: 64,
                color: Color(0xFFFFD77A),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.explore_outlined,
                      size: 31,
                      color: Color(0xFFE1B85C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thông điệp hôm nay',
                          style: TextStyle(
                            color: Color(0xFFF5DEA2),
                            fontFamily: 'serif',
                            fontSize: 24,
                            height: 1.05,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.25,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Lời nhắn dành cho bạn',
                          style: TextStyle(
                            color: Color(0xFFE1B85C),
                            fontFamily: 'serif',
                            fontSize: 14,
                            height: 1.15,
                            fontStyle: FontStyle.italic,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Row(
                children: [
                  const SizedBox(width: 41),
                  Expanded(
                    child: Container(height: 1, color: const Color(0x887C5A26)),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.auto_awesome,
                    size: 11,
                    color: Color(0xFFD8A94B),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              const Padding(
                padding: EdgeInsets.only(left: 41, right: 4),
                child: Text(
                  'Tâm tĩnh thì trí sáng. Hãy dành một nhịp chậm để nhìn rõ cơ hội đang đến gần.',
                  style: TextStyle(
                    color: Color(0xFFF0E8D8),
                    fontSize: 15.5,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                margin: const EdgeInsets.only(left: 22),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x99101B25),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFB9852D)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Color(0xFFF0C65F),
                    ),
                    SizedBox(width: 9),
                    Text(
                      'Ngày cát lành  ·  2026',
                      style: TextStyle(
                        color: Color(0xFFECE2CC),
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

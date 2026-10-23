import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_colors.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'providers/home_providers.dart';
import 'widgets/home_daily_message_card.dart';
import 'widgets/home_destiny_discovery_card.dart';
import 'widgets/home_featured_grid.dart';
import 'widgets/home_mystic_app_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MysticScaffold(
    extendBodyBehindAppBar: true,
    background: Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
          child: Transform.scale(
            scale: 1.02,
            child: Image.asset(
              MysticAssets.homeBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheWidth:
                  (MediaQuery.sizeOf(context).width *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
        const ColoredBox(color: Color(0x58020812)),
      ],
    ),
    appBar: _HomeAppBarConnector(
      onMenuPressed: () => _showComingSoon(context, 'Menu'),
      onWalletPressed: () => context.go(AppRoute.wallet),
      onAddCoinPressed: () => context.go(AppRoute.wallet),
    ),
    body: RefreshIndicator(
      color: MysticColors.gold,
      backgroundColor: MysticColors.midnight,
      onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          MysticSpacing.md,
          0,
          MysticSpacing.md,
          MysticSpacing.md,
        ),
        children: [
          const _HomeHeroGreeting(),
          const SizedBox(height: MysticSpacing.sm),
          HomeDestinyDiscoveryCard(
            onPressed: () => context.go(AppRoute.horoscope),
          ),
          const SizedBox(height: MysticSpacing.xs),
          const _HomeDailyMessageConnector(),
          const SizedBox(height: MysticSpacing.xs),
          HomeFeaturedGrid(
            onChartPressed: () => context.go(AppRoute.horoscope),
            onTodayPressed: () => context.go(AppRoute.dailyFortune),
            onChatPressed: () => context.go(AppRoute.chat),
            onArticlesPressed: () => _showComingSoon(context, 'Bài viết'),
            onViewAllPressed: () => _showComingSoon(context, 'Tính năng'),
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
                    Shadow(color: Color(0xCC000000), blurRadius: 8),
                    Shadow(color: Color(0x807E541C), blurRadius: 12),
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

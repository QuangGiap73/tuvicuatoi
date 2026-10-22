import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../auth/domain/auth_user.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import 'providers/chart_form_providers.dart';
import 'widgets/saved_chart_card.dart';

class MyChartsPage extends ConsumerWidget {
  const MyChartsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myChartsControllerProvider);
    final user = ref.watch(authControllerProvider).asData?.value?.user;
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();

    return Scaffold(
      backgroundColor: const Color(0xFF03101E),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.myChartsBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth: cacheWidth,
            filterQuality: FilterQuality.medium,
          ),
          const ColoredBox(color: Color(0x33000612)),
          SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFFD9AE5F),
              backgroundColor: const Color(0xFF071827),
              onRefresh: () =>
                  ref.read(myChartsControllerProvider.notifier).load(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _MyChartsHero(
                      onBack: context.pop,
                      onCreate: () => context.go(AppRoute.horoscope),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
                    sliver: SliverList.list(
                      children: [
                        _ChartVaultSummary(
                          user: user,
                          loadedCount: state.charts.length,
                          onCreate: () => context.go(AppRoute.horoscope),
                          onUpgrade: () => context.go(AppRoute.wallet),
                        ),
                        const SizedBox(height: 13),
                        if (state.isLoading && state.charts.isEmpty)
                          const _LoadingState()
                        else if (state.errorMessage != null &&
                            state.charts.isEmpty)
                          _ErrorState(
                            message: state.errorMessage!,
                            onRetry: () => ref
                                .read(myChartsControllerProvider.notifier)
                                .load(),
                          )
                        else if (state.charts.isEmpty)
                          _EmptyState(
                            onCreate: () => context.go(AppRoute.horoscope),
                          )
                        else
                          for (final chart in state.charts) ...[
                            SavedChartCard(
                              chart: chart,
                              isDeleting: state.deletingId == chart.id,
                              onInterpret: () => _comingSoon(
                                context,
                                'Luận giải ${chart.displayName}',
                              ),
                              onAskAi: () => context.go(AppRoute.chat),
                              onDelete: () =>
                                  _confirmDelete(context, ref, chart.id),
                            ),
                            const SizedBox(height: 13),
                          ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6E5BD),
        title: const Text('Xóa lá số?'),
        content: const Text('Lá số đã xóa sẽ không thể khôi phục.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFA82232),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await ref
        .read(myChartsControllerProvider.notifier)
        .delete(id);
    if (!context.mounted) return;
    if (success) {
      await ref.read(authControllerProvider.notifier).refreshProfile();
    }
    if (!context.mounted) return;
    final error = ref.read(myChartsControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Đã xóa lá số.' : error ?? 'Không thể xóa lá số.',
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context, String feature) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature sẽ được hoàn thiện ở bước tiếp theo.'),
        ),
      );
}

class _MyChartsHero extends StatelessWidget {
  const _MyChartsHero({required this.onBack, required this.onCreate});
  final VoidCallback onBack;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 5, 18, 22),
    child: Column(
      children: [
        Row(
          children: [
            const _BrandMark(),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tử Vi AI',
                    style: TextStyle(
                      color: Color(0xFFFFDEA0),
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'DESTINY · INSIGHTS',
                    style: TextStyle(
                      color: Color(0xFFD9AE5F),
                      fontSize: 8,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            _CircleMenuButton(onPressed: onBack),
          ],
        ),
        const SizedBox(height: 0),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 64, child: Divider(color: Color(0xFFB88B39))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFD66D),
                size: 25,
              ),
            ),
            SizedBox(width: 64, child: Divider(color: Color(0xFFB88B39))),
          ],
        ),
        const SizedBox(height: 5),
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'LÁ SỐ CỦA TÔI',
            style: TextStyle(
              color: Color(0xFFFFD368),
              fontFamily: 'serif',
              fontSize: 27,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
              shadows: [Shadow(color: Color(0xAA9B5D00), blurRadius: 12)],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const SizedBox(
          width: 235,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Lưu giữ và quản lý các lá số đã tạo.',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFF3E9D5),
                fontFamily: 'serif',
                fontSize: 10.5,
                height: 1.2,
                fontWeight: FontWeight.w700,
                letterSpacing: .1,
                shadows: [Shadow(color: Color(0x99000000), blurRadius: 3)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 244,
          height: 44,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                MysticAssets.bottomFrameA,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.high,
              ),
              TextButton(
                onPressed: onCreate,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFF4D9),
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'TẠO LÁ SỐ MỚI',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .9,
                        shadows: [
                          Shadow(color: Color(0xCC000000), blurRadius: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
    width: 47,
    height: 47,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFFC89B43), width: 1.2),
      color: const Color(0x99051320),
    ),
    child: const Icon(
      Icons.explore_outlined,
      color: Color(0xFFFFD76F),
      size: 29,
    ),
  );
}

class _CircleMenuButton extends StatelessWidget {
  const _CircleMenuButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xB3071522),
      border: Border.all(color: const Color(0xFFD0A551), width: 1.2),
    ),
    child: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.close_rounded, color: Color(0xFFFFE4A2), size: 25),
      padding: EdgeInsets.zero,
    ),
  );
}

class _ChartVaultSummary extends StatelessWidget {
  const _ChartVaultSummary({
    required this.user,
    required this.loadedCount,
    required this.onCreate,
    required this.onUpgrade,
  });
  final AuthUser? user;
  final int loadedCount;
  final VoidCallback onCreate;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final count = loadedCount;
    final max = user?.maxSavedCharts ?? (user?.isPremium == true ? 999 : 1);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            MysticAssets.largeFrameA,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 17),
          child: Column(
            children: [
              Row(
                children: [
                  _VaultCountBadge(count: count),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KHO LÁ SỐ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFFFE5AE),
                            fontFamily: 'serif',
                            fontSize: 18,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đã lưu $count / ${max >= 999 ? '∞' : max} lá số',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF5EEE1),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (max < 999 && count >= max) ...[
                          const SizedBox(height: 3),
                          Text(
                            '(đã đủ $max lá số gói miễn phí)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFC8BBA4),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _VaultPill(
                        icon: Icons.monetization_on_rounded,
                        label: '${user?.coinBalance ?? 0} Xu',
                      ),
                      const SizedBox(height: 6),
                      _VaultPill(
                        icon: Icons.workspace_premium_outlined,
                        label: user?.isPremium == true
                            ? 'PREMIUM'
                            : 'GÓI MIỄN PHÍ',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FractionallySizedBox(
                widthFactor: .9,
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        MysticAssets.upgradeFrameB,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                      TextButton(
                        onPressed: user?.isPremium == true
                            ? onCreate
                            : onUpgrade,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3B2917),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              user?.isPremium == true
                                  ? Icons.add_rounded
                                  : Icons.workspace_premium_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user?.isPremium == true
                                  ? 'Tạo thêm lá số'
                                  : 'Nâng cấp gói dịch vụ  ›',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VaultCountBadge extends StatelessWidget {
  const _VaultCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Container(
    width: 49,
    height: 49,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF102235),
      border: Border.all(color: const Color(0xFFE1AE47), width: 2),
      boxShadow: const [
        BoxShadow(color: Color(0x99000000), blurRadius: 6),
        BoxShadow(color: Color(0x55E1AE47), blurRadius: 8),
      ],
    ),
    child: Text(
      '$count',
      style: const TextStyle(
        color: Color(0xFFFFE5A2),
        fontFamily: 'serif',
        fontSize: 22,
        height: 1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _VaultPill extends StatelessWidget {
  const _VaultPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 93),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xAA3A2B13),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFC28B25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFFFC942)),
        const SizedBox(width: 5),
        Text(
          label,
          maxLines: 1,
          style: const TextStyle(
            color: Color(0xFFFFE19A),
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(48),
    child: Center(child: CircularProgressIndicator(color: Color(0xFFD9AE5F))),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => _MessagePanel(
    icon: Icons.cloud_off_outlined,
    message: message,
    button: 'Thử lại',
    onPressed: onRetry,
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;
  @override
  Widget build(BuildContext context) => _MessagePanel(
    icon: Icons.auto_stories_outlined,
    message: 'Bạn chưa lưu lá số nào.',
    button: 'Tạo lá số đầu tiên',
    onPressed: onCreate,
  );
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.message,
    required this.button,
    required this.onPressed,
  });
  final IconData icon;
  final String message;
  final String button;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: const Color(0xDD071827),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF9B7636)),
    ),
    child: Column(
      children: [
        Icon(icon, color: const Color(0xFFD9AE5F), size: 38),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFF2E4C4)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onPressed, child: Text(button)),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../interpretation/domain/interpretation_models.dart';
import '../../auth/presentation/require_authentication.dart';
import '../../interpretation/presentation/controllers/interpretation_controller.dart';
import '../../palace_detail/domain/palace_detail_models.dart';
import '../../palace_detail/presentation/controllers/palace_detail_controller.dart';
import '../domain/chart_result.dart';
import 'providers/chart_form_providers.dart';
import 'widgets/chart_palace_board.dart';
import 'widgets/chart_result_actions.dart';

class ChartResultPage extends ConsumerWidget {
  const ChartResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartGenerationControllerProvider);
    final result = state.result;
    if (result == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF06141F),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Chưa có dữ liệu lá số.',
                  style: TextStyle(color: Color(0xFFFFE4A4)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go(AppRoute.horoscope),
                  child: const Text('Quay lại lập lá số'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF06141F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          ),
          const ColoredBox(color: Color(0x66000812)),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ResultAppBar(
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoute.horoscope),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 26),
                  sliver: SliverList.list(
                    children: [
                      ChartResultActions(
                        isSaved: state.isSaved,
                        isSaving: state.isSaving,
                        onSave: () => _save(context, ref),
                        onInterpret: () => _openInterpretation(context, ref),
                      ),
                      const SizedBox(height: 10),
                      ChartPalaceBoard(
                        result: result,
                        onPalaceTap: (palace) =>
                            _openPalaceDetail(context, ref, result, palace),
                      ),
                      const SizedBox(height: 12),
                      _ChartInsights(result: result),
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

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    if (!requireAuthentication(
      context,
      ref,
      reason: 'Đăng nhập để lưu và đồng bộ lá số của bạn.',
    )) {
      return;
    }
    final success = await ref
        .read(chartGenerationControllerProvider.notifier)
        .save();
    if (!context.mounted) return;
    final state = ref.read(chartGenerationControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã lưu lá số vào tài khoản.'
              : state.errorMessage ?? 'Không thể lưu lá số.',
        ),
      ),
    );
  }

  void _openInterpretation(
    BuildContext context,
    WidgetRef ref, {
    String? palaceName,
  }) {
    final state = ref.read(chartGenerationControllerProvider);
    final request = state.request;
    final result = state.result;
    if (request == null || result == null) return;
    final controller = ref.read(interpretationControllerProvider.notifier);
    controller.openGenerated(
      request: request,
      result: result,
      savedChartId: state.savedChartId,
    );
    if (palaceName != null) {
      controller.selectTab(InterpretationTab.palaces);
      controller.selectPalace(palaceName);
    }
    context.push(AppRoute.interpretation);
  }

  void _openPalaceDetail(
    BuildContext context,
    WidgetRef ref,
    ChartResult result,
    ChartPalace palace,
  ) {
    final generation = ref.read(chartGenerationControllerProvider);
    ref
        .read(palaceDetailControllerProvider.notifier)
        .open(
          PalaceDetailContext(
            chart: result,
            palace: palace,
            chartId: generation.savedChartId,
          ),
        );
    context.push(AppRoute.palaceDetail);
  }
}

class _ChartInsights extends StatelessWidget {
  const _ChartInsights({required this.result});

  final ChartResult result;

  @override
  Widget build(BuildContext context) {
    final mainStars = result.palaces
        .expand((palace) => palace.mainStars)
        .map((star) => star.name)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .length;
    final luckyStars = result.palaces
        .expand((palace) => palace.luckyStars)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .length;
    final badStars = result.palaces
        .expand((palace) => palace.badStars)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
      decoration: BoxDecoration(
        color: const Color(0xE8081B2A),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFC99532), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_graph_rounded,
                size: 19,
                color: Color(0xFFFFD66E),
              ),
              SizedBox(width: 8),
              Text(
                'TỔNG QUAN TINH BÀN',
                style: TextStyle(
                  color: Color(0xFFFFE1A0),
                  fontFamily: 'serif',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InsightMetric(
                  value: mainStars,
                  label: 'Chính tinh',
                  color: const Color(0xFFFFD66E),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _InsightMetric(
                  value: luckyStars,
                  label: 'Cát tinh',
                  color: const Color(0xFF72D3A2),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _InsightMetric(
                  value: badStars,
                  label: 'Sát tinh',
                  color: const Color(0xFFFF8B88),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const Divider(color: Color(0x55D7AA50), height: 1),
          const SizedBox(height: 9),
          const Wrap(
            spacing: 14,
            runSpacing: 7,
            children: [
              _LegendDot(color: Color(0xFF16805D), label: 'Cát tinh hỗ trợ'),
              _LegendDot(color: Color(0xFFB12B36), label: 'Sát tinh thử thách'),
              _LegendDot(color: Color(0xFF329A72), label: 'Cung an Thân'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightMetric extends StatelessWidget {
  const _InsightMetric({
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF102A3A),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: color.withValues(alpha: .6)),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontFamily: 'serif',
            fontSize: 21,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD9CCAD),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(color: Color(0xFFBEB293), fontSize: 9.5),
      ),
    ],
  );
}

class _ResultAppBar extends StatelessWidget {
  const _ResultAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFFFFD66E),
        ),
        const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TỬ VI AI 2026',
                style: TextStyle(
                  color: Color(0xFFFFD98B),
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'DESTINY · INSIGHTS',
                style: TextStyle(
                  color: Color(0xFFCEAA67),
                  fontSize: 7,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: null,
          icon: Icon(Icons.menu_rounded),
          color: Color(0xFFFFD66E),
        ),
      ],
    ),
  );
}

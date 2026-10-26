import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../ai_chat/presentation/controllers/ai_chat_controller.dart';
import '../../interpretation/domain/interpretation_models.dart';
import '../../interpretation/presentation/controllers/interpretation_controller.dart';
import '../../palace_detail/domain/palace_detail_models.dart';
import '../../palace_detail/presentation/controllers/palace_detail_controller.dart';
import '../domain/chart_result.dart';
import 'providers/chart_form_providers.dart';
import 'widgets/chart_palace_board.dart';
import 'widgets/chart_result_actions.dart';
import 'widgets/chart_result_header.dart';

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
                SliverToBoxAdapter(child: _ResultAppBar(onBack: context.pop)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 26),
                  sliver: SliverList.list(
                    children: [
                      ChartResultHeader(result: result),
                      const SizedBox(height: 10),
                      ChartResultActions(
                        isSaved: state.isSaved,
                        isSaving: state.isSaving,
                        onSave: () => _save(context, ref),
                        onInterpret: () => _openInterpretation(context, ref),
                        onAskAi: () {
                          ref
                              .read(aiChatControllerProvider.notifier)
                              .useGeneratedChart(result);
                          context.push(AppRoute.chat);
                        },
                        onExport: () => _comingSoon(context, 'Xuất PDF'),
                      ),
                      const SizedBox(height: 10),
                      ChartPalaceBoard(
                        result: result,
                        onPalaceTap: (palace) =>
                            _openPalaceDetail(context, ref, result, palace),
                      ),
                      const SizedBox(height: 12),
                      const _DetailHint(),
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

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature sẽ được nối ở bước tiếp theo.')),
    );
  }
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

class _DetailHint extends StatelessWidget {
  const _DetailHint();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xD9081824),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFCE9C3C)),
    ),
    child: const Row(
      children: [
        Icon(Icons.grid_view_rounded, color: Color(0xFFFFD66E)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHỌN CUNG XEM CHI TIẾT',
                style: TextStyle(
                  color: Color(0xFFFFE5AB),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Nhấn vào từng cung để xem dữ liệu chi tiết',
                style: TextStyle(color: Color(0xFFBDAE8D), fontSize: 9),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFD66E)),
      ],
    ),
  );
}

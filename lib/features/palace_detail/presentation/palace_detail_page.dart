import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../ai_chat/presentation/controllers/ai_chat_controller.dart';
import '../../horoscope/presentation/providers/chart_form_providers.dart';
import '../../interpretation/domain/interpretation_models.dart';
import '../../interpretation/presentation/controllers/interpretation_controller.dart';
import '../domain/palace_detail_models.dart';
import 'controllers/palace_detail_controller.dart';
import 'state/palace_detail_state.dart';
import 'widgets/palace_detail_sections.dart';

class PalaceDetailPage extends ConsumerWidget {
  const PalaceDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(palaceDetailControllerProvider);
    final detail = state.context;
    if (detail == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF03101E),
        body: SafeArea(
          child: Center(
            child: OutlinedButton(
              onPressed: () => context.go(AppRoute.horoscope),
              child: const Text('Quay lại tinh bàn'),
            ),
          ),
        ),
      );
    }
    final screenWidth = MediaQuery.sizeOf(context).width;
    final framePadding = screenWidth <= 360
        ? 8.0
        : screenWidth >= 430
        ? 16.0
        : 12.0;
    return Scaffold(
      backgroundColor: const Color(0xFF03101E),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ColoredBox(
          color: const Color(0xF2051422),
          child: Padding(
            padding: EdgeInsets.fromLTRB(framePadding, 8, framePadding, 10),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: _BottomActions(
                  state: state,
                  onAskAi: () => _openAi(context, ref, state),
                  onInterpret: () => _openInterpretation(context, ref, state),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.myChartsBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          ),
          const ColoredBox(color: Color(0x55000610)),
          SafeArea(
            child: Column(
              children: [
                _PalaceDetailAppBar(
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoute.horoscope),
                ),
                Expanded(
                  child: CustomScrollView(
                    key: ValueKey(
                      'palace-${detail.chart.id}-${detail.palace.id}',
                    ),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          framePadding,
                          0,
                          framePadding,
                          20,
                        ),
                        sliver: SliverList.list(
                          children: [
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 680,
                                ),
                                child: PalaceHeroCard(palace: detail.palace),
                              ),
                            ),
                            const SizedBox(height: 9),
                            _SectionWidth(
                              child: MainStarsSection(
                                stars: detail.palace.mainStars,
                                rules: state.rules,
                              ),
                            ),
                            const SizedBox(height: 9),
                            _SectionWidth(
                              child: StarsGroupSection(
                                luckyStars: detail.palace.luckyStars,
                                badStars: detail.palace.badStars,
                              ),
                            ),
                            if (state.relatedPalaces.isNotEmpty) ...[
                              const SizedBox(height: 9),
                              _SectionWidth(
                                child: RelatedPalacesSection(
                                  palaces: state.relatedPalaces,
                                  rules: state.triadRules,
                                ),
                              ),
                              const SizedBox(height: 9),
                              _SectionWidth(
                                child: PalaceSummarySection(
                                  palace: detail.palace,
                                  relatedPalaces: state.relatedPalaces,
                                ),
                              ),
                            ],
                            const SizedBox(height: 9),
                            _SectionWidth(
                              child: FreeIntroductionSection(
                                summary: state.freeSummary,
                              ),
                            ),
                            if (state.isLoading) ...[
                              const SizedBox(height: 12),
                              const Center(
                                child: SizedBox.square(
                                  dimension: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFFFD978),
                                  ),
                                ),
                              ),
                            ],
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 9),
                              _SectionWidth(
                                child: _InlineError(
                                  message: state.errorMessage!,
                                  onRetry: () => ref
                                      .read(
                                        palaceDetailControllerProvider.notifier,
                                      )
                                      .retry(),
                                ),
                              ),
                            ],
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

  void _openAi(BuildContext context, WidgetRef ref, PalaceDetailState state) {
    final detail = state.context;
    if (detail == null) return;
    final controller = ref.read(aiChatControllerProvider.notifier);
    controller.useGeneratedChart(detail.chart);
    final index = AiChatController.palaceNames.indexWhere(
      (name) =>
          normalizePalaceSlug(name) == normalizePalaceSlug(detail.palace.name),
    );
    if (index >= 0) controller.selectTopic(index);
    context.push(AppRoute.chat);
  }

  void _openInterpretation(
    BuildContext context,
    WidgetRef ref,
    PalaceDetailState state,
  ) {
    final detail = state.context;
    if (detail == null) return;
    final generation = ref.read(chartGenerationControllerProvider);
    final request = generation.result?.id == detail.chart.id
        ? generation.request
        : null;
    final controller = ref.read(interpretationControllerProvider.notifier);
    controller.openContext(
      InterpretationChartContext(
        name: detail.chart.fullName,
        chartId: detail.chartId,
        chartData: detail.chart.rawData,
        request: request,
        generatedResult: detail.chart,
      ),
    );
    controller.selectTab(InterpretationTab.palaces);
    controller.selectPalace(detail.palace.name);
    context.push(AppRoute.interpretation);
  }
}

class _SectionWidth extends StatelessWidget {
  const _SectionWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}

class _PalaceDetailAppBar extends StatelessWidget {
  const _PalaceDetailAppBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 76,
    child: Stack(
      alignment: Alignment.center,
      children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chi tiết cung',
              style: TextStyle(
                color: Color(0xFFFFE1A0),
                fontFamily: 'serif',
                fontSize: 25,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 5)],
              ),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 45,
                  child: Divider(color: Color(0xFFFFD978), height: 1),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.local_florist_rounded,
                    size: 18,
                    color: Color(0xFFFFD978),
                  ),
                ),
                SizedBox(
                  width: 45,
                  child: Divider(color: Color(0xFFFFD978), height: 1),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 8,
          top: 14,
          child: Material(
            color: const Color(0xCC0A1C2A),
            shape: const CircleBorder(
              side: BorderSide(color: Color(0xFFD6A33D), width: 1.2),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onBack,
              child: const SizedBox.square(
                dimension: 44,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 21,
                  color: Color(0xFFFFD978),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.state,
    required this.onAskAi,
    required this.onInterpret,
  });
  final PalaceDetailState state;
  final VoidCallback onAskAi;
  final VoidCallback onInterpret;

  @override
  Widget build(BuildContext context) {
    final section = state.readingSection;
    final price = section?.coinCost;
    final label = state.isUnlocked || section?.isFree == true
        ? 'Xem luận giải chi tiết'
        : price == null
        ? 'Xem luận giải chi tiết'
        : 'Xem luận giải chi tiết\n• $price Xu';
    final askButton = _ActionButton(
      label: 'Hỏi AI về cung này',
      icon: Icons.auto_awesome_rounded,
      onPressed: onAskAi,
    );
    final interpretationButton = _ActionButton(
      label: label,
      icon: state.isUnlocked
          ? Icons.lock_open_rounded
          : Icons.lock_outline_rounded,
      emphasized: true,
      onPressed: onInterpret,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 315) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              askButton,
              const SizedBox(height: 7),
              interpretationButton,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: askButton),
            const SizedBox(width: 8),
            Expanded(child: interpretationButton),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.emphasized = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 55),
    decoration: BoxDecoration(
      color: emphasized ? const Color(0xFF9B620B) : const Color(0xFF12212A),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD5A237), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 10.5,
          height: 1.15,
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFFFE7AE),
        padding: const EdgeInsets.symmetric(horizontal: 7),
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0x55A52E2E),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0x88B84949)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF7F2A25), fontSize: 11),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Thử lại')),
      ],
    ),
  );
}

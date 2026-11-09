import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_typography.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/mystic_date_picker_dialog.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'controllers/daily_fortune_controller.dart';
import 'widgets/daily_fortune_date_selector.dart';
import 'widgets/daily_fortune_empty_state.dart';
import 'widgets/daily_calendar_card.dart';
import 'widgets/active_fortune_chart_card.dart';
import 'widgets/auspicious_hours_card.dart';
import 'widgets/fortune_guidance_card.dart';
import 'widgets/fortune_hours_card.dart';
import 'widgets/fortune_life_aspects_card.dart';
import 'widgets/fortune_lucky_card.dart';
import 'widgets/fortune_overview_card.dart';
import 'widgets/fortune_ai_prompt_card.dart';
import 'widgets/personal_fortune_details_card.dart';

class DailyFortunePage extends ConsumerWidget {
  const DailyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MysticScaffold(
      safeTop: false,
      constrainBody: false,
      background: RepaintBoundary(
        child: Image.asset(
          MysticAssets.dailyFortuneBackground,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          cacheWidth:
              (MediaQuery.sizeOf(context).width *
                      MediaQuery.devicePixelRatioOf(context))
                  .round(),
          filterQuality: FilterQuality.medium,
        ),
      ),
      body: const CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(child: _DailyFortuneHeaderConnector()),
          _DailyFortuneContent(),
        ],
      ),
    );
  }
}

class _DailyFortuneHeaderConnector extends ConsumerWidget {
  const _DailyFortuneHeaderConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(
      dailyFortuneControllerProvider.select((state) => state.selectedDate),
    );
    return SafeArea(
      bottom: false,
      child: _DailyFortuneHeader(
        selectedDate: date,
        onBack: () =>
            context.canPop() ? context.pop() : context.go(AppRoute.home),
        onCalendar: () => _selectDate(context, ref, date),
      ),
    );
  }
}

class _DailyFortuneContent extends ConsumerWidget {
  const _DailyFortuneContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final structure = ref.watch(
      dailyFortuneControllerProvider.select(
        (state) => (
          hasFortune: state.fortune != null,
          hasPersonal: state.fortune?.personal != null,
          hasPrompt:
              state.fortune?.aiSuggestedPrompt?.trim().isNotEmpty == true,
        ),
      ),
    );
    final items = <Widget>[
      const _DateSelectorConnector(),
      const SizedBox(height: 4),
    ];
    void add(Widget child) {
      items.add(child);
      items.add(const SizedBox(height: 10));
    }

    if (!structure.hasFortune) {
      add(const _EmptyFortuneConnector());
    } else {
      add(const _FortuneSection(type: _FortuneSectionType.calendar));
      add(const _ActiveFortuneChartConnector());
      add(const _FortuneOverviewConnector());
      if (structure.hasPersonal) {
        add(const _FortuneSection(type: _FortuneSectionType.lifeAspects));
        add(const _FortuneSection(type: _FortuneSectionType.lucky));
      }
      add(const _FortuneSection(type: _FortuneSectionType.compatibleHours));
      add(const _FortuneSection(type: _FortuneSectionType.directions));
      add(const _FortuneSection(type: _FortuneSectionType.auspiciousHours));
      if (structure.hasPersonal) {
        add(const _FortuneSection(type: _FortuneSectionType.personalDetails));
      }
      if (structure.hasPrompt) {
        add(const _FortuneSection(type: _FortuneSectionType.aiPrompt));
      }
    }
    items.add(const SizedBox(height: 100));

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
      sliver: SliverList.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: MysticSpacing.contentMaxWidth,
            ),
            child: items[index],
          ),
        ),
      ),
    );
  }
}

class _DateSelectorConnector extends ConsumerWidget {
  const _DateSelectorConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(
      dailyFortuneControllerProvider.select(
        (state) => (
          date: state.selectedDate,
          fortune: state.fortune,
          loading: state.isLoading,
          error: state.errorMessage,
        ),
      ),
    );
    return DailyFortuneDateSelector(
      date: view.date,
      fortune: view.fortune,
      isLoading: view.loading,
      errorMessage: view.error,
      onPrevious: () =>
          ref.read(dailyFortuneControllerProvider.notifier).previousDay(),
      onNext: () => ref.read(dailyFortuneControllerProvider.notifier).nextDay(),
      onToday: () => ref.read(dailyFortuneControllerProvider.notifier).today(),
      onRetry: () => ref.read(dailyFortuneControllerProvider.notifier).load(),
    );
  }
}

class _EmptyFortuneConnector extends ConsumerWidget {
  const _EmptyFortuneConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(
      dailyFortuneControllerProvider.select((state) => state.selectedDate),
    );
    return DailyFortuneEmptyState(date: date);
  }
}

class _FortuneOverviewConnector extends ConsumerWidget {
  const _FortuneOverviewConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(
      dailyFortuneControllerProvider.select(
        (state) => (
          fortune: state.fortune,
          loading: state.isReadingLoading,
          error: state.readingErrorMessage,
        ),
      ),
    );
    final fortune = view.fortune;
    if (fortune == null) return const SizedBox.shrink();
    return FortuneOverviewCard(
      fortune: fortune,
      loading: view.loading,
      errorMessage: view.error,
    );
  }
}

enum _FortuneSectionType {
  calendar,
  lifeAspects,
  personalDetails,
  lucky,
  compatibleHours,
  directions,
  auspiciousHours,
  aiPrompt,
}

class _FortuneSection extends ConsumerWidget {
  const _FortuneSection({required this.type});

  final _FortuneSectionType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortune = ref.watch(
      dailyFortuneControllerProvider.select((state) => state.fortune),
    );
    if (fortune == null) return const SizedBox.shrink();
    return switch (type) {
      _FortuneSectionType.calendar => DailyCalendarCard(fortune: fortune),
      _FortuneSectionType.lifeAspects => FortuneLifeAspectsCard(
        fortune: fortune,
      ),
      _FortuneSectionType.personalDetails =>
        fortune.personal == null
            ? const SizedBox.shrink()
            : PersonalFortuneDetailsCard(fortune: fortune.personal!),
      _FortuneSectionType.lucky =>
        fortune.personal == null
            ? const SizedBox.shrink()
            : FortuneLuckyCard(fortune: fortune.personal!),
      _FortuneSectionType.compatibleHours => FortuneHoursCard(fortune: fortune),
      _FortuneSectionType.directions => FortuneGuidanceCard(fortune: fortune),
      _FortuneSectionType.auspiciousHours => AuspiciousHoursCard(
        fortune: fortune,
      ),
      _FortuneSectionType.aiPrompt => FortuneAiPromptCard(
        prompt: fortune.aiSuggestedPrompt ?? '',
        onOpenChat: () => context.push(
          '${AppRoute.chat}?prompt=${Uri.encodeQueryComponent(fortune.aiSuggestedPrompt ?? '')}',
        ),
      ),
    };
  }
}

class _ActiveFortuneChartConnector extends ConsumerWidget {
  const _ActiveFortuneChartConnector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(
      dailyFortuneControllerProvider.select(
        (state) => (
          charts: state.charts,
          selected: state.selectedChart,
          loading: state.isChartsLoading || state.isReadingLoading,
        ),
      ),
    );
    return ActiveFortuneChartCard(
      charts: view.charts,
      selected: view.selected,
      loading: view.loading,
      onChanged: (chart) =>
          ref.read(dailyFortuneControllerProvider.notifier).selectChart(chart),
    );
  }
}

Future<void> _selectDate(
  BuildContext context,
  WidgetRef ref,
  DateTime selectedDate,
) async {
  final date = await showDialog<DateTime>(
    context: context,
    barrierColor: const Color(0xCC00050A),
    builder: (context) => MysticDatePickerDialog(
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ),
  );
  if (date == null) return;
  ref.read(dailyFortuneControllerProvider.notifier).selectDate(date);
}

class _DailyFortuneHeader extends StatelessWidget {
  const _DailyFortuneHeader({
    required this.selectedDate,
    required this.onBack,
    required this.onCalendar,
  });

  final DateTime selectedDate;
  final VoidCallback onBack;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 350;
      final side = narrow ? 42.0 : 47.0;
      return SizedBox(
        // Giữ đường phân cách và khung chọn ngày gần cụm tiêu đề hơn.
        height: narrow ? 50 : 82,
        child: Stack(
          children: [
            Positioned(
              left: 15,
              right: 15,
              top: narrow ? 11 : 13,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCircleButton(
                    size: side,
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Quay lại',
                    onPressed: onBack,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: narrow ? 1 : 0),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Vận Hạn Hôm Nay',
                              maxLines: 1,
                              style: MysticTypography.pageTitle(
                                fontSize: narrow ? 23 : 27,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '✧  Tra cứu lịch vận niên  •  Soi chiếu vận trình  ✧',
                              maxLines: 1,
                              style: TextStyle(
                                color: const Color(0xFFE4C384),
                                fontSize: narrow ? 9 : 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: .15,
                                shadows: const [
                                  Shadow(color: Colors.black, blurRadius: 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _HeaderCircleButton(
                    size: side,
                    icon: Icons.calendar_month_rounded,
                    tooltip:
                        'Ngày ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    onPressed: onCalendar,
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _GoldHeaderDivider(),
            ),
          ],
        ),
      );
    },
  );
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xB3071827),
      border: Border.all(color: const Color(0xFFD4A348), width: 1.3),
      boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3)],
    ),
    child: IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: Icon(icon, color: const Color(0xFFFFDD8B), size: size * .45),
    ),
  );
}

class _GoldHeaderDivider extends StatelessWidget {
  const _GoldHeaderDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 13,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFF9B702D),
                Color(0xFFFFD46D),
                Color(0xFF9B702D),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Transform.rotate(
          angle: .785398,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF0A1927),
              border: Border.all(color: const Color(0xFFFFCE64), width: 1.2),
            ),
          ),
        ),
      ],
    ),
  );
}

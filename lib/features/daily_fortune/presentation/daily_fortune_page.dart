import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/theme/mystic_spacing.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'controllers/daily_fortune_controller.dart';
import 'widgets/daily_fortune_date_selector.dart';
import 'widgets/daily_fortune_empty_state.dart';
import 'widgets/daily_calendar_card.dart';
import 'widgets/active_fortune_chart_card.dart';
import 'widgets/fortune_guidance_card.dart';
import 'widgets/fortune_hours_card.dart';
import 'widgets/fortune_overview_card.dart';

class DailyFortunePage extends ConsumerWidget {
  const DailyFortunePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyFortuneControllerProvider);
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
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SafeArea(
            bottom: false,
            child: _DailyFortuneHeader(
              selectedDate: state.selectedDate,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(AppRoute.home),
              onCalendar: () => _selectDate(context, ref, state.selectedDate),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: MysticSpacing.contentMaxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 110),
                child: Column(
                  children: [
                    DailyFortuneDateSelector(
                      date: state.selectedDate,
                      fortune: state.fortune,
                      isLoading: state.isLoading,
                      errorMessage: state.errorMessage,
                      onPrevious: () => ref
                          .read(dailyFortuneControllerProvider.notifier)
                          .previousDay(),
                      onNext: () => ref
                          .read(dailyFortuneControllerProvider.notifier)
                          .nextDay(),
                      onToday: () => ref
                          .read(dailyFortuneControllerProvider.notifier)
                          .today(),
                      onRetry: () => ref
                          .read(dailyFortuneControllerProvider.notifier)
                          .load(),
                    ),
                    const SizedBox(height: MysticSpacing.md),
                    if (state.fortune == null)
                      DailyFortuneEmptyState(date: state.selectedDate)
                    else ...[
                      DailyCalendarCard(fortune: state.fortune!),
                      const SizedBox(height: 10),
                      ActiveFortuneChartCard(
                        charts: state.charts,
                        selected: state.selectedChart,
                        loading: state.isChartsLoading,
                        onChanged: (chart) => ref
                            .read(dailyFortuneControllerProvider.notifier)
                            .selectChart(chart),
                      ),
                      const SizedBox(height: 10),
                      FortuneOverviewCard(
                        fortune: state.fortune!,
                        loading: state.isReadingLoading,
                        errorMessage: state.readingErrorMessage,
                      ),
                      const SizedBox(height: 10),
                      FortuneGuidanceCard(fortune: state.fortune!),
                      const SizedBox(height: 10),
                      FortuneHoursCard(fortune: state.fortune!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Chọn ngày xem vận hạn',
    );
    if (date == null) return;
    ref.read(dailyFortuneControllerProvider.notifier).selectDate(date);
  }
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
                              style: TextStyle(
                                color: const Color(0xFFFFD978),
                                fontFamily: 'serif',
                                fontSize: narrow ? 23 : 27,
                                height: 1.1,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                shadows: const [
                                  Shadow(
                                    color: Color(0xCC3B2108),
                                    blurRadius: 3,
                                    offset: Offset(0, 2),
                                  ),
                                  Shadow(
                                    color: Color(0x66E4AE45),
                                    blurRadius: 10,
                                  ),
                                ],
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
                                  Shadow(color: Colors.black, blurRadius: 4),
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
      boxShadow: const [
        BoxShadow(color: Color(0x88000000), blurRadius: 7),
        BoxShadow(color: Color(0x44D4A348), blurRadius: 8),
      ],
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

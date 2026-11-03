import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../horoscope/domain/saved_chart.dart';

class ActiveFortuneChartCard extends StatelessWidget {
  const ActiveFortuneChartCard({
    required this.charts,
    required this.selected,
    required this.loading,
    required this.onChanged,
    super.key,
  });
  final List<SavedChart> charts;
  final SavedChart? selected;
  final bool loading;
  final ValueChanged<SavedChart> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = (width * .19).clamp(68.0, 92.0);
      final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context))
          .round();
      return RepaintBoundary(
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                MysticAssets.dailyFortuneChartFrame,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
              Positioned(
                left: width * .135,
                right: width * .30,
                top: height * .14,
                bottom: height * .13,
                child: _ChartInformation(
                  chart: selected,
                  loading: loading,
                  hasCharts: charts.isNotEmpty,
                ),
              ),
              Positioned(
                right: width * .04,
                top: height * .30,
                width: width * .225,
                height: height * .40,
                child: PopupMenuButton<SavedChart>(
                  enabled: !loading && charts.isNotEmpty,
                  tooltip: 'Đổi lá số',
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 6),
                  color: const Color(0xFF0A2133),
                  surfaceTintColor: Colors.transparent,
                  elevation: 12,
                  constraints: const BoxConstraints(
                    minWidth: 172,
                    maxWidth: 230,
                    maxHeight: 248,
                  ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color(0xFFD5A443),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onSelected: onChanged,
                  itemBuilder: (_) => charts
                      .map(
                        (chart) => PopupMenuItem(
                          value: chart,
                          height: 42,
                          child: Row(
                            children: [
                              Icon(
                                chart.id == selected?.id
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 16,
                                color: const Color(0xFFFFD77C),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chart.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFFFE4A8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (chart.menh?.trim().isNotEmpty == true)
                                      Text(
                                        chart.menh!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFFCAB98F),
                                          fontSize: 9,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 15,
                        color: Color(0xFF30200E),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Đổi lá số',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF30200E),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ChartInformation extends StatelessWidget {
  const _ChartInformation({
    required this.chart,
    required this.loading,
    required this.hasCharts,
  });
  final SavedChart? chart;
  final bool loading;
  final bool hasCharts;

  @override
  Widget build(BuildContext context) {
    if (loading && chart == null) {
      return const Center(
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (!hasCharts || chart == null) {
      return const Center(
        child: Text(
          'Đăng nhập và lưu lá số để xem vận hạn cá nhân.',
          maxLines: 2,
          style: TextStyle(fontSize: 10, color: Color(0xFF4B3821)),
        ),
      );
    }
    final place = _first(chart!.chartData, const [
      'birthPlace',
      'birth_place',
      'place',
      'location',
    ]);
    final time = _first(chart!.chartData, const [
      'solarTime',
      'solar_time',
      'birthTime',
      'birth_time',
    ]);
    final birth = [
      chart!.solarDate,
      time,
    ].where((value) => value.isNotEmpty).join(' • ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'LÁ SỐ ĐANG SOI CHIẾU',
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Color(0xFF30200E),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${chart!.displayName}${chart!.menh == null ? '' : ' · ${chart!.menh}'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Color(0xFF30200E),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _Info(
              icon: Icons.person_rounded,
              text: chart!.gender.isEmpty ? '—' : chart!.gender,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Info(
                icon: Icons.calendar_month_rounded,
                text: birth.isEmpty ? 'Chưa cập nhật' : birth,
              ),
            ),
            if (place.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: _Info(icon: Icons.location_on_rounded, text: place),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static String _first(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 9, color: const Color(0xFF49351D)),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 7.5, color: Color(0xFF49351D)),
        ),
      ),
    ],
  );
}

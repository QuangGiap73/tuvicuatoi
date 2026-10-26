import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xE9071A29),
      border: Border.all(color: const Color(0xFFD5A443)),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '◈  LÁ SỐ ĐANG SOI CHIẾU',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            color: Color(0xFFFFD77C),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        if (loading && selected == null)
          const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFFFD77C),
            ),
          )
        else if (charts.isEmpty)
          const Text(
            'Đăng nhập và lưu một lá số để xem vận hạn cá nhân.',
            style: TextStyle(color: Color(0xFFE6D2A7), fontSize: 12),
          )
        else
          DropdownButtonHideUnderline(
            child: DropdownButton<SavedChart>(
              isExpanded: true,
              dropdownColor: const Color(0xFF0A2133),
              value:
                  charts.where((item) => item.id == selected?.id).firstOrNull ??
                  charts.first,
              iconEnabledColor: const Color(0xFFFFD77C),
              items: charts
                  .map(
                    (chart) => DropdownMenuItem(
                      value: chart,
                      child: Text(
                        '${chart.displayName} • ${chart.menh ?? 'Chưa rõ Mệnh'}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFE4A8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: loading
                  ? null
                  : (value) {
                      if (value != null) onChanged(value);
                    },
            ),
          ),
      ],
    ),
  );
}

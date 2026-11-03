import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';
import '../../domain/fortune_hour.dart';

class FortuneHoursCard extends StatelessWidget {
  const FortuneHoursCard({required this.fortune, super.key});
  final DailyFortune fortune;

  @override
  Widget build(BuildContext context) {
    final compatible = fortune.hours.where(_isCompatible).take(2).toList();
    final hours = compatible.isNotEmpty
        ? compatible
        : fortune.hours.where((hour) => hour.isAuspicious).take(2).toList();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xF2071A29),
        border: Border.all(color: const Color(0xFFD5A443), width: 1.2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 9),
            child: Row(
              children: [
                Icon(Icons.group_rounded, color: Color(0xFFFFC94D), size: 22),
                SizedBox(width: 7),
                Text(
                  'GIỜ HỢP TUỔI',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 16,
                    color: Color(0xFFFFD77C),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (hours.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Chưa có dữ liệu giờ hợp tuổi.',
                style: TextStyle(color: Color(0xFFCAB98F)),
              ),
            )
          else
            Row(
              children: [
                for (var i = 0; i < hours.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _HourTile(hour: hours[i])),
                ],
                if (hours.length == 1) const Expanded(child: SizedBox()),
              ],
            ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;
              final itemCount =
                  fortune.shouldDo.length > fortune.shouldAvoid.length
                  ? fortune.shouldDo.length.clamp(0, 5)
                  : fortune.shouldAvoid.length.clamp(0, 5);
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final calculated =
                  (68 + itemCount * (compact ? 27 : 22)) * textScale;
              final height = calculated < (compact ? 145 : 130)
                  ? (compact ? 145.0 : 130.0)
                  : calculated;
              return Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: height,
                      child: _AdvicePanel(
                        title: 'VIỆC NÊN LÀM',
                        items: fortune.shouldDo,
                        positive: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: height,
                      child: _AdvicePanel(
                        title: 'VIỆC NÊN KIÊNG',
                        items: fortune.shouldAvoid,
                        positive: false,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static bool _isCompatible(FortuneHour hour) {
    final text = [
      hour.affinityType,
      hour.affinityLabel,
      hour.affinityBadge,
    ].whereType<String>().join(' ').toLowerCase();
    return text.contains('hợp') || text.contains('quý nhân');
  }
}

class _HourTile extends StatelessWidget {
  const _HourTile({required this.hour});
  final FortuneHour hour;
  @override
  Widget build(BuildContext context) {
    final detail = hour.affinityLabel ?? hour.affinityBadge ?? hour.starName;
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1C9), Color(0xFFFFDF9B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(color: const Color(0xFFD6A13D), width: 1.3),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x55D8A730),
              shape: BoxShape.circle,
            ),
            child: Text(
              _animal(hour.branch),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: hour.branch,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: ' · $detail'),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 10,
                height: 1.2,
                color: Color(0xFF38240D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _animal(String branch) => switch (branch.toLowerCase()) {
    'tý' => '🐭',
    'sửu' => '🐂',
    'dần' => '🐯',
    'mão' => '🐇',
    'thìn' => '🐉',
    'tỵ' => '🐍',
    'ngọ' => '🐎',
    'mùi' => '🐐',
    'thân' => '🐒',
    'dậu' => '🐓',
    'tuất' => '🐕',
    'hợi' => '🐖',
    _ => '✦',
  };
}

class _AdvicePanel extends StatelessWidget {
  const _AdvicePanel({
    required this.title,
    required this.items,
    required this.positive,
  });
  final String title;
  final List<String> items;
  final bool positive;
  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFFB8D49C) : const Color(0xFFE2B0B3);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: positive
              ? const [Color(0xFF205044), Color(0xFF173A33)]
              : const [Color(0xFF5B333B), Color(0xFF43282E)],
        ),
        border: Border.all(
          color: positive ? const Color(0xFF839A79) : const Color(0xFFA7797D),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                positive ? Icons.eco_rounded : Icons.cancel_rounded,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          if (items.isEmpty)
            const Text(
              'Đang cập nhật',
              style: TextStyle(color: Colors.white60, fontSize: 10),
            )
          else
            ...items
                .take(5)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFEDE2CE),
                              fontSize: 10,
                              height: 1.25,
                            ),
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
}

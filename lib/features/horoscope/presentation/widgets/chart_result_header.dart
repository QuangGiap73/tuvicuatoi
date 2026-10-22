import 'package:flutter/material.dart';

import '../../domain/chart_result.dart';

class ChartResultHeader extends StatelessWidget {
  const ChartResultHeader({required this.result, super.key});

  final ChartResult result;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 12, 18, 13),
    decoration: BoxDecoration(
      color: const Color(0xFFF7E7BF),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFD6A43C), width: 1.5),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        const _LanternMark(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFB99051)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LÁ SỐ TỬ VI · ${result.amDuong.toUpperCase()}',
                  style: const TextStyle(
                    color: Color(0xFF72502A),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .8,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _firstName(result.fullName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF3A2514),
                  fontFamily: 'serif',
                  fontSize: 27,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Sinh ngày '),
                    TextSpan(
                      text: result.solarDate,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(text: ' lúc '),
                    TextSpan(
                      text: '${result.solarTime} (${result.hourBranch})',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: '\nÂm lịch: ${result.lunarDate}'),
                  ],
                ),
                style: const TextStyle(
                  color: Color(0xFF4B3823),
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  static String _firstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Lá số' : parts.last;
  }
}

class _LanternMark extends StatelessWidget {
  const _LanternMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 58,
    decoration: BoxDecoration(
      color: const Color(0xFF6B3D14),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFD9A43B), width: 2),
    ),
    child: const Icon(
      Icons.light_mode_outlined,
      color: Color(0xFFFFD978),
      size: 28,
    ),
  );
}

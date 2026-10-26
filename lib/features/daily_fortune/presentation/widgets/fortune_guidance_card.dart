import 'package:flutter/material.dart';
import '../../domain/daily_fortune.dart';

class FortuneGuidanceCard extends StatelessWidget {
  const FortuneGuidanceCard({required this.fortune, super.key});
  final DailyFortune fortune;

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
          '◉  HƯỚNG XUẤT HÀNH & KHUYẾN NGHỊ',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            color: Color(0xFFFFD77C),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Direction(
                label: 'HỶ THẦN (MAY MẮN)',
                value: fortune.joyDirection,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Direction(
                label: 'TÀI THẦN (TÀI LỘC)',
                value: fortune.wealthDirection,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Advice(
                title: '✓ NÊN LÀM',
                color: const Color(0xFF40DDA3),
                items: fortune.shouldDo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Advice(
                title: '⚠ NÊN KIÊNG CỮ',
                color: const Color(0xFFFF7180),
                items: fortune.shouldAvoid,
              ),
            ),
          ],
        ),
        if (fortune.advice?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text(
            'Lời khuyên: ${fortune.advice}',
            style: const TextStyle(
              color: Color(0xFFEADDBE),
              height: 1.4,
              fontSize: 11,
            ),
          ),
        ],
      ],
    ),
  );
}

class _Direction extends StatelessWidget {
  const _Direction({required this.label, required this.value});
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF10283A),
      border: Border.all(color: const Color(0xFF785D2B)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFBEB08D), fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? '—',
          style: const TextStyle(
            color: Color(0xFFFFD77C),
            fontFamily: 'serif',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );
}

class _Advice extends StatelessWidget {
  const _Advice({
    required this.title,
    required this.color,
    required this.items,
  });
  final String title;
  final Color color;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Color.alphaBlend(
        color.withValues(alpha: .08),
        const Color(0xFF0B2131),
      ),
      border: Border.all(color: color.withValues(alpha: .55)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        ...items
            .take(5)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $item',
                  style: const TextStyle(
                    color: Color(0xFFE5DBC5),
                    fontSize: 10,
                    height: 1.25,
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}

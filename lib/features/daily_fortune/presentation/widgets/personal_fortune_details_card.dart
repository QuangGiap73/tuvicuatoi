import 'package:flutter/material.dart';

import '../../domain/personal_fortune.dart';

class PersonalFortuneDetailsCard extends StatelessWidget {
  const PersonalFortuneDetailsCard({required this.fortune, super.key});
  final PersonalFortune fortune;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
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
          '✧  SOI CHIẾU NHẬT HẠN CÁ NHÂN',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            color: Color(0xFFFFD77C),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        _Relation(
          title: 'Xung hợp tuổi · ${fortune.branchRelationType}',
          text: fortune.branchRelationDescription,
          positive: !_negative(fortune.branchRelationType),
        ),
        const SizedBox(height: 8),
        _Relation(
          title: 'Ngũ hành ngày · ${fortune.elementRelationType}',
          text: fortune.elementRelationDescription,
          positive: !_negative(fortune.elementRelationType),
        ),
        if (fortune.majorStars.isNotEmpty || fortune.dailyStars.isNotEmpty) ...[
          const SizedBox(height: 11),
          _LabelValues(
            label: 'Chính tinh cung hạn',
            values: fortune.majorStars,
          ),
          const SizedBox(height: 7),
          _LabelValues(label: 'Sao lưu ngày', values: fortune.dailyStars),
        ],
        if (fortune.mutagenStars.isNotEmpty) ...[
          const SizedBox(height: 11),
          const Text(
            'TỨ HÓA LƯU NGÀY',
            style: TextStyle(
              color: Color(0xFFD7B66A),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: fortune.mutagenStars.entries
                .map(
                  (entry) => _Tag(
                    text:
                        '${entry.key.toUpperCase()}: ${entry.value.star} · ${entry.value.palace}',
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ],
    ),
  );

  static bool _negative(String value) {
    final text = value.toLowerCase();
    return text.contains('xung') ||
        text.contains('hại') ||
        text.contains('khắc');
  }
}

class _Relation extends StatelessWidget {
  const _Relation({
    required this.title,
    required this.text,
    required this.positive,
  });
  final String title;
  final String text;
  final bool positive;
  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF52DCA6) : const Color(0xFFFF8994);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
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
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE5DBC5),
                fontSize: 10.5,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabelValues extends StatelessWidget {
  const _LabelValues({required this.label, required this.values});
  final String label;
  final List<String> values;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 112,
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFFBEB08D), fontSize: 10),
        ),
      ),
      Expanded(
        child: Text(
          values.isEmpty ? '—' : values.join(' · '),
          style: const TextStyle(
            color: Color(0xFFFFD77C),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFF10283A),
      border: Border.all(color: const Color(0xFF8B6A2C)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Color(0xFFFFD77C), fontSize: 9),
    ),
  );
}

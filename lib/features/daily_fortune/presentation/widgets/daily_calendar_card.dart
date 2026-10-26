import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';

class DailyCalendarCard extends StatelessWidget {
  const DailyCalendarCard({required this.fortune, super.key});
  final DailyFortune fortune;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 13, 12, 14),
    decoration: BoxDecoration(
      color: const Color(0xF2071929),
      border: Border.all(color: const Color(0xFFD5A441), width: 1.2),
      borderRadius: BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(
          color: Color(0x88000000),
          blurRadius: 9,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF102538),
            border: Border.all(color: const Color(0xFFC89532)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'ÂM LỊCH:  '),
                TextSpan(
                  text: _lunarLabel(fortune.lunarDate),
                  style: const TextStyle(color: Color(0xFFFFE3A2)),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFC947),
              fontFamily: 'serif',
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 11),
        const Divider(color: Color(0x557F672F), height: 1),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _CanChiTile(label: 'NĂM', value: fortune.canChiYear),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _CanChiTile(label: 'THÁNG', value: fortune.canChiMonth),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _CanChiTile(label: 'NGÀY', value: fortune.canChiDay),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _CanChiTile(label: 'GIỜ', value: fortune.canChiHour),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _InfoPanel(
          children: [
            _InfoLine(
              label: 'Nạp âm:',
              value: fortune.napAm,
              badge: fortune.dayElement,
            ),
            const SizedBox(height: 8),
            _InfoLine(label: 'Tiết khí:', value: fortune.solarTerm),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DetailTile(
                title: 'TRỰC NGÀY',
                status: fortune.dayRating,
                value: fortune.dayOfficer,
                description: fortune.dayOfficerDescription,
                good: _isGood(fortune.dayRating),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _DetailTile(
                title: 'NHỊ THẬP BÁT TÚ',
                status: fortune.lunarMansionRating,
                value: fortune.lunarMansion,
                description: fortune.lunarMansionDescription,
                good: _isGood(fortune.lunarMansionRating),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  static bool _isGood(String? value) {
    final text = value?.toLowerCase() ?? '';
    return text.contains('tốt') ||
        text.contains('cát') ||
        text.contains('hoàng');
  }

  static String _lunarLabel(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return 'Đang cập nhật';
    return value.replaceAll('(Âm lịch)', '').trim();
  }
}

class _CanChiTile extends StatelessWidget {
  const _CanChiTile({required this.label, required this.value});
  final String label;
  final String? value;
  @override
  Widget build(BuildContext context) => Container(
    height: 77,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0xFF0A1D2E),
      border: Border.all(color: const Color(0xFFB8862D)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFBBAA87),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value ?? '—',
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFFFFD574),
              fontFamily: 'serif',
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF0A1D2E),
      border: Border.all(color: const Color(0xFF9C742C)),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value, this.badge});
  final String label;
  final String? value;
  final String? badge;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB8AA90),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          value ?? 'Đang cập nhật',
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFFFD778),
            fontFamily: 'serif',
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      if (badge?.isNotEmpty == true) ...[
        const SizedBox(width: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB98727)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Hành $badge',
            style: const TextStyle(
              color: Color(0xFFFFC947),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ],
  );
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.title,
    required this.status,
    required this.value,
    required this.description,
    required this.good,
  });
  final String title;
  final String? status;
  final String? value;
  final String? description;
  final bool good;
  @override
  Widget build(BuildContext context) {
    final accent = good ? const Color(0xFF27D89B) : const Color(0xFFFFAD2E);
    return Container(
      constraints: const BoxConstraints(minHeight: 146),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1D2E),
        border: Border.all(color: const Color(0xFF9C742C)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFFB8AA90),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          if (status?.isNotEmpty == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .13),
                border: Border.all(color: accent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status!,
                style: TextStyle(
                  color: accent,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          const SizedBox(height: 7),
          Text(
            value ?? 'Đang cập nhật',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFE1A0),
              fontFamily: 'serif',
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description ?? 'Dữ liệu đang được backend cập nhật.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD0C4AA),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

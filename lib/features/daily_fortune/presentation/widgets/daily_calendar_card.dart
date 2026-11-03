import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';

const _nightTop = Color(0xFF071827);
const _nightBottom = Color(0xFF09283B);
const _gold = Color(0xFFD4A33B);
const _goldLight = Color(0xFFF4D27B);
const _cream = Color(0xFFF2DFC0);
const _muted = Color(0xFFC8B994);

class DailyCalendarCard extends StatelessWidget {
  const DailyCalendarCard({required this.fortune, super.key});
  final DailyFortune fortune;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 13, 12, 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_nightTop, _nightBottom],
      ),
      border: Border.all(color: _gold, width: 1.45),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        _LunarDatePill(label: _lunarLabel(fortune.lunarDate)),
        const SizedBox(height: 7),
        const _OrnamentDivider(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _CanChiTile(label: 'NĂM', value: fortune.canChiYear),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _CanChiTile(label: 'THÁNG', value: fortune.canChiMonth),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _CanChiTile(label: 'NGÀY', value: fortune.canChiDay),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _CanChiTile(label: 'GIỜ', value: fortune.canChiHour),
            ),
          ],
        ),
        const SizedBox(height: 9),
        _InfoPanel(
          napAm: fortune.napAm,
          element: fortune.dayElement,
          solarTerm: fortune.solarTerm,
        ),
        const SizedBox(height: 9),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 330;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    height: compact ? 152 : 132,
                    child: _DetailTile(
                      title: 'TRỰC NGÀY',
                      status: fortune.dayRating,
                      value: fortune.dayOfficer,
                      description: fortune.dayOfficerDescription,
                      good: _isGood(fortune.dayRating),
                      compact: compact,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: SizedBox(
                    height: compact ? 152 : 132,
                    child: _DetailTile(
                      title: 'NHỊ THẬP BÁT TÚ',
                      status: fortune.lunarMansionRating,
                      value: fortune.lunarMansion,
                      description: fortune.lunarMansionDescription,
                      good: _isGood(fortune.lunarMansionRating),
                      compact: compact,
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

class _LunarDatePill extends StatelessWidget {
  const _LunarDatePill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xB3071A29),
      border: Border.all(color: _gold, width: 1.2),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'ÂM LỊCH:  '),
          TextSpan(
            text: label,
            style: const TextStyle(color: Color(0xFFFFE5A3)),
          ),
        ],
      ),
      maxLines: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: _goldLight,
        fontFamily: 'serif',
        fontSize: 14.5,
        height: 1,
        fontWeight: FontWeight.w900,
        letterSpacing: .1,
      ),
    ),
  );
}

class _OrnamentDivider extends StatelessWidget {
  const _OrnamentDivider();
  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 10,
    width: double.infinity,
    child: CustomPaint(painter: _GoldDividerPainter()),
  );
}

class _GoldDividerPainter extends CustomPainter {
  const _GoldDividerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x887F642D)
      ..strokeWidth = .8;
    final center = size.width / 2;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(center - 15, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center + 15, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    final star = Path()
      ..moveTo(center, 0)
      ..lineTo(center + 3, size.height / 2 - 3)
      ..lineTo(center + 9, size.height / 2)
      ..lineTo(center + 3, size.height / 2 + 3)
      ..lineTo(center, size.height)
      ..lineTo(center - 3, size.height / 2 + 3)
      ..lineTo(center - 9, size.height / 2)
      ..lineTo(center - 3, size.height / 2 - 3)
      ..close();
    canvas.drawPath(star, Paint()..color = _goldLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CanChiTile extends StatelessWidget {
  const _CanChiTile({required this.label, required this.value});
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Container(
    height: 76,
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
    decoration: BoxDecoration(
      color: const Color(0xA8071B2B),
      border: Border.all(color: _gold, width: 1.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: .25,
          ),
        ),
        const SizedBox(height: 4),
        const _ShortGoldLine(),
        const SizedBox(height: 5),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value?.trim().isNotEmpty == true ? value! : '—',
              maxLines: 1,
              style: const TextStyle(
                color: _goldLight,
                fontFamily: 'serif',
                fontSize: 15.5,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ShortGoldLine extends StatelessWidget {
  const _ShortGoldLine();
  @override
  Widget build(BuildContext context) => Container(
    width: 43,
    height: .7,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.transparent, _gold, Colors.transparent],
      ),
    ),
  );
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.napAm,
    required this.element,
    required this.solarTerm,
  });
  final String? napAm;
  final String? element;
  final String? solarTerm;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: CustomPaint(painter: const _MountainPainter(opacity: .28)),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 9, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0x8C071B2B),
          border: Border.all(color: _gold, width: 1.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoLine(
              icon: Icons.balance_outlined,
              label: 'Nạp âm:',
              value: napAm,
              badge: element,
            ),
            const SizedBox(height: 7),
            _InfoLine(
              icon: Icons.air_rounded,
              label: 'Tiết khí:',
              value: solarTerm,
            ),
          ],
        ),
      ),
    ],
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
  });
  final IconData icon;
  final String label;
  final String? value;
  final String? badge;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Wrap(
      spacing: 7,
      runSpacing: 7,
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(width: 22, child: Icon(icon, color: _gold, size: 19)),
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontFamily: 'serif',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value?.trim().isNotEmpty == true ? value! : 'Đang cập nhật',
          style: const TextStyle(
            color: _cream,
            fontFamily: 'serif',
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (badge?.isNotEmpty == true)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0x99091C2B),
              border: Border.all(color: _gold),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Hành $badge',
              style: const TextStyle(
                color: _goldLight,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    ),
  );
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.title,
    required this.status,
    required this.value,
    required this.description,
    required this.good,
    required this.compact,
  });
  final String title;
  final String? status;
  final String? value;
  final String? description;
  final bool good;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = good ? const Color(0xFF36DCB6) : const Color(0xFFD69412);
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: const _MountainPainter(opacity: .42)),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            compact ? 8 : 10,
            9,
            compact ? 8 : 10,
            8,
          ),
          decoration: BoxDecoration(
            color: const Color(0x76051728),
            border: Border.all(color: _gold, width: 1.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DecoratedTitle(title: title, compact: compact),
              const SizedBox(height: 7),
              if (status?.isNotEmpty == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .18),
                    border: Border.all(color: accent, width: 1.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    status!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: good
                          ? const Color(0xFF8BF2D6)
                          : const Color(0xFFFFD173),
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                value?.trim().isNotEmpty == true ? value! : 'Đang cập nhật',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _goldLight,
                  fontFamily: 'serif',
                  fontSize: compact ? 18 : 20,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  description?.trim().isNotEmpty == true
                      ? description!
                      : 'Dữ liệu đang được cập nhật.',
                  maxLines: compact ? 6 : 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _cream,
                    fontSize: compact ? 9.5 : 10.5,
                    height: 1.3,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DecoratedTitle extends StatelessWidget {
  const _DecoratedTitle({required this.title, required this.compact});
  final String title;
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox(
        width: 6,
        height: 6,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _gold),
              bottom: BorderSide(color: _gold),
            ),
          ),
        ),
      ),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          title,
          maxLines: compact ? 2 : 1,
          style: TextStyle(
            color: _muted,
            fontFamily: 'serif',
            fontSize: compact ? 8.5 : 9.5,
            height: 1.05,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      const SizedBox(width: 5),
      if (compact)
        const SizedBox(width: 8, child: _ShortGoldLine())
      else
        const Expanded(child: _ShortGoldLine()),
    ],
  );
}

class _MountainPainter extends CustomPainter {
  const _MountainPainter({required this.opacity});
  final double opacity;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gold.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .65;
    final base = size.height - 3;
    final path = Path()..moveTo(size.width * .42, base);
    path.lineTo(size.width * .56, base - size.height * .12);
    path.lineTo(size.width * .65, base - size.height * .08);
    path.lineTo(size.width * .76, base - size.height * .28);
    path.lineTo(size.width * .83, base - size.height * .19);
    path.lineTo(size.width * .91, base - size.height * .36);
    path.lineTo(size.width, base - size.height * .12);
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      paint..color = _gold.withValues(alpha: opacity * .55),
    );
  }

  @override
  bool shouldRepaint(covariant _MountainPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

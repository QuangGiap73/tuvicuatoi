import 'package:flutter/material.dart';

import '../../domain/chart_result.dart';

class ChartPalaceBoard extends StatelessWidget {
  const ChartPalaceBoard({required this.result, this.onPalaceTap, super.key});

  final ChartResult result;
  final ValueChanged<ChartPalace>? onPalaceTap;

  @override
  Widget build(BuildContext context) {
    final palaces = result.palaces;
    if (palaces.length < 12) {
      return _CompactGrid(result: result, onTap: onPalaceTap);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 370) {
          return _CompactGrid(result: result, onTap: onPalaceTap);
        }
        const gap = 5.0;
        final cardWidth = (constraints.maxWidth - gap * 3) / 4;
        const cardHeight = 132.0;
        return Column(
          children: [
            _PalaceRow(
              palaces: palaces.sublist(0, 4),
              width: cardWidth,
              height: cardHeight,
              gap: gap,
              onTap: onPalaceTap,
            ),
            const SizedBox(height: gap),
            SizedBox(
              height: cardHeight * 2 + gap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: Column(
                      children: [
                        Expanded(
                          child: _PalaceCard(
                            palace: palaces[4],
                            onTap: onPalaceTap,
                          ),
                        ),
                        const SizedBox(height: gap),
                        Expanded(
                          child: _PalaceCard(
                            palace: palaces[5],
                            onTap: onPalaceTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(child: _CenterSummary(result: result)),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: cardWidth,
                    child: Column(
                      children: [
                        Expanded(
                          child: _PalaceCard(
                            palace: palaces[6],
                            onTap: onPalaceTap,
                          ),
                        ),
                        const SizedBox(height: gap),
                        Expanded(
                          child: _PalaceCard(
                            palace: palaces[7],
                            onTap: onPalaceTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: gap),
            _PalaceRow(
              palaces: palaces.sublist(8, 12),
              width: cardWidth,
              height: cardHeight,
              gap: gap,
              onTap: onPalaceTap,
            ),
          ],
        );
      },
    );
  }
}

class _PalaceRow extends StatelessWidget {
  const _PalaceRow({
    required this.palaces,
    required this.width,
    required this.height,
    required this.gap,
    this.onTap,
  });
  final List<ChartPalace> palaces;
  final double width;
  final double height;
  final double gap;
  final ValueChanged<ChartPalace>? onTap;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < palaces.length; index++) ...[
        SizedBox(
          width: width,
          height: height,
          child: _PalaceCard(palace: palaces[index], onTap: onTap),
        ),
        if (index != palaces.length - 1) SizedBox(width: gap),
      ],
    ],
  );
}

class _PalaceCard extends StatelessWidget {
  const _PalaceCard({required this.palace, this.onTap});
  final ChartPalace palace;
  final ValueChanged<ChartPalace>? onTap;

  @override
  Widget build(BuildContext context) {
    final mainStars = palace.mainStars
        .map((star) => '${star.name} ${star.tag}')
        .join('\n');
    return Material(
      color: const Color(0xFFF6E7BF),
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(palace),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 6, 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: palace.isThan
                  ? const Color(0xFF3FD3A4)
                  : const Color(0xFFD1A247),
              width: palace.isThan ? 2 : 1.2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      palace.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF4B3019),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (palace.daiHanAge != null)
                    Text(
                      '${palace.daiHanAge}',
                      style: const TextStyle(
                        color: Color(0xFF8D261D),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                mainStars.isEmpty ? 'Vô Chính Diệu' : mainStars,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9D2D25),
                  fontFamily: 'serif',
                  fontSize: 9.5,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _StarWrap(good: palace.luckyStars, bad: palace.badStars),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    palace.branch,
                    style: const TextStyle(
                      color: Color(0xFF5B422B),
                      fontSize: 7,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      palace.vongTrangSinh,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5B422B),
                        fontSize: 7,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarWrap extends StatelessWidget {
  const _StarWrap({required this.good, required this.bad});
  final List<String> good;
  final List<String> bad;

  @override
  Widget build(BuildContext context) {
    final stars = [
      ...good.take(3).map((value) => (value, true)),
      ...bad.take(3).map((value) => (value, false)),
    ];
    return Align(
      alignment: Alignment.topCenter,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: stars
            .map(
              (star) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                color: star.$2
                    ? const Color(0xFFD6F0D9)
                    : const Color(0xFFF5CDD0),
                child: Text(
                  star.$1,
                  maxLines: 1,
                  style: TextStyle(
                    color: star.$2
                        ? const Color(0xFF16805D)
                        : const Color(0xFFB12B36),
                    fontSize: 6.5,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _CenterSummary extends StatelessWidget {
  const _CenterSummary({required this.result});
  final ChartResult result;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF7E7BF),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: const Color(0xFFD1A247), width: 1.3),
    ),
    child: Column(
      children: [
        const Text(
          'LÁ SỐ TỬ VI',
          style: TextStyle(
            color: Color(0xFF79532B),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        Text(
          ChartResultHeaderName.firstName(result.fullName),
          style: const TextStyle(
            color: Color(0xFF3A2514),
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          'Sinh: ${result.solarDate} (${result.solarTime})',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF4B3823), fontSize: 8),
        ),
        Text(
          'Năm xem: ${result.namXem}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF4B3823), fontSize: 8),
        ),
        const Divider(color: Color(0xFFB98A42), height: 16),
        _InfoLine('Âm dương', result.amDuong),
        _InfoLine('Bản mệnh', result.menh),
        _InfoLine('Cục số', result.cuc),
        _InfoLine('Chủ Mệnh', result.chuMenh),
        _InfoLine('Chủ Thân', result.chuThan),
        _InfoLine('Thân cư', result.thanCu),
      ],
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: const TextStyle(color: Color(0xFF65492E), fontSize: 8),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF8C2A22),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CompactGrid extends StatelessWidget {
  const _CompactGrid({required this.result, this.onTap});
  final ChartResult result;
  final ValueChanged<ChartPalace>? onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _CenterSummary(result: result),
      const SizedBox(height: 6),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: result.palaces.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 135,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemBuilder: (context, index) =>
            _PalaceCard(palace: result.palaces[index], onTap: onTap),
      ),
    ],
  );
}

abstract final class ChartResultHeaderName {
  static String firstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Lá số' : parts.last;
  }
}

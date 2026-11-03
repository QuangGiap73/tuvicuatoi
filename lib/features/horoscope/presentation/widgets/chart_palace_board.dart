import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/chart_result.dart';

class ChartPalaceBoard extends StatelessWidget {
  const ChartPalaceBoard({required this.result, this.onPalaceTap, super.key});

  final ChartResult result;
  final ValueChanged<ChartPalace>? onPalaceTap;

  @override
  Widget build(BuildContext context) {
    if (result.palaces.length < 12) {
      return _CompactGrid(result: result, onTap: onPalaceTap);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final boardWidth = viewportWidth > 720 ? 720.0 : viewportWidth;
        final board = _ClassicBoard(
          width: boardWidth,
          result: result,
          onTap: onPalaceTap,
        );
        return Align(alignment: Alignment.topCenter, child: board);
      },
    );
  }
}

class _ClassicBoard extends StatelessWidget {
  const _ClassicBoard({
    required this.width,
    required this.result,
    required this.onTap,
  });

  final double width;
  final ChartResult result;
  final ValueChanged<ChartPalace>? onTap;

  @override
  Widget build(BuildContext context) {
    final gap = (width * .012).clamp(3.0, 8.0);
    final cardWidth = (width - gap * 3) / 4;
    final compact = width < 430;
    final cardHeight = cardWidth * (compact ? 1.16 : 1.18);
    final palaces = result.palaces;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          _PalaceRow(
            palaces: palaces.sublist(0, 4),
            width: cardWidth,
            height: cardHeight,
            gap: gap,
            onTap: onTap,
          ),
          SizedBox(height: gap),
          SizedBox(
            height: cardHeight * 2 + gap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _PalaceColumn(
                    first: palaces[4],
                    second: palaces[5],
                    gap: gap,
                    onTap: onTap,
                  ),
                ),
                SizedBox(width: gap),
                Expanded(child: _CenterSummary(result: result)),
                SizedBox(width: gap),
                SizedBox(
                  width: cardWidth,
                  child: _PalaceColumn(
                    first: palaces[6],
                    second: palaces[7],
                    gap: gap,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: gap),
          _PalaceRow(
            palaces: palaces.sublist(8, 12),
            width: cardWidth,
            height: cardHeight,
            gap: gap,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _PalaceColumn extends StatelessWidget {
  const _PalaceColumn({
    required this.first,
    required this.second,
    required this.gap,
    required this.onTap,
  });

  final ChartPalace first;
  final ChartPalace second;
  final double gap;
  final ValueChanged<ChartPalace>? onTap;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: _PalaceCard(palace: first, onTap: onTap),
      ),
      SizedBox(height: gap),
      Expanded(
        child: _PalaceCard(palace: second, onTap: onTap),
      ),
    ],
  );
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

  Future<void> _openPreview(BuildContext context) async {
    final openDetail = await Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: const Color(0xB300050A),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _PalacePreview(palace: palace),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
    if (openDetail == true && context.mounted) onTap?.call(palace);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = (constraints.maxWidth / 112).clamp(.58, 1.28);
      final mainStars = palace.mainStars
          .take(3)
          .map((star) => '${star.name} ${star.tag}'.trim())
          .join('\n');
      return Hero(
        tag: _palaceHeroTag(palace),
        createRectTween: (begin, end) =>
            MaterialRectArcTween(begin: begin, end: end),
        child: Material(
          color: const Color(0xFFF6E7BF),
          borderRadius: BorderRadius.circular(7),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openPreview(context),
            child: Container(
              padding: EdgeInsets.fromLTRB(6 * scale, 5 * scale, 6 * scale, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: palace.isThan
                      ? const Color(0xFF329A72)
                      : const Color(0xFFD1A247),
                  width: palace.isThan ? 2 : 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          palace.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: const Color(0xFF4B3019),
                            fontSize: 8.5 * scale,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (palace.daiHanAge != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3 * scale,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF916123),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${palace.daiHanAge}',
                            style: TextStyle(
                              color: const Color(0xFFFFF1C7),
                              fontSize: 6.8 * scale,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    palace.canChi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF6D4E31),
                      fontSize: 7 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Text(
                    mainStars.isEmpty ? 'Vô Chính Diệu' : mainStars,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF9D2D25),
                      fontFamily: 'serif',
                      fontSize: 9 * scale,
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 3 * scale),
                  Expanded(
                    child: _StarColumns(
                      good: palace.luckyStars,
                      bad: palace.badStars,
                      scale: scale,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        palace.branch,
                        style: TextStyle(
                          color: const Color(0xFF5B422B),
                          fontSize: 7 * scale,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          palace.vongTrangSinh,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0xFF5B422B),
                            fontSize: 7 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _StarColumns extends StatelessWidget {
  const _StarColumns({
    required this.good,
    required this.bad,
    required this.scale,
  });

  final List<String> good;
  final List<String> bad;
  final double scale;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _StarList(
          stars: good,
          color: const Color(0xFF16805D),
          scale: scale,
        ),
      ),
      const SizedBox(width: 2),
      Expanded(
        child: _StarList(
          stars: bad,
          color: const Color(0xFFB12B36),
          scale: scale,
          alignRight: true,
        ),
      ),
    ],
  );
}

class _StarList extends StatelessWidget {
  const _StarList({
    required this.stars,
    required this.color,
    required this.scale,
    this.alignRight = false,
  });

  final List<String> stars;
  final Color color;
  final double scale;
  final bool alignRight;

  @override
  Widget build(BuildContext context) => Text(
    stars.take(5).join('\n'),
    maxLines: 5,
    overflow: TextOverflow.ellipsis,
    textAlign: alignRight ? TextAlign.right : TextAlign.left,
    style: TextStyle(
      color: color,
      fontSize: 6.7 * scale,
      height: 1.16,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _PalacePreview extends StatelessWidget {
  const _PalacePreview({required this.palace});

  final ChartPalace palace;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final availableWidth = size.width - 32;
    final availableByHeight = (size.height - 150) * .92;
    final cardWidth = [
      420.0,
      availableWidth,
      availableByHeight,
    ].reduce((left, right) => left < right ? left : right).clamp(260.0, 420.0);
    return PopScope(
      child: SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: Navigator.of(context).pop,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: _palaceHeroTag(palace),
                      createRectTween: (begin, end) =>
                          MaterialRectArcTween(begin: begin, end: end),
                      child: _OrnatePreviewCard(
                        palace: palace,
                        width: cardWidth,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: cardWidth * .86,
                      child: _OrnatePreviewButton(palace: palace),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrnatePreviewCard extends StatelessWidget {
  const _OrnatePreviewCard({required this.palace, required this.width});

  final ChartPalace palace;
  final double width;

  @override
  Widget build(BuildContext context) {
    final scale = width / 360;
    final primaryStars = palace.mainStars
        .map((star) => '${star.name} ${star.tag}'.trim())
        .join('  ·  ');
    final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox(
      width: width,
      height: width * 1.02,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            RepaintBoundary(
              child: Image.asset(
                MysticAssets.horoscopeCenterFrame,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                34 * scale,
                25 * scale,
                34 * scale,
                30 * scale,
              ),
              child: Column(
                children: [
                  _OrnateTitle(label: 'CUNG ${palace.name}', scale: scale),
                  SizedBox(height: 8 * scale),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _OrnateBadge(
                      label: palace.daiHanAge == null
                          ? palace.canChi
                          : 'Cung ${palace.daiHanAge}',
                      scale: scale,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      primaryStars.isEmpty ? 'Vô Chính Diệu' : primaryStars,
                      maxLines: 1,
                      style: TextStyle(
                        color: const Color(0xFF9E2E25),
                        fontFamily: 'serif',
                        fontSize: 27 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: 18 * scale),
                    color: const Color(0xFFD6A64B),
                  ),
                  SizedBox(height: 10 * scale),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _OrnateStarColumn(
                            stars: palace.luckyStars,
                            color: const Color(0xFF138052),
                            scale: scale,
                          ),
                        ),
                        Container(
                          width: 1,
                          margin: EdgeInsets.symmetric(horizontal: 8 * scale),
                          color: const Color(0x33B88637),
                        ),
                        Expanded(
                          child: _OrnateStarColumn(
                            stars: palace.badStars,
                            color: const Color(0xFFC22628),
                            scale: scale,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: const Color(0x55C99A45)),
                  SizedBox(height: 9 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: _OrnateMeta(
                          label: 'ĐỊA CHI',
                          value: palace.branch,
                        ),
                      ),
                      _OrnateDivider(scale: scale),
                      Expanded(
                        child: _OrnateMeta(
                          label: 'VÒNG TRƯỜNG SINH',
                          value: palace.vongTrangSinh,
                        ),
                      ),
                      _OrnateDivider(scale: scale),
                      Expanded(
                        child: _OrnateMeta(
                          label: 'THÁNG HẠN',
                          value: palace.thangHan.trim().isEmpty
                              ? palace.element
                              : palace.thangHan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 7 * scale,
              top: 7 * scale,
              child: Material(
                color: const Color(0xFF76501E),
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFFFD77C), width: 1.3),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: Navigator.of(context).pop,
                  child: SizedBox.square(
                    dimension: 38 * scale,
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFFFFEAB4),
                      size: 25 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnateTitle extends StatelessWidget {
  const _OrnateTitle({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 7 * scale),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFEDBC), Color(0xFFFFD46D), Color(0xFFFFEDBC)],
      ),
      borderRadius: BorderRadius.circular(24 * scale),
      border: Border.all(color: const Color(0xFFC68A27), width: 1.4),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xFF66431E),
        fontFamily: 'serif',
        fontSize: 17 * scale,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _OrnateBadge extends StatelessWidget {
  const _OrnateBadge({required this.label, required this.scale});

  final String label;
  final double scale;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE5A0),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFC68A27)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: const Color(0xFF76501E),
        fontSize: 10 * scale,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _OrnateStarColumn extends StatelessWidget {
  const _OrnateStarColumn({
    required this.stars,
    required this.color,
    required this.scale,
  });

  final List<String> stars;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Text(
      stars.isEmpty ? 'Không có' : stars.join('\n'),
      textAlign: TextAlign.center,
      style: TextStyle(
        color: color,
        fontFamily: 'serif',
        fontSize: 16 * scale,
        height: 1.32,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _OrnateDivider extends StatelessWidget {
  const _OrnateDivider({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 20 * scale, color: const Color(0x55C99A45));
}

class _OrnateMeta extends StatelessWidget {
  const _OrnateMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF9A7544),
          fontSize: 7.5,
          fontWeight: FontWeight.w800,
          letterSpacing: .25,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF704D2A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _OrnatePreviewButton extends StatelessWidget {
  const _OrnatePreviewButton({required this.palace});

  final ChartPalace palace;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFFD56D), Color(0xFFFFF0B2), Color(0xFFFFCD56)],
      ),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0xFFC58926), width: 1.6),
    ),
    child: Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => Navigator.of(context).pop(true),
        child: const SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_rounded, color: Color(0xFF714916)),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Xem luận giải chi tiết',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF5A3812),
                    fontFamily: 'serif',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF714916)),
            ],
          ),
        ),
      ),
    ),
  );
}

String _palaceHeroTag(ChartPalace palace) =>
    'chart-palace-${palace.id}-${palace.name}';

class _CenterSummary extends StatelessWidget {
  const _CenterSummary({required this.result});

  final ChartResult result;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = (constraints.maxWidth / 225).clamp(.58, 1.35);
      final cacheWidth =
          (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round();
      return Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: Image.asset(
              MysticAssets.horoscopeCenterFrame,
              fit: BoxFit.fill,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              19 * scale,
              24 * scale,
              19 * scale,
              22 * scale,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 2 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xBFFFF0C8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC9973E)),
                  ),
                  child: Text(
                    'LÁ SỐ TỬ VI',
                    style: TextStyle(
                      color: const Color(0xFF79532B),
                      fontSize: 8.5 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .8,
                    ),
                  ),
                ),
                SizedBox(height: 4 * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    ChartResultHeaderName.firstName(result.fullName),
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF3A2514),
                      fontFamily: 'serif',
                      fontSize: 23 * scale,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: 5 * scale),
                Text(
                  'Sinh: ${result.solarDate} (${result.solarTime})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4B3823),
                    fontSize: 7.8 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Giờ ${result.hourBranch}  •  ${result.gender}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4B3823),
                    fontSize: 7.5 * scale,
                  ),
                ),
                Text(
                  'Năm xem: ${result.namXem}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF4B3823),
                    fontSize: 7.5 * scale,
                  ),
                ),
                Divider(color: const Color(0xFFB98A42), height: 14 * scale),
                _InfoLine('Âm dương', result.amDuong, scale),
                _InfoLine('Bản mệnh', result.menh, scale),
                _InfoLine('Cục số', result.cuc, scale),
                _InfoLine('Chủ Mệnh', result.chuMenh, scale),
                _InfoLine('Chủ Thân', result.chuThan, scale),
                _InfoLine('Thân cư', result.thanCu, scale),
                const Spacer(),
                Text(
                  result.menhCucBinhHoa,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF805B2E),
                    fontSize: 7.3 * scale,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine(this.label, this.value, this.scale);

  final String label;
  final String value;
  final double scale;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 1.3 * scale),
    child: Row(
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(
              color: const Color(0xFF65492E),
              fontSize: 7.5 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF8C2A22),
              fontSize: 7.5 * scale,
              fontWeight: FontWeight.w800,
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
      SizedBox(height: 300, child: _CenterSummary(result: result)),
      const SizedBox(height: 6),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: result.palaces.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 150,
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

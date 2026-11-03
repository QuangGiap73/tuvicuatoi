import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../horoscope/domain/chart_result.dart';
import '../../domain/palace_detail_models.dart';

const _ink = Color(0xFF4A2F18);
const _mutedInk = Color(0xFF806238);

class PalaceHeroCard extends StatelessWidget {
  const PalaceHeroCard({required this.palace, super.key});
  final ChartPalace palace;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cacheWidth =
          (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round();
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxWidth / (1693 / 594),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  MysticAssets.palaceDetailBanner,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  cacheWidth: cacheWidth,
                  filterQuality: FilterQuality.medium,
                ),
              ),
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xDFFFF1CA),
                        Color(0x55FFF0C9),
                        Colors.transparent,
                      ],
                      stops: [0, .48, .78],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 15, 13, 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${palace.name.toUpperCase()} (${palace.branch})',
                        style: const TextStyle(
                          color: _ink,
                          fontFamily: 'serif',
                          fontSize: 17,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(color: Color(0xAAFFF1C6), blurRadius: 5),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 255),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'Hành ${palace.element}'),
                              if (palace.mainStars.isNotEmpty) ...[
                                const TextSpan(text: '  •  Chính tinh: '),
                                TextSpan(
                                  text: palace.mainStars
                                      .map((star) => star.name)
                                      .join(', '),
                                  style: const TextStyle(
                                    color: Color(0xFFB42D39),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          style: const TextStyle(
                            color: _mutedInk,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Color(0xAAFFF1C6), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 5,
                        children: [
                          if (palace.isThan) const _TinyBadge('THÂN CƯ'),
                          if (palace.vongTrangSinh.isNotEmpty)
                            _TinyBadge(palace.vongTrangSinh.toUpperCase()),
                          if (palace.thangHan.isNotEmpty)
                            _TinyBadge(palace.thangHan.toUpperCase()),
                        ],
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

class MainStarsSection extends StatelessWidget {
  const MainStarsSection({required this.stars, required this.rules, super.key});

  final List<ChartStar> stars;
  final List<PalaceRule> rules;

  @override
  Widget build(BuildContext context) => PalacePaperSection(
    title: 'Chính tinh',
    child: stars.isEmpty
        ? const Text(
            'Vô Chính Diệu',
            style: TextStyle(color: _mutedInk, fontSize: 12),
          )
        : Column(
            children: [
              for (var index = 0; index < stars.length; index++) ...[
                _MainStarTile(star: stars[index], rule: _ruleFor(stars[index])),
                if (index != stars.length - 1)
                  const Divider(color: Color(0x55A97827), height: 15),
              ],
            ],
          ),
  );

  PalaceRule? _ruleFor(ChartStar star) {
    final name = star.name.toLowerCase();
    for (final rule in rules) {
      if (rule.stars.any((value) => value.toLowerCase() == name) ||
          rule.name.toLowerCase().contains(name)) {
        return rule;
      }
    }
    return rules.isEmpty ? null : rules.first;
  }
}

class StarsGroupSection extends StatelessWidget {
  const StarsGroupSection({
    required this.luckyStars,
    required this.badStars,
    super.key,
  });
  final List<String> luckyStars;
  final List<String> badStars;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PalacePaperSection(
        title: 'Cát tinh',
        child: _StarGroup(
          title: 'Cát tinh',
          stars: luckyStars,
          favorable: true,
          hideTitle: true,
        ),
      ),
      const SizedBox(height: 9),
      PalacePaperSection(
        title: 'Sát tinh',
        child: _StarGroup(
          title: 'Sát tinh',
          stars: badStars,
          favorable: false,
          hideTitle: true,
        ),
      ),
    ],
  );
}

List<String> _featuredNames(List<String> luckyStars, List<String> badStars) => [
  ...luckyStars.take(4),
  ...badStars.take(luckyStars.length >= 4 ? 0 : 4 - luckyStars.length),
];

class _StarGroup extends StatelessWidget {
  const _StarGroup({
    required this.title,
    required this.stars,
    required this.favorable,
    this.hideTitle = false,
  });

  final String title;
  final List<String> stars;
  final bool favorable;
  final bool hideTitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (!hideTitle) ...[
        _SectionLabel(title, danger: !favorable),
        const SizedBox(height: 6),
      ],
      if (stars.isEmpty)
        const Text('Không có', style: TextStyle(color: _mutedInk, fontSize: 11))
      else
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: stars
              .map((name) => PalaceStarChip(name: name, favorable: favorable))
              .toList(growable: false),
        ),
    ],
  );
}

class FeaturedStarsSection extends StatelessWidget {
  const FeaturedStarsSection({
    this.featuredStars = const [],
    required this.luckyStars,
    required this.badStars,
    super.key,
  });
  final List<String> featuredStars;
  final List<String> luckyStars;
  final List<String> badStars;

  @override
  Widget build(BuildContext context) {
    final names = featuredStars.isEmpty
        ? _featuredNames(luckyStars, badStars)
        : featuredStars;
    final featured = names
        .map((name) => (name, !badStars.contains(name)))
        .toList(growable: false);
    if (featured.isEmpty) return const SizedBox.shrink();
    return PalacePaperSection(
      title: 'Phụ tinh nổi bật',
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: featured
            .map((star) => PalaceStarChip(name: star.$1, favorable: star.$2))
            .toList(growable: false),
      ),
    );
  }
}

class RelatedPalacesSection extends StatelessWidget {
  const RelatedPalacesSection({
    required this.palaces,
    required this.rules,
    super.key,
  });
  final List<ChartPalace> palaces;
  final List<TriadRule> rules;

  @override
  Widget build(BuildContext context) => PalacePaperSection(
    title: 'Tam phương tứ chính',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 6.0;
            final count = palaces.take(4).length;
            final columns = constraints.maxWidth >= 560
                ? count
                : count > 2
                ? 2
                : count;
            final width = count == 0
                ? constraints.maxWidth
                : (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final palace in palaces.take(4))
                  SizedBox(
                    width: width,
                    child: _RelatedPalaceCard(palace: palace),
                  ),
              ],
            );
          },
        ),
        if (rules.isNotEmpty && rules.first.meaning.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(
            rules.first.meaning,
            style: const TextStyle(
              color: _mutedInk,
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ],
    ),
  );
}

class FreeIntroductionSection extends StatelessWidget {
  const FreeIntroductionSection({required this.summary, super.key});
  final String? summary;

  @override
  Widget build(BuildContext context) => PalacePaperSection(
    title: 'Giới thiệu chung (miễn phí)',
    child: summary == null || summary!.trim().isEmpty
        ? const Text(
            'Máy chủ chưa cung cấp phần giới thiệu cho cung này.',
            style: TextStyle(color: _mutedInk, fontSize: 12, height: 1.4),
          )
        : Text(
            summary!,
            style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.45),
          ),
  );
}

class PalaceSummarySection extends StatelessWidget {
  const PalaceSummarySection({
    required this.palace,
    required this.relatedPalaces,
    super.key,
  });

  final ChartPalace palace;
  final List<ChartPalace> relatedPalaces;

  @override
  Widget build(BuildContext context) {
    final related = relatedPalaces
        .where((item) => item.id != palace.id)
        .map((item) => item.name)
        .take(3)
        .join(', ');
    final stars = palace.mainStars.map((star) => star.name).join(', ');
    final text = StringBuffer(
      '${palace.name} tại ${palace.branch} thuộc hành ${palace.element}',
    );
    if (stars.isNotEmpty) text.write(', có chính tinh $stars tọa thủ');
    if (related.isNotEmpty) {
      text.write('. Tam phương tứ chính liên kết với $related');
    }
    text.write(', tạo thành hệ thống tương hỗ khi luận giải cung này.');
    return PalacePaperSection(
      title: 'Tóm tắt luận giải',
      child: Text(
        text.toString(),
        style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.5),
      ),
    );
  }
}

class PalacePaperSection extends StatelessWidget {
  const PalacePaperSection({required this.child, this.title, super.key});
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
    decoration: BoxDecoration(
      color: const Color(0xF7FFF1CF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD09A38), width: 1.25),
      boxShadow: const [
        BoxShadow(
          color: Color(0x4D000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              Icon(
                _sectionIcon(title!),
                size: 20,
                color: _sectionColor(title!),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Text(
                  title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontFamily: 'serif',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                flex: 2,
                child: Divider(color: Color(0x88B88637), height: 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        child,
      ],
    ),
  );
}

IconData _sectionIcon(String title) {
  if (title.contains('Cát')) return Icons.energy_savings_leaf_rounded;
  if (title.contains('Sát')) return Icons.colorize_rounded;
  if (title.contains('Tam phương')) return Icons.temple_buddhist_rounded;
  if (title.contains('Tóm tắt')) return Icons.article_outlined;
  if (title.contains('Giới thiệu')) return Icons.card_giftcard_rounded;
  return Icons.auto_awesome_rounded;
}

Color _sectionColor(String title) {
  if (title.contains('Cát')) return const Color(0xFF338A58);
  if (title.contains('Sát')) return const Color(0xFFB9363A);
  return const Color(0xFF9A681D);
}

class PalaceStarChip extends StatelessWidget {
  const PalaceStarChip({
    required this.name,
    required this.favorable,
    super.key,
  });
  final String name;
  final bool favorable;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: favorable ? const Color(0xFFD9F2E7) : const Color(0xFFFFE1DC),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(
        color: favorable ? const Color(0xFF70BEA5) : const Color(0xFFE77C74),
      ),
    ),
    child: Text(
      name,
      style: TextStyle(
        color: favorable ? const Color(0xFF267660) : const Color(0xFFB92C38),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _MainStarTile extends StatefulWidget {
  const _MainStarTile({required this.star, required this.rule});
  final ChartStar star;
  final PalaceRule? rule;

  @override
  State<_MainStarTile> createState() => _MainStarTileState();
}

class _MainStarTileState extends State<_MainStarTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final star = widget.star;
    final rule = widget.rule;
    final explanation = rule?.summary.trim().isNotEmpty == true
        ? rule!.summary.trim()
        : rule?.content.trim() ?? '';
    final canExpand = explanation.length > 95;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 5,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9A2C36), Color(0xFF671F29)],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFFD9A440), width: 1.3),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFD978),
                size: 22,
              ),
            ),
            Text(
              star.name,
              style: const TextStyle(
                color: _ink,
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (star.tag.isNotEmpty) _StarBadge(star.tag),
            if (star.brightness.isNotEmpty)
              _StarBadge(star.brightness, danger: true),
          ],
        ),
        if (explanation.isNotEmpty) ...[
          const SizedBox(height: 4),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Text(
              explanation,
              maxLines: canExpand && !_expanded ? 2 : null,
              overflow: canExpand && !_expanded
                  ? TextOverflow.ellipsis
                  : TextOverflow.visible,
              style: const TextStyle(
                color: _mutedInk,
                fontSize: 10.8,
                height: 1.35,
              ),
            ),
          ),
          if (canExpand)
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 3, 2, 2),
                  child: Text(
                    _expanded ? 'Thu gọn' : 'Xem thêm',
                    style: const TextStyle(
                      color: Color(0xFF8E5C12),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ] else if (star.element.isNotEmpty || star.type.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            [
              star.element,
              star.type,
            ].where((value) => value.isNotEmpty).join(' • '),
            style: const TextStyle(color: _mutedInk, fontSize: 10.8),
          ),
        ],
      ],
    );
  }
}

class _RelatedPalaceCard extends StatelessWidget {
  const _RelatedPalaceCard({required this.palace});
  final ChartPalace palace;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 59),
    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFDDEDEF),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF9FBFC2)),
    ),
    child: Column(
      children: [
        Text(
          palace.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF526466),
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          palace.mainStars.isEmpty
              ? 'Vô Chính Diệu'
              : palace.mainStars.first.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF297274),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.danger = false});
  final String text;
  final bool danger;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: danger ? const Color(0xFFB92534) : _ink,
      fontSize: 12,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _StarBadge extends StatelessWidget {
  const _StarBadge(this.text, {this.danger = false});
  final String text;
  final bool danger;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: danger ? const Color(0xFFCC4A59) : const Color(0xFFAF347B),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xBFF8EBCB),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x88936A28)),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: _ink,
        fontSize: 7.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

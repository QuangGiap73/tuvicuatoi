import 'package:flutter/material.dart';

import '../../domain/daily_fortune.dart';

class FortuneLifeAspectsCard extends StatelessWidget {
  const FortuneLifeAspectsCard({required this.fortune, super.key});

  final DailyFortune fortune;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.business_center_rounded, 'CÔNG VIỆC · SỰ NGHIỆP', fortune.career),
      (Icons.savings_rounded, 'TÀI LỘC · TIỀN BẠC', fortune.wealth),
      (Icons.favorite_rounded, 'TÌNH CẢM · MỐI QUAN HỆ', fortune.love),
      (Icons.health_and_safety_rounded, 'SỨC KHỎE', fortune.health),
    ];
    return Container(
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
            '✦  BÌNH GIẢI 4 PHƯƠNG DIỆN CUỘC SỐNG',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              color: Color(0xFFFFD77C),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ...items.indexed.map(
            (entry) => Padding(
              padding: EdgeInsets.only(
                bottom: entry.$1 == items.length - 1 ? 0 : 8,
              ),
              child: _Aspect(
                icon: entry.$2.$1,
                title: entry.$2.$2,
                content: entry.$2.$3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Aspect extends StatefulWidget {
  const _Aspect({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String? content;

  @override
  State<_Aspect> createState() => _AspectState();
}

class _AspectState extends State<_Aspect> {
  static const _collapsedLines = 2;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF10283A),
      border: Border.all(color: const Color(0xFF785D2B)),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(widget.icon, size: 17, color: const Color(0xFFFFD77C)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Color(0xFFFFD77C),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              _ExpandableAspectText(
                text: widget.content?.trim().isNotEmpty == true
                    ? widget.content!.trim()
                    : 'Chưa có bình giải từ máy chủ.',
                expanded: _expanded,
                collapsedLines: _collapsedLines,
                onToggle: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ExpandableAspectText extends StatelessWidget {
  const _ExpandableAspectText({
    required this.text,
    required this.expanded,
    required this.collapsedLines,
    required this.onToggle,
  });

  static const _textStyle = TextStyle(
    color: Color(0xFFE5DBC5),
    fontSize: 10.5,
    height: 1.4,
  );

  final String text;
  final bool expanded;
  final int collapsedLines;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: _textStyle),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: collapsedLines,
      )..layout(maxWidth: constraints.maxWidth);
      final canExpand = painter.didExceedMaxLines;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: expanded ? null : collapsedLines,
            overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: _textStyle,
          ),
          if (canExpand) ...[
            const SizedBox(height: 3),
            Semantics(
              button: true,
              expanded: expanded,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    expanded ? 'Thu gọn' : 'Đọc thêm',
                    style: const TextStyle(
                      color: Color(0xFFFFD77C),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFFFD77C),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    },
  );
}

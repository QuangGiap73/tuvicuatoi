import 'package:flutter/material.dart';

class ArticleBodySliver extends StatelessWidget {
  const ArticleBodySliver({
    required this.title,
    required this.paragraphs,
    this.backgroundColor,
    this.horizontalPadding = 0,
    super.key,
  });

  final String title;
  final List<String> paragraphs;
  final Color? backgroundColor;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final items = paragraphs.where((item) => item.trim().isNotEmpty).toList();
    if (items.isNotEmpty && _plain(items.first) == _plain(title)) {
      items.removeAt(0);
    }
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final raw = items[index].trim();
        final level = raw.startsWith('## ')
            ? 2
            : raw.startsWith('# ')
            ? 1
            : 0;
        final text = level == 0
            ? raw
            : raw.replaceFirst(RegExp(r'^#{1,2}\s+'), '');
        return ColoredBox(
          color: backgroundColor ?? Colors.transparent,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              level > 0 && index > 0 ? 9 : 0,
              horizontalPadding,
              level > 0 ? 10 : 14,
            ),
            child: SelectableText(
              text,
              style: TextStyle(
                color: const Color(0xFF4D351F),
                fontFamily: level > 0 ? 'serif' : null,
                fontSize: level == 1
                    ? 22
                    : level == 2
                    ? 18
                    : 14.5,
                height: level > 0 ? 1.25 : 1.65,
                fontWeight: level > 0 ? FontWeight.w900 : FontWeight.w400,
              ),
            ),
          ),
        );
      },
    );
  }

  static String _plain(String value) =>
      value.replaceFirst(RegExp(r'^#{1,2}\s+'), '').trim().toLowerCase();
}

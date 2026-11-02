import 'package:flutter/material.dart';

import '../../domain/article_models.dart';
import 'article_network_image.dart';

const _gold = Color(0xFFD9AC4C);
const _paper = Color(0xFFF4E2B9);
const _ink = Color(0xFF452A13);

class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({
    required this.article,
    required this.onTap,
    super.key,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ArticleNetworkImage(url: article.imageUrl, cacheWidth: 1000),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x16000000), Color(0xE6000000)],
                    stops: [.25, 1],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryLabel(text: article.category),
                    const SizedBox(height: 7),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFFEDBA),
                        fontFamily: 'serif',
                        fontSize: 19,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                      ),
                    ),
                    const SizedBox(height: 5),
                    _ArticleMeta(article: article, light: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class ArticlePreviewCard extends StatelessWidget {
  const ArticlePreviewCard({
    required this.article,
    required this.onTap,
    super.key,
  });

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Material(
      color: _paper,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 132,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB98227), width: 1.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 112,
                child: ArticleNetworkImage(
                  url: article.imageUrl,
                  cacheWidth: 360,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 9, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CategoryLabel(text: article.category, compact: true),
                      const SizedBox(height: 5),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontFamily: 'serif',
                          fontSize: 14,
                          height: 1.18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF745C3E),
                          fontSize: 10,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _ArticleMeta(article: article),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF96641B),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.text, this.compact = false});
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 7 : 9,
      vertical: compact ? 2 : 3,
    ),
    decoration: BoxDecoration(
      color: compact ? const Color(0xFFE7BD63) : const Color(0xD98F5C0F),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _gold.withValues(alpha: .75)),
    ),
    child: Text(
      text.isEmpty ? 'Cẩm nang' : text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: compact ? _ink : const Color(0xFFFFEDBC),
        fontSize: compact ? 8 : 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ArticleMeta extends StatelessWidget {
  const _ArticleMeta({required this.article, this.light = false});
  final Article article;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final parts = [
      if (article.publishDate.isNotEmpty) article.publishDate,
      if (article.readTime.isNotEmpty) article.readTime,
    ];
    return Text(
      parts.join('  •  '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: light ? Colors.white70 : const Color(0xFF8A704D),
        fontSize: light ? 9.5 : 8.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

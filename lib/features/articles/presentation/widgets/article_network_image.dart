import 'package:flutter/material.dart';

class ArticleNetworkImage extends StatelessWidget {
  const ArticleNetworkImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return const _ImageFallback();
    return Image.network(
      url,
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const _ImageFallback(showProgress: true);
      },
      errorBuilder: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: const Color(0xFF172434),
    child: Center(
      child: showProgress
          ? const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD6AB4D),
              ),
            )
          : const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFFB99042),
              size: 38,
            ),
    ),
  );
}

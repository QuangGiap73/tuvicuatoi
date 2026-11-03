import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../../wallet/presentation/wallet_controller.dart';
import 'providers/article_providers.dart';
import 'widgets/article_body_sliver.dart';
import 'widgets/article_network_image.dart';

class ArticleDetailPage extends ConsumerStatefulWidget {
  const ArticleDetailPage({required this.slug, this.missionCode, super.key});

  final String slug;
  final String? missionCode;

  @override
  ConsumerState<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends ConsumerState<ArticleDetailPage> {
  bool _missionRecorded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_prepare);
  }

  Future<void> _prepare() async {
    await ref.read(articleCatalogControllerProvider.notifier).load();
    final article = ref
        .read(articleCatalogControllerProvider)
        .catalog
        ?.findBySlug(widget.slug);
    if (article != null) {
      await ref
          .read(articleEngagementServiceProvider)
          .recordPageView('/articles/${article.slug}');
    }
    final missionCode = widget.missionCode?.trim() ?? '';
    if (article == null || missionCode.isEmpty || _missionRecorded) return;
    _missionRecorded = true;
    await ref
        .read(walletControllerProvider.notifier)
        .recordMissionActionByCode(missionCode);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleCatalogControllerProvider);
    final article = ref.watch(articleBySlugProvider(widget.slug));
    return MysticScaffold(
      constrainBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          ),
          const ColoredBox(color: Color(0xCB06111E)),
        ],
      ),
      body: article == null
          ? _MissingArticle(
              loading: state.isLoading,
              error: state.error,
              onBack: Navigator.of(context).pop,
              onRetry: () => ref
                  .read(articleCatalogControllerProvider.notifier)
                  .load(force: true),
            )
          : CustomScrollView(
              key: PageStorageKey('article-${article.slug}'),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 235,
                  backgroundColor: const Color(0xFF07101E),
                  foregroundColor: const Color(0xFFFFD66B),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        ArticleNetworkImage(
                          url: article.imageUrl,
                          cacheWidth: 1100,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x15000000), Color(0xE907101E)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5E4BC),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        border: Border(
                          top: BorderSide(color: Color(0xFFB77C25), width: 1.2),
                          left: BorderSide(
                            color: Color(0xFFB77C25),
                            width: 1.2,
                          ),
                          right: BorderSide(
                            color: Color(0xFFB77C25),
                            width: 1.2,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 19, 18, 0),
                      child: _ArticleHeading(
                        title: article.title,
                        category: article.category,
                        author: article.author,
                        publishDate: article.publishDate,
                        readTime: article.readTime,
                        summary: article.summary,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: ArticleBodySliver(
                    title: article.title,
                    paragraphs: article.content,
                    backgroundColor: const Color(0xFFF5E4BC),
                    horizontalPadding: 18,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5E4BC),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(18),
                        ),
                        border: Border(
                          left: BorderSide(
                            color: Color(0xFFB77C25),
                            width: 1.2,
                          ),
                          right: BorderSide(
                            color: Color(0xFFB77C25),
                            width: 1.2,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFFB77C25),
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: article.tags.isEmpty
                          ? const SizedBox.shrink()
                          : Wrap(
                              spacing: 7,
                              runSpacing: 6,
                              children: article.tags
                                  .map(
                                    (tag) => Chip(
                                      label: Text(tag),
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: const Color(0xFFE7C477),
                                      side: const BorderSide(
                                        color: Color(0xFFB98227),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF533515),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ArticleHeading extends StatelessWidget {
  const _ArticleHeading({
    required this.title,
    required this.category,
    required this.author,
    required this.publishDate,
    required this.readTime,
    required this.summary,
  });

  final String title;
  final String category;
  final String author;
  final String publishDate;
  final String readTime;
  final String summary;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        category.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF9A681F),
          fontSize: 10,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 7),
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF462A12),
          fontFamily: 'serif',
          fontSize: 25,
          height: 1.18,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        [
          author,
          publishDate,
          readTime,
        ].where((item) => item.trim().isNotEmpty).join('  •  '),
        style: const TextStyle(color: Color(0xFF806445), fontSize: 10.5),
      ),
      if (summary.isNotEmpty) ...[
        const SizedBox(height: 14),
        Text(
          summary,
          style: const TextStyle(
            color: Color(0xFF66472A),
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 17),
        child: Divider(color: Color(0x66996A28), height: 1),
      ),
    ],
  );
}

class _MissingArticle extends StatelessWidget {
  const _MissingArticle({
    required this.loading,
    required this.error,
    required this.onBack,
    required this.onRetry,
  });
  final bool loading;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFFFD66B),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: loading
                ? const CircularProgressIndicator(color: Color(0xFFD9AC4C))
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          error ?? 'Không tìm thấy bài viết này.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: onRetry,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

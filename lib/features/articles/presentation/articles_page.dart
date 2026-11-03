import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_frame_button.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import 'providers/article_providers.dart';
import 'widgets/article_cards.dart';

class ArticlesPage extends ConsumerStatefulWidget {
  const ArticlesPage({this.missionCode, super.key});

  final String? missionCode;

  @override
  ConsumerState<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends ConsumerState<ArticlesPage> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final query = ref.read(articleFilterControllerProvider).query;
    _searchController = TextEditingController(text: query);
    Future.microtask(ref.read(articleCatalogControllerProvider.notifier).load);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(articleCatalogControllerProvider);
    final filter = ref.watch(articleFilterControllerProvider);
    final articles = ref.watch(filteredArticlesProvider);
    final catalog = catalogState.catalog;
    final categories = <String>{
      'Tất cả',
      ...?catalog?.categories.where((item) => item.trim().isNotEmpty),
    }.toList(growable: false);
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
          const ColoredBox(color: Color(0xC006111E)),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD9AC4C),
        onRefresh: () => ref
            .read(articleCatalogControllerProvider.notifier)
            .load(force: true),
        child: CustomScrollView(
          key: const PageStorageKey('articles-scroll'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(onBack: context.pop)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              sliver: SliverToBoxAdapter(
                child: _SearchField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                ),
              ),
            ),
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 7),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final selected = category == filter.category;
                      final buttonWidth = (category.runes.length * 7.5 + 34)
                          .clamp(82.0, 156.0);
                      return SizedBox(
                        width: buttonWidth,
                        child: MysticFrameButton(
                          label: category,
                          selected: selected,
                          height: 44,
                          onPressed: selected
                              ? null
                              : () => ref
                                    .read(
                                      articleFilterControllerProvider.notifier,
                                    )
                                    .selectCategory(category),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (catalogState.isLoading && catalog == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD9AC4C)),
                ),
              )
            else if (catalogState.error != null && catalog == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessagePanel(
                  message: catalogState.error!,
                  onRetry: ref
                      .read(articleCatalogControllerProvider.notifier)
                      .load,
                ),
              )
            else ...[
              if (catalog?.featured != null &&
                  filter.category == 'Tất cả' &&
                  filter.query.isEmpty) ...[
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(14, 6, 14, 8),
                  sliver: SliverToBoxAdapter(
                    child: _SectionTitle(title: 'Bài viết nổi bật'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverToBoxAdapter(
                    child: FeaturedArticleCard(
                      article: catalog!.featured!,
                      onTap: () => _openArticle(catalog.featured!.slug),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ],
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                sliver: SliverToBoxAdapter(
                  child: _SectionTitle(
                    title:
                        filter.query.isNotEmpty || filter.category != 'Tất cả'
                        ? 'Kết quả (${articles.length})'
                        : 'Tin tức & Cẩm nang mới nhất',
                  ),
                ),
              ),
              if (articles.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessagePanel(
                    message: 'Không tìm thấy bài viết phù hợp.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                  sliver: SliverList.separated(
                    itemCount: articles.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return ArticlePreviewCard(
                        article: article,
                        onTap: () => _openArticle(article.slug),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      ref.read(articleFilterControllerProvider.notifier).setQuery(value);
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(articleFilterControllerProvider.notifier).setQuery('');
  }

  void _openArticle(String slug) {
    final missionCode = widget.missionCode?.trim();
    final query = missionCode == null || missionCode.isEmpty
        ? ''
        : '?missionCode=${Uri.encodeQueryComponent(missionCode)}';
    context.push('/articles/${Uri.encodeComponent(slug)}$query');
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(9, 8, 14, 13),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFFFFD66B),
              size: 29,
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'Tin Tức & Cẩm Nang',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFE4A0),
                    fontFamily: 'serif',
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Khám phá kiến thức Tử Vi và Phong Thủy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    textInputAction: TextInputAction.search,
    style: const TextStyle(color: Color(0xFFFFEDC1), fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Tìm kiếm bài viết...',
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD9AC4C)),
      suffixIcon: controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded, color: Colors.white54),
            ),
      filled: true,
      fillColor: const Color(0xD20A1725),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF8E6A28)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE1B64E), width: 1.4),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.auto_awesome, color: Color(0xFFFFD66B), size: 17),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFE3A0),
            fontFamily: 'serif',
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            color: Color(0xFFD9AC4C),
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ],
      ),
    ),
  );
}

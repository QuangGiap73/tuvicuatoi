import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/article_engagement_service.dart';
import '../../data/article_repository.dart';
import '../../domain/article_models.dart';
import '../controllers/article_catalog_controller.dart';
import '../controllers/article_filter_controller.dart';
import '../state/article_catalog_state.dart';
import '../state/article_filter_state.dart';

final articleCatalogControllerProvider =
    NotifierProvider<ArticleCatalogController, ArticleCatalogState>(
      ArticleCatalogController.new,
    );

final articleEngagementServiceProvider = Provider<ArticleEngagementService>(
  (ref) => ArticleEngagementService(ref.watch(articleRepositoryProvider)),
);

final articleFilterControllerProvider =
    NotifierProvider<ArticleFilterController, ArticleFilterState>(
      ArticleFilterController.new,
    );

final filteredArticlesProvider = Provider<List<Article>>((ref) {
  final articles = ref.watch(
    articleCatalogControllerProvider.select(
      (state) => state.catalog?.articles ?? const <Article>[],
    ),
  );
  final filter = ref.watch(articleFilterControllerProvider);
  return filterArticles(articles, filter);
});

List<Article> filterArticles(
  List<Article> articles,
  ArticleFilterState filter,
) {
  final category = filter.category.trim().toLowerCase();
  final query = filter.query.trim().toLowerCase();
  if ((category.isEmpty || category == 'tất cả') && query.isEmpty) {
    return articles;
  }
  return List.unmodifiable(
    articles.where((article) {
      final matchesCategory =
          category.isEmpty ||
          category == 'tất cả' ||
          article.category.toLowerCase() == category;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return article.title.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query) ||
          article.tags.any((tag) => tag.toLowerCase().contains(query));
    }),
  );
}

final articleBySlugProvider = Provider.family<Article?, String>((ref, slug) {
  return ref
      .watch(articleCatalogControllerProvider.select((state) => state.catalog))
      ?.findBySlug(slug);
});

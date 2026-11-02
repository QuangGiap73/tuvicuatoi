import '../../domain/article_models.dart';

class ArticleCatalogState {
  const ArticleCatalogState({
    this.catalog,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  final ArticleCatalog? catalog;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  ArticleCatalogState copyWith({
    ArticleCatalog? catalog,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) => ArticleCatalogState(
    catalog: catalog ?? this.catalog,
    isLoading: isLoading ?? this.isLoading,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    error: clearError ? null : error ?? this.error,
  );
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/article_repository.dart';
import '../state/article_catalog_state.dart';

class ArticleCatalogController extends Notifier<ArticleCatalogState> {
  CancelToken? _loadToken;

  @override
  ArticleCatalogState build() {
    ref.onDispose(() => _loadToken?.cancel());
    return const ArticleCatalogState();
  }

  Future<void> load({bool force = false}) async {
    if (_loadToken != null && !_loadToken!.isCancelled) return;
    if (!force && state.catalog != null) return;
    final token = CancelToken();
    _loadToken = token;
    final hasCatalog = state.catalog != null;
    state = state.copyWith(
      isLoading: !hasCatalog,
      isRefreshing: hasCatalog,
      clearError: true,
    );
    try {
      final catalog = await ref
          .read(articleRepositoryProvider)
          .getCatalog(cancelToken: token);
      if (token.isCancelled) return;
      state = state.copyWith(
        catalog: catalog,
        isLoading: false,
        isRefreshing: false,
        clearError: true,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: error.userMessage,
      );
    } on ArticleException catch (error) {
      if (token.isCancelled) return;
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: error.message,
      );
    } finally {
      if (identical(_loadToken, token)) _loadToken = null;
    }
  }
}

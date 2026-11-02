import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/article_filter_state.dart';

class ArticleFilterController extends Notifier<ArticleFilterState> {
  @override
  ArticleFilterState build() => const ArticleFilterState();

  void selectCategory(String category) {
    final value = category.trim().isEmpty ? 'Tất cả' : category.trim();
    if (value == state.category) return;
    state = state.copyWith(category: value);
  }

  void setQuery(String query) {
    final value = query.trim();
    if (value == state.query) return;
    state = state.copyWith(query: value);
  }

  void clear() {
    if (state.category == 'Tất cả' && state.query.isEmpty) return;
    state = const ArticleFilterState();
  }
}

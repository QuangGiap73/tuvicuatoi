class ArticleFilterState {
  const ArticleFilterState({this.category = 'Tất cả', this.query = ''});

  final String category;
  final String query;

  ArticleFilterState copyWith({String? category, String? query}) =>
      ArticleFilterState(
        category: category ?? this.category,
        query: query ?? this.query,
      );
}

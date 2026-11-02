import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/articles/domain/article_models.dart';
import 'package:tuvicuatoi/features/articles/presentation/providers/article_providers.dart';
import 'package:tuvicuatoi/features/articles/presentation/state/article_filter_state.dart';

void main() {
  const articles = [
    Article(
      id: '1',
      slug: 'tu-vi',
      title: 'Tử Vi Đẩu Số',
      category: 'Cổ Thư',
      summary: 'Kiến thức nhập môn',
      content: [],
      readTime: '',
      publishDate: '',
      author: '',
      imageUrl: '',
      tags: ['Tử Vi'],
      isFeatured: false,
    ),
    Article(
      id: '2',
      slug: 'phong-thuy',
      title: 'Phong thủy ứng dụng',
      category: 'Phong Thủy',
      summary: 'Không gian sống',
      content: [],
      readTime: '',
      publishDate: '',
      author: '',
      imageUrl: '',
      tags: ['Nhà cửa'],
      isFeatured: false,
    ),
  ];

  test('filters locally without mutating the source catalog', () {
    final filtered = filterArticles(
      articles,
      const ArticleFilterState(category: 'Phong Thủy', query: 'không gian'),
    );

    expect(filtered.map((article) => article.slug), ['phong-thuy']);
    expect(articles, hasLength(2));
  });

  test('returns the cached list unchanged for the all filter', () {
    final filtered = filterArticles(articles, const ArticleFilterState());
    expect(identical(filtered, articles), isTrue);
  });
}

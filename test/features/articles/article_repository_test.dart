import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/articles/data/article_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late ArticleRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = ArticleRepository(dio);
  });

  test(
    'parses the real catalog shape and resolves root-relative images',
    () async {
      adapter.onGet(
        '/articles/',
        (server) => server.reply(200, {
          'success': true,
          'categories': ['Tất cả', 'Phong Thủy'],
          'featured': {
            'id': 'featured-id',
            'slug': 'featured',
            'title': 'Bài nổi bật',
            'image': '/images/parchment.jpg',
            'content': ['# Bài nổi bật', 'Nội dung'],
            'isFeatured': true,
          },
          'articles': [
            {
              'id': 'article-id',
              'slug': 'phong-thuy',
              'title': 'Phong thủy ứng dụng',
              'category': 'Phong Thủy',
              'summary': 'Tóm tắt',
              'content': ['## Mở đầu', 'Nội dung bài viết'],
              'readTime': '3 phút đọc',
              'publishDate': '01/11/2026',
              'author': 'Tử Vi AI',
              'image': '/images/parchment.jpg',
              'tags': ['Phong Thủy'],
            },
          ],
        }),
      );

      final catalog = await repository.getCatalog();

      expect(catalog.categories, ['Tất cả', 'Phong Thủy']);
      expect(catalog.featured?.slug, 'featured');
      expect(catalog.articles.single.content, [
        '## Mở đầu',
        'Nội dung bài viết',
      ]);
      expect(
        catalog.articles.single.imageUrl,
        'https://tuvicuatoi.com/images/parchment.jpg',
      );
    },
  );

  test('accepts string content and ignores invalid articles', () async {
    adapter.onGet(
      '/articles/',
      (server) => server.reply(200, {
        'success': true,
        'categories': <String>[],
        'featured': null,
        'articles': [
          {
            'id': 'valid',
            'slug': 'valid',
            'title': 'Valid',
            'content': 'Một đoạn duy nhất',
          },
          {'id': '', 'slug': '', 'title': ''},
        ],
      }),
    );

    final catalog = await repository.getCatalog();

    expect(catalog.articles, hasLength(1));
    expect(catalog.articles.single.content, ['Một đoạn duy nhất']);
  });

  test('records the web-compatible pageview payload', () async {
    adapter.onPost(
      '/analytics/pageview/',
      data: {'path': '/articles/phong-thuy'},
      (server) => server.reply(200, {'success': true}),
    );

    await repository.recordPageView('/articles/phong-thuy');
  });
}

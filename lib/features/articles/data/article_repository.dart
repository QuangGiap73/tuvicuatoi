import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/article_models.dart';

class ArticleException implements Exception {
  const ArticleException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ArticleRepository {
  const ArticleRepository(this._dio);

  final Dio _dio;

  Future<ArticleCatalog> getCatalog({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<Object?>(
        '/articles/',
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw const ArticleException(
          'Máy chủ chưa cung cấp danh sách bài viết hợp lệ.',
        );
      }
      final resolveImage = _resolveImageUrl;
      final articles = _maps(body['articles'])
          .map((item) => Article.fromJson(item, resolveImageUrl: resolveImage))
          .where((article) => article.isValid)
          .toList(growable: false);
      final featuredRaw = body['featured'];
      final featured = featuredRaw is Map
          ? Article.fromJson(
              Map<String, dynamic>.from(featuredRaw),
              resolveImageUrl: resolveImage,
            )
          : null;
      final categories = _strings(body['categories']);
      return ArticleCatalog(
        categories: List.unmodifiable(categories),
        featured: featured?.isValid == true ? featured : null,
        articles: List.unmodifiable(articles),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw ArticleException(error.userMessage);
    }
  }

  Future<void> recordPageView(String path, {CancelToken? cancelToken}) async {
    final value = path.trim();
    if (value.isEmpty) return;
    try {
      await _dio.post<Object?>(
        '/analytics/pageview/',
        data: {'path': value},
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw ArticleException(error.userMessage);
    }
  }

  String _resolveImageUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return uri.toString();
    final base = Uri.tryParse(_dio.options.baseUrl);
    if (base == null || !base.hasScheme) return value;
    final origin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );
    return origin.resolve(value).toString();
  }

  static List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false)
      : const [];

  static List<String> _strings(Object? value) => value is List
      ? value
            .map((item) => item?.toString().trim() ?? '')
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList(growable: false)
      : const [];
}

final articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepository(ref.watch(dioProvider)),
);

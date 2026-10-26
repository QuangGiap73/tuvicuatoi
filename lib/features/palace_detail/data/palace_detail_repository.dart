import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/palace_detail_models.dart';

class PalaceDetailException implements Exception {
  const PalaceDetailException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PalaceDetailRepository {
  const PalaceDetailRepository(this._dio);
  final Dio _dio;

  Future<List<PalaceRule>> getPalaceRules({
    required String palaceName,
    required List<String> stars,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/luan/cung',
        data: {'palaceName': palaceName, 'stars': stars},
        cancelToken: cancelToken,
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! List) {
        throw const PalaceDetailException(
          'Dữ liệu luận giải cung không hợp lệ.',
        );
      }
      return List.unmodifiable(
        data
            .whereType<Map>()
            .map((item) => PalaceRule.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw PalaceDetailException(_message(error));
    }
  }

  Future<List<TriadRule>> getTriadRules({
    required String palaceName,
    required List<String> triadStars,
    CancelToken? cancelToken,
  }) async {
    if (triadStars.isEmpty) return const [];
    try {
      final response = await _dio.post<Object?>(
        '/luan/tam-phuong',
        data: {'palaceName': palaceName, 'triadStars': triadStars},
        cancelToken: cancelToken,
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! List) {
        throw const PalaceDetailException(
          'Dữ liệu Tam phương Tứ chính không hợp lệ.',
        );
      }
      return List.unmodifiable(
        data
            .whereType<Map>()
            .map((item) => TriadRule.fromJson(Map<String, dynamic>.from(item)))
            .toList(growable: false),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw PalaceDetailException(_message(error));
    }
  }

  static String _message(DioException error) {
    final body = error.response?.data;
    if (body is Map) {
      final value = body['message'] ?? body['error'] ?? body['detail'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return error.userMessage;
  }
}

final palaceDetailRepositoryProvider = Provider<PalaceDetailRepository>(
  (ref) => PalaceDetailRepository(ref.watch(dioProvider)),
);

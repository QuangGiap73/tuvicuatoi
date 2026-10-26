import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/interpretation_models.dart';

class InterpretationException implements Exception {
  const InterpretationException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class InterpretationRepository {
  const InterpretationRepository(this._dio);
  final Dio _dio;

  Future<List<ReadingSection>> getSections({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<Object?>(
        '/charts/reading-sections/',
        cancelToken: cancelToken,
      );
      final body = response.data;
      final raw = body is Map ? body['readingSections'] : null;
      if (body is! Map || body['success'] != true || raw is! List) {
        throw const InterpretationException('Danh mục luận giải không hợp lệ.');
      }
      final sections =
          raw
              .whereType<Map>()
              .map(
                (item) =>
                    ReadingSection.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(growable: false)
            ..sort((left, right) => left.order.compareTo(right.order));
      return List.unmodifiable(sections);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw _exception(error);
    }
  }

  Future<Set<String>> getUnlocks({
    required String chartId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/charts/reading-unlocks/',
        queryParameters: {'chartId': chartId},
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw const InterpretationException(
          'Không thể tải quyền đọc luận giải.',
        );
      }
      final raw = body['unlockedReadingKeys'];
      return raw is List
          ? Set.unmodifiable(raw.map((item) => item.toString()))
          : const {};
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw _exception(error);
    }
  }

  Future<InterpretationData> getSavedInterpretation({
    required String chartId,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/charts/$chartId/interpretation/',
        cancelToken: cancelToken,
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        throw const InterpretationException(
          'Dữ liệu luận giải đã lưu không hợp lệ.',
        );
      }
      return InterpretationData.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw _exception(error);
    }
  }

  Future<InterpretationData> generate({
    required Map<String, dynamic> chartData,
    required InterpretationMode mode,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/tuvi/read',
        data: {'type': 'full', 'mode': mode.apiValue, 'chart': chartData},
        cancelToken: cancelToken,
      );
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (body is! Map || body['success'] != true || data is! Map) {
        throw const InterpretationException('Dữ liệu luận giải không hợp lệ.');
      }
      return InterpretationData.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw _exception(error);
    }
  }

  Future<ReadingUnlockResult> unlock({
    required String chartId,
    required InterpretationMode mode,
    required ReadingSection section,
    String? voucherCode,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        '/charts/reading-unlocks/',
        data: {
          'chartId': chartId,
          'interpretationMode': mode.apiValue,
          'groupSlug': section.groupSlug,
          'sectionSlug': section.sectionSlug,
          if (voucherCode != null && voucherCode.trim().isNotEmpty)
            'voucherCode': voucherCode.trim(),
        },
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw InterpretationException(_message(body));
      }
      return ReadingUnlockResult.fromJson(Map<String, dynamic>.from(body));
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw _exception(error);
    }
  }

  static InterpretationException _exception(DioException error) =>
      InterpretationException(
        _message(error.response?.data, fallback: error.userMessage),
        statusCode: error.response?.statusCode,
      );

  static String _message(Object? body, {String? fallback}) {
    if (body is Map) {
      final error = body['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      final value = body['message'] ?? error ?? body['detail'];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback ?? 'Không thể xử lý yêu cầu luận giải.';
  }
}

final interpretationRepositoryProvider = Provider<InterpretationRepository>(
  (ref) => InterpretationRepository(ref.watch(dioProvider)),
);

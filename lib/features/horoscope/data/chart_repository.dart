import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/chart_request.dart';
import '../domain/chart_result.dart';
import '../domain/saved_chart.dart';
import '../domain/saved_chart_detail.dart';

class ChartRepository {
  const ChartRepository(this._dio);

  final Dio _dio;

  Future<ChartResult> generate(ChartRequest request) async {
    try {
      final response = await _dio.post<Object?>(
        '/chart/generate',
        data: request.toJson(),
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['data'] is! Map) {
        throw const ChartException(
          'Máy chủ trả về dữ liệu lá số không hợp lệ.',
        );
      }
      return ChartResult.fromJson(
        Map<String, dynamic>.from(body['data'] as Map),
      );
    } on DioException catch (error) {
      throw ChartException(_errorMessage(error));
    }
  }

  Future<String> save(ChartRequest request, ChartResult result) async {
    try {
      final response = await _dio.post<Object?>(
        '/charts/save/',
        data: {
          ...request.toJson(),
          'name': 'Lá Số ${request.name.trim()} ${request.year}',
          'chart_data': result.rawData,
        },
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw const ChartException('Không thể lưu lá số.');
      }
      return (body['chartId'] ?? body['id'] ?? '').toString();
    } on DioException catch (error) {
      throw ChartException(_errorMessage(error));
    }
  }

  Future<List<SavedChart>> getMyCharts({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get<Object?>(
        '/charts/my-charts/',
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map || body['success'] != true || body['charts'] is! List) {
        throw const ChartException('Không thể đọc danh sách lá số.');
      }
      return (body['charts'] as List)
          .whereType<Map>()
          .map((item) => SavedChart.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
    } on DioException catch (error) {
      throw ChartException(_errorMessage(error));
    }
  }

  Future<void> deleteChart(String chartId) async {
    try {
      final response = await _dio.delete<Object?>('/charts/$chartId/delete/');
      final body = response.data;
      if (body is Map && body['success'] == false) {
        throw ChartException(
          (body['message'] ?? body['error'] ?? 'Không thể xóa lá số.')
              .toString(),
        );
      }
    } on DioException catch (error) {
      throw ChartException(_errorMessage(error));
    }
  }

  Future<SavedChartDetail> getChartDetail(
    SavedChart chart, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/charts/${chart.id}/',
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map) {
        throw const ChartException('Dữ liệu chi tiết lá số không hợp lệ.');
      }
      return SavedChartDetail.fromResponse(
        chart,
        Map<String, dynamic>.from(body),
      );
    } on DioException catch (error) {
      throw ChartException(_errorMessage(error));
    }
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return error.userMessage;
  }
}

class ChartException implements Exception {
  const ChartException(this.message);
  final String message;

  @override
  String toString() => message;
}

final chartRepositoryProvider = Provider<ChartRepository>(
  (ref) => ChartRepository(ref.watch(dioProvider)),
);

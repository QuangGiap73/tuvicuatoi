import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/ai_chat_message.dart';

class AiChatException implements Exception {
  const AiChatException(this.details);
  AiChatException.message(String message)
    : details = AiChatFailureDetails(message: message);

  final AiChatFailureDetails details;
  String get message => details.message;
  bool get isInsufficientCoins => details.isInsufficientCoins;

  @override
  String toString() => message;
}

Stream<AiChatStreamEvent> parseAiChatSse(Stream<List<int>> byteStream) async* {
  await for (final line
      in byteStream.transform(utf8.decoder).transform(const LineSplitter())) {
    final value = line.trim();
    if (!value.startsWith('data:')) continue;
    final jsonText = value.substring(5).trim();
    if (jsonText.isEmpty || jsonText == '[DONE]') continue;
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) continue;
    if (decoded['delta'] != null) {
      yield AiChatDelta(decoded['delta'].toString());
    } else if (decoded['done'] == true ||
        (decoded['success'] == true && decoded['reply'] != null)) {
      final usage = AiChatUsageUpdate.fromJson(decoded);
      final nested = decoded['data'];
      yield AiChatDone(
        (decoded['fullText'] ??
                decoded['full_text'] ??
                decoded['reply'] ??
                (nested is Map ? nested['reply'] : null) ??
                '')
            .toString(),
        usage: usage.hasData ? usage : null,
      );
    } else if (decoded['error'] != null || decoded['success'] == false) {
      yield AiChatStreamError(AiChatFailureDetails.fromJson(decoded));
    }
  }
}

class AiChatRepository {
  const AiChatRepository(this._dio);
  final Dio _dio;

  Future<List<AiChatMessage>> getHistory({
    required String chartId,
    required String email,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/ai/history/',
        queryParameters: {'chartId': chartId, 'email': email},
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body is! Map || body['success'] == false) {
        throw AiChatException.message('Không thể tải lịch sử trò chuyện.');
      }
      final data = body['data'];
      final rawMessages =
          body['messages'] ??
          (data is Map ? data['messages'] ?? data['history'] : null);
      if (rawMessages is! List) return const [];
      final messages = rawMessages
          .whereType<Map>()
          .map(
            (item) => AiChatMessage.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((message) => message.content.trim().isNotEmpty)
          .toList(growable: false);
      messages.sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null || right == null) return 0;
        return left.compareTo(right);
      });
      return List.unmodifiable(messages);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw AiChatException.message(_messageFrom(error));
    }
  }

  Future<int> clearHistory({required String chartId}) async {
    try {
      final response = await _dio.post<Object?>(
        '/ai/history/clear/',
        data: {'chartId': chartId},
      );
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw AiChatException.message(
          body is Map && (body['message'] ?? body['error']) != null
              ? (body['message'] ?? body['error']).toString()
              : 'Không thể xóa lịch sử trò chuyện.',
        );
      }
      return (body['deletedCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (error) {
      throw AiChatException.message(_messageFrom(error));
    }
  }

  Stream<AiChatStreamEvent> sendMessage({
    required String message,
    required String chartId,
    required Map<String, dynamic> chartData,
    required String focusPalace,
    CancelToken? cancelToken,
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        '/ai/chat/',
        data: {
          'message': message,
          'chartId': chartId,
          'chartData': chartData,
          'focusPalace': focusPalace,
          'stream': true,
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 2),
          headers: const {'Accept': 'text/event-stream, application/json'},
        ),
        cancelToken: cancelToken,
      );
      final body = response.data;
      if (body == null) {
        throw AiChatException.message('Máy chủ không trả về nội dung.');
      }

      final contentType =
          response.headers.value(Headers.contentTypeHeader) ?? '';
      if (contentType.contains('text/event-stream')) {
        final byteStream = body.stream.map<List<int>>((chunk) => chunk);
        yield* parseAiChatSse(byteStream);
        return;
      }

      final bytes = await body.stream.expand((chunk) => chunk).toList();
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map || decoded['success'] != true) {
        if (decoded is Map) {
          throw AiChatException(AiChatFailureDetails.fromJson(decoded));
        }
        throw AiChatException.message('Phản hồi AI không hợp lệ.');
      }
      final data = decoded['data'];
      final reply = (decoded['reply'] ?? (data is Map ? data['reply'] : null))
          ?.toString();
      if (reply == null || reply.trim().isEmpty) {
        throw AiChatException.message('AI chưa trả về nội dung.');
      }
      final usage = AiChatUsageUpdate.fromJson(decoded);
      yield AiChatDone(reply, usage: usage.hasData ? usage : null);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw await _exceptionFrom(error);
    } on FormatException {
      throw AiChatException.message('Không thể đọc phản hồi từ AI.');
    }
  }

  Future<AiChatException> _exceptionFrom(DioException error) async {
    Object? data = error.response?.data;
    if (data is ResponseBody) {
      try {
        final bytes = await data.stream.expand((chunk) => chunk).toList();
        data = jsonDecode(utf8.decode(bytes));
      } catch (_) {
        data = null;
      }
    } else if (data is String) {
      try {
        data = jsonDecode(data);
      } catch (_) {}
    }
    if (data is Map) {
      final details = AiChatFailureDetails.fromJson(data);
      if (details.message.trim().isNotEmpty || details.code != null) {
        return AiChatException(details);
      }
    }
    return AiChatException.message(error.userMessage);
  }

  String _messageFrom(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    return error.userMessage;
  }
}

final aiChatRepositoryProvider = Provider<AiChatRepository>(
  (ref) => AiChatRepository(ref.watch(dioProvider)),
);

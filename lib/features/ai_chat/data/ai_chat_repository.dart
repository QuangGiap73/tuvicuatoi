import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/ai_chat_message.dart';

class AiChatException implements Exception {
  const AiChatException(this.message);
  final String message;
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
    } else if (decoded['done'] == true) {
      yield AiChatDone(
        (decoded['fullText'] ?? decoded['full_text'] ?? '').toString(),
      );
    } else if (decoded['error'] != null) {
      yield AiChatStreamError(decoded['error'].toString());
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
        throw const AiChatException('Không thể tải lịch sử trò chuyện.');
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
      throw AiChatException(_messageFrom(error));
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
        throw AiChatException(
          body is Map && (body['message'] ?? body['error']) != null
              ? (body['message'] ?? body['error']).toString()
              : 'Không thể xóa lịch sử trò chuyện.',
        );
      }
      return (body['deletedCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (error) {
      throw AiChatException(_messageFrom(error));
    }
  }

  Stream<AiChatStreamEvent> sendMessage({
    required String message,
    required String chartId,
    required Map<String, dynamic> chartData,
    required String focusPalace,
    required bool isPremium,
    required String userEmail,
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
          'isPremium': isPremium,
          'userEmail': userEmail,
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
        throw const AiChatException('Máy chủ không trả về nội dung.');
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
        throw AiChatException(
          decoded is Map && decoded['error'] != null
              ? decoded['error'].toString()
              : 'Phản hồi AI không hợp lệ.',
        );
      }
      final data = decoded['data'];
      final reply = (decoded['reply'] ?? (data is Map ? data['reply'] : null))
          ?.toString();
      if (reply == null || reply.trim().isEmpty) {
        throw const AiChatException('AI chưa trả về nội dung.');
      }
      yield AiChatDone(reply);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw AiChatException(_messageFrom(error));
    } on FormatException {
      throw const AiChatException('Không thể đọc phản hồi từ AI.');
    }
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

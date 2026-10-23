import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/ai_chat/data/ai_chat_repository.dart';
import 'package:tuvicuatoi/features/ai_chat/domain/ai_chat_message.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late AiChatRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = AiChatRepository(dio);
  });

  test('history is mapped and sorted chronologically', () async {
    adapter.onGet(
      '/ai/history/',
      (server) => server.reply(200, {
        'success': true,
        'data': {
          'messages': [
            {
              'id': 'assistant-1',
              'role': 'assistant',
              'content': 'Câu trả lời',
              'created_at': '2026-10-22T10:01:00.000Z',
            },
            {
              'id': 'user-1',
              'sender': 'user',
              'text': 'Câu hỏi',
              'createdAt': '2026-10-22T10:00:00.000Z',
            },
          ],
        },
      }),
      queryParameters: {'chartId': 'chart-1', 'email': 'user@example.com'},
    );

    final messages = await repository.getHistory(
      chartId: 'chart-1',
      email: 'user@example.com',
    );

    expect(messages.map((item) => item.id), ['user-1', 'assistant-1']);
    expect(messages.first.role, AiChatRole.user);
    expect(messages.last.role, AiChatRole.assistant);
  });

  test('SSE parser handles chunked deltas and final message', () async {
    final payload = [
      'data: {"delta":"Xin "}',
      'data: {"delta":"chào"}',
      'data: {"done":true,"fullText":"Xin chào"}',
      '',
    ].join('\n');
    final bytes = utf8.encode(payload);
    final events = await parseAiChatSse(
      Stream.fromIterable([
        bytes.sublist(0, 17),
        bytes.sublist(17, 39),
        bytes.sublist(39),
      ]),
    ).toList();

    expect(events, hasLength(3));
    expect((events[0] as AiChatDelta).text, 'Xin ');
    expect((events[1] as AiChatDelta).text, 'chào');
    expect((events[2] as AiChatDone).fullText, 'Xin chào');
  });

  test('chat sends the documented payload with focusPalace', () async {
    final requestBodies = <Object?>[];
    final streamDio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    streamDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requestBodies.add(options.data);
          handler.resolve(
            Response<ResponseBody>(
              requestOptions: options,
              statusCode: 200,
              headers: Headers.fromMap({
                Headers.contentTypeHeader: ['application/json'],
              }),
              data: ResponseBody.fromString(
                jsonEncode({'success': true, 'reply': 'Câu trả lời từ AI'}),
                200,
                headers: {
                  Headers.contentTypeHeader: ['application/json'],
                },
              ),
            ),
          );
        },
      ),
    );
    final streamRepository = AiChatRepository(streamDio);

    final events = await streamRepository
        .sendMessage(
          message: 'Công việc của tôi thế nào?',
          chartId: 'chart-1',
          chartData: const {'id': 'chart-1'},
          focusPalace: 'Quan Lộc',
          isPremium: true,
          userEmail: 'user@example.com',
        )
        .toList();

    expect(requestBodies, [
      {
        'message': 'Công việc của tôi thế nào?',
        'chartId': 'chart-1',
        'chartData': {'id': 'chart-1'},
        'focusPalace': 'Quan Lộc',
        'isPremium': true,
        'userEmail': 'user@example.com',
        'stream': true,
      },
    ]);
    expect((events.single as AiChatDone).fullText, 'Câu trả lời từ AI');
  });

  test('clear history posts the selected chart id', () async {
    adapter.onPost(
      '/ai/history/clear/',
      (server) => server.reply(200, {
        'success': true,
        'deletedCount': 6,
        'message': 'Đã dọn dẹp lịch sử trò chuyện thành công',
      }),
      data: {'chartId': 'chart-1'},
    );

    final deletedCount = await repository.clearHistory(chartId: 'chart-1');

    expect(deletedCount, 6);
  });
}

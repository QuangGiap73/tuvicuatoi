import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/ai_chat_message.dart';

abstract interface class AiChatHistoryStore {
  Future<List<AiChatMessage>> read({
    required String userId,
    required String chartId,
  });

  Future<void> write({
    required String userId,
    required String chartId,
    required List<AiChatMessage> messages,
  });

  Future<void> delete({required String userId, required String chartId});
}

class SecureAiChatHistoryStore implements AiChatHistoryStore {
  const SecureAiChatHistoryStore(this._storage);

  final FlutterSecureStorage _storage;
  static const _maxMessagesPerChart = 100;

  String _key(String userId, String chartId) =>
      'ai_chat_history_${base64Url.encode(utf8.encode(userId))}_'
      '${base64Url.encode(utf8.encode(chartId))}';

  @override
  Future<List<AiChatMessage>> read({
    required String userId,
    required String chartId,
  }) async {
    try {
      final value = await _storage.read(key: _key(userId, chartId));
      if (value == null || value.isEmpty) return const [];
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return List.unmodifiable(
        decoded
            .whereType<Map>()
            .map(
              (item) => AiChatMessage.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((message) => message.content.trim().isNotEmpty),
      );
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> write({
    required String userId,
    required String chartId,
    required List<AiChatMessage> messages,
  }) async {
    try {
      final persistable = messages
          .where(
            (message) =>
                message.id != 'welcome' &&
                message.content.trim().isNotEmpty &&
                message.status != AiChatMessageStatus.streaming,
          )
          .toList(growable: false);
      final start = persistable.length > _maxMessagesPerChart
          ? persistable.length - _maxMessagesPerChart
          : 0;
      final encoded = jsonEncode(
        persistable.skip(start).map((message) => message.toJson()).toList(),
      );
      await _storage.write(key: _key(userId, chartId), value: encoded);
    } catch (_) {
      // Cache cục bộ không được phép làm hỏng luồng trả lời AI.
    }
  }

  @override
  Future<void> delete({required String userId, required String chartId}) =>
      _storage.delete(key: _key(userId, chartId));
}

final aiChatHistoryStoreProvider = Provider<AiChatHistoryStore>(
  (_) => const SecureAiChatHistoryStore(FlutterSecureStorage()),
);

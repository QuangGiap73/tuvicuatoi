import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

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

/// Keeps the bounded chat cache in app-support storage. Secure storage is only
/// read once to migrate cache written by older app versions.
class FileAiChatHistoryStore implements AiChatHistoryStore {
  FileAiChatHistoryStore(this._legacyStorage);

  final FlutterSecureStorage _legacyStorage;
  static const _maxMessagesPerChart = 40;
  static const _maxContentCharacters = 120000;
  Directory? _cacheDirectory;

  String _storageKey(String userId, String chartId) =>
      'ai_chat_history_${base64Url.encode(utf8.encode(userId))}_'
      '${base64Url.encode(utf8.encode(chartId))}';

  Future<Directory> _directory() async {
    final cached = _cacheDirectory;
    if (cached != null) return cached;
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/ai_chat_history');
    if (!await directory.exists()) await directory.create(recursive: true);
    _cacheDirectory = directory;
    return directory;
  }

  Future<File> _file(String userId, String chartId) async {
    final directory = await _directory();
    return File('${directory.path}/${_storageKey(userId, chartId)}.json');
  }

  @override
  Future<List<AiChatMessage>> read({
    required String userId,
    required String chartId,
  }) async {
    try {
      final file = await _file(userId, chartId);
      var value = await file.exists() ? await file.readAsString() : null;

      if (value == null || value.isEmpty) {
        final legacyKey = _storageKey(userId, chartId);
        value = await _legacyStorage.read(key: legacyKey);
        if (value != null && value.isNotEmpty) {
          await file.writeAsString(value, flush: true);
          await _legacyStorage.delete(key: legacyKey);
        }
      }
      if (value == null || value.isEmpty) return const [];

      final decoded = await Isolate.run<Object?>(() => jsonDecode(value!));
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
      final selected = <AiChatMessage>[];
      var contentCharacters = 0;
      for (final message in messages.reversed) {
        if (message.id == 'welcome' ||
            message.content.trim().isEmpty ||
            message.status == AiChatMessageStatus.streaming) {
          continue;
        }
        final nextCharacters = contentCharacters + message.content.length;
        if (selected.isNotEmpty &&
            (selected.length >= _maxMessagesPerChart ||
                nextCharacters > _maxContentCharacters)) {
          break;
        }
        selected.add(message);
        contentCharacters = nextCharacters;
      }
      final payload = selected.reversed
          .map((message) => message.toJson())
          .toList(growable: false);
      final encoded = await Isolate.run(() => jsonEncode(payload));
      final file = await _file(userId, chartId);
      final temporary = File('${file.path}.tmp');
      await temporary.writeAsString(encoded, flush: true);
      if (await file.exists()) await file.delete();
      await temporary.rename(file.path);
    } catch (_) {
      // Local cache must never turn a successful AI answer into a failure.
    }
  }

  @override
  Future<void> delete({required String userId, required String chartId}) async {
    final legacyKey = _storageKey(userId, chartId);
    try {
      final file = await _file(userId, chartId);
      if (await file.exists()) await file.delete();
    } finally {
      await _legacyStorage.delete(key: legacyKey);
    }
  }
}

final aiChatHistoryStoreProvider = Provider<AiChatHistoryStore>(
  (_) => FileAiChatHistoryStore(const FlutterSecureStorage()),
);

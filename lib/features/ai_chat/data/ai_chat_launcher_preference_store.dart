import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AiChatLauncherPreferenceStore {
  Future<bool> readVisible();
  Future<void> writeVisible(bool visible);
}

class SecureAiChatLauncherPreferenceStore
    implements AiChatLauncherPreferenceStore {
  const SecureAiChatLauncherPreferenceStore(this._storage);

  static const _key = 'show_global_ai_chat_launcher';
  final FlutterSecureStorage _storage;

  @override
  Future<bool> readVisible() async => await _storage.read(key: _key) != 'false';

  @override
  Future<void> writeVisible(bool visible) =>
      _storage.write(key: _key, value: visible.toString());
}

final aiChatLauncherPreferenceStoreProvider =
    Provider<AiChatLauncherPreferenceStore>(
      (_) => const SecureAiChatLauncherPreferenceStore(FlutterSecureStorage()),
    );

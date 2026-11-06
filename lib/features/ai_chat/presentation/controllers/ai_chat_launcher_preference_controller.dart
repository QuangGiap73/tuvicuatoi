import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ai_chat_launcher_preference_store.dart';

class AiChatLauncherPreferenceController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() =>
      ref.read(aiChatLauncherPreferenceStoreProvider).readVisible();

  Future<bool> setVisible(bool visible) async {
    final previous = state;
    state = AsyncData(visible);
    try {
      await ref
          .read(aiChatLauncherPreferenceStoreProvider)
          .writeVisible(visible);
      return true;
    } catch (error, stackTrace) {
      state = previous.hasValue
          ? previous
          : AsyncError<bool>(error, stackTrace);
      return false;
    }
  }
}

final aiChatLauncherPreferenceProvider =
    AsyncNotifierProvider<AiChatLauncherPreferenceController, bool>(
      AiChatLauncherPreferenceController.new,
    );

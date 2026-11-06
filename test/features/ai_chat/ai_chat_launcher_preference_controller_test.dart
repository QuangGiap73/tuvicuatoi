import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/ai_chat/data/ai_chat_launcher_preference_store.dart';
import 'package:tuvicuatoi/features/ai_chat/presentation/controllers/ai_chat_launcher_preference_controller.dart';

void main() {
  test('launcher is visible by default and persists user changes', () async {
    final store = _MemoryPreferenceStore();
    final container = ProviderContainer(
      overrides: [
        aiChatLauncherPreferenceStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(aiChatLauncherPreferenceProvider.future), true);

    final saved = await container
        .read(aiChatLauncherPreferenceProvider.notifier)
        .setVisible(false);

    expect(saved, true);
    expect(
      container.read(aiChatLauncherPreferenceProvider).asData?.value,
      false,
    );
    expect(store.visible, false);
  });

  test('failed persistence restores the previous preference', () async {
    final store = _MemoryPreferenceStore(failWrites: true);
    final container = ProviderContainer(
      overrides: [
        aiChatLauncherPreferenceStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);

    await container.read(aiChatLauncherPreferenceProvider.future);
    final saved = await container
        .read(aiChatLauncherPreferenceProvider.notifier)
        .setVisible(false);

    expect(saved, false);
    expect(
      container.read(aiChatLauncherPreferenceProvider).asData?.value,
      true,
    );
  });
}

class _MemoryPreferenceStore implements AiChatLauncherPreferenceStore {
  _MemoryPreferenceStore({this.failWrites = false});

  bool visible = true;
  final bool failWrites;

  @override
  Future<bool> readVisible() async => visible;

  @override
  Future<void> writeVisible(bool visible) async {
    if (failWrites) throw StateError('write failed');
    this.visible = visible;
  }
}

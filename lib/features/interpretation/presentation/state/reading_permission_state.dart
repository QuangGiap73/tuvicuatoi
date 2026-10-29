import 'package:flutter/foundation.dart';

import '../../domain/interpretation_models.dart';

@immutable
class ReadingPermissionState {
  const ReadingPermissionState({
    this.chartId,
    this.mode = InterpretationMode.deep,
    this.allUnlocked = false,
    this.unlockedKeys = const {},
    this.statusBySection = const {},
    this.isLoading = false,
    this.permissionError,
    this.unlockError,
  });

  final String? chartId;
  final InterpretationMode mode;
  final bool allUnlocked;
  final Set<ReadingSectionKey> unlockedKeys;
  final Map<String, UnlockStatus> statusBySection;
  final bool isLoading;
  final String? permissionError;
  final String? unlockError;

  ReadingSectionKey? keyFor(ReadingSection section) {
    final id = chartId;
    if (id == null || id.trim().isEmpty) return null;
    return ReadingSectionKey(
      chartId: id,
      mode: mode,
      groupSlug: section.groupSlug,
      sectionSlug: section.sectionSlug,
    );
  }

  bool isUnlocked(ReadingSection section) {
    if (section.isFree || section.isUnlocked || allUnlocked) return true;
    final key = keyFor(section);
    return key != null && unlockedKeys.contains(key);
  }

  UnlockStatus statusFor(ReadingSection section) {
    if (isUnlocked(section)) return UnlockStatus.unlocked;
    final key = keyFor(section);
    return key == null
        ? UnlockStatus.idle
        : statusBySection[key.value] ?? UnlockStatus.idle;
  }

  bool canPurchase(ReadingSection section) {
    final status = statusFor(section);
    return !section.isFree &&
        status != UnlockStatus.confirming &&
        status != UnlockStatus.submitting &&
        status != UnlockStatus.syncing &&
        status != UnlockStatus.unlocked;
  }

  bool get hasPendingTransaction => statusBySection.values.any(
    (status) =>
        status == UnlockStatus.confirming ||
        status == UnlockStatus.submitting ||
        status == UnlockStatus.syncing,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingPermissionState &&
          chartId == other.chartId &&
          mode == other.mode &&
          allUnlocked == other.allUnlocked &&
          isLoading == other.isLoading &&
          permissionError == other.permissionError &&
          unlockError == other.unlockError &&
          setEquals(unlockedKeys, other.unlockedKeys) &&
          mapEquals(statusBySection, other.statusBySection);

  @override
  int get hashCode => Object.hash(
    chartId,
    mode,
    allUnlocked,
    isLoading,
    permissionError,
    unlockError,
    Object.hashAllUnordered(unlockedKeys),
    Object.hashAllUnordered(
      statusBySection.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
  );
}

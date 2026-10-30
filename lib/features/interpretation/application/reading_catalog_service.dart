import '../domain/interpretation_models.dart';

class ReadingCatalogService {
  const ReadingCatalogService();

  Set<ReadingSectionKey> permissionsFromCatalog({
    required String chartId,
    required ReadingCatalog catalog,
    required InterpretationMode currentMode,
  }) {
    final result = <ReadingSectionKey>{};
    final modes = catalog.pricing.buyOneGetBothModes
        ? InterpretationMode.values
        : <InterpretationMode>[currentMode];
    for (final section in catalog.sections) {
      if (!catalog.allUnlocked && !section.isUnlocked && !section.isFree) {
        continue;
      }
      for (final mode in modes) {
        result.add(
          ReadingSectionKey(
            chartId: chartId,
            mode: mode,
            groupSlug: section.groupSlug,
            sectionSlug: section.sectionSlug,
          ),
        );
      }
    }
    return Set.unmodifiable(result);
  }

  Map<String, UnlockStatus> reconcileStatuses(
    Map<String, UnlockStatus> current,
    Set<ReadingSectionKey> permissions,
  ) {
    final result = <String, UnlockStatus>{...current};
    final grantedValues = permissions.map((key) => key.value).toSet();
    for (final entry in current.entries) {
      if (entry.value == UnlockStatus.unlocked &&
          !grantedValues.contains(entry.key)) {
        result[entry.key] = UnlockStatus.idle;
      }
    }
    for (final key in permissions) {
      result[key.value] = UnlockStatus.unlocked;
    }
    return Map.unmodifiable(result);
  }
}

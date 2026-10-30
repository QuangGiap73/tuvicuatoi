import 'package:flutter/foundation.dart';

import '../../domain/interpretation_models.dart';
import 'interpretation_state.dart';

@immutable
class InterpretationViewSnapshot {
  const InterpretationViewSnapshot({required this.state});

  final InterpretationState state;

  String? get chartId => state.context?.chartId;
  InterpretationMode get mode => state.mode;
  int get contentRevision => state.contentRevision;
  InterpretationData? get content => state.interpretation;
  Set<ReadingSectionKey> get permissions => state.canonicalUnlockedKeys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterpretationViewSnapshot &&
          identical(state.context, other.state.context) &&
          state.mode == other.state.mode &&
          state.selectedTab == other.state.selectedTab &&
          identical(state.sections, other.state.sections) &&
          identical(state.catalog, other.state.catalog) &&
          state.contentRevision == other.state.contentRevision &&
          identical(state.interpretation, other.state.interpretation) &&
          setEquals(
            state.canonicalUnlockedKeys,
            other.state.canonicalUnlockedKeys,
          ) &&
          mapEquals(
            state.unlockStatusBySection,
            other.state.unlockStatusBySection,
          ) &&
          state.isLoadingChart == other.state.isLoadingChart &&
          state.isLoadingSections == other.state.isLoadingSections &&
          state.isLoadingUnlocks == other.state.isLoadingUnlocks &&
          state.isLoadingInterpretation ==
              other.state.isLoadingInterpretation &&
          state.isSavingChart == other.state.isSavingChart &&
          state.errorMessage == other.state.errorMessage;

  @override
  int get hashCode => Object.hashAll([
    identityHashCode(state.context),
    state.mode,
    state.selectedTab,
    identityHashCode(state.sections),
    identityHashCode(state.catalog),
    state.contentRevision,
    identityHashCode(state.interpretation),
    Object.hashAllUnordered(state.canonicalUnlockedKeys),
    Object.hashAllUnordered(
      state.unlockStatusBySection.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
    state.isLoadingChart,
    state.isLoadingSections,
    state.isLoadingUnlocks,
    state.isLoadingInterpretation,
    state.isSavingChart,
    state.errorMessage,
  ]);
}

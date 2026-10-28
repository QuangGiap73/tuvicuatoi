import '../../domain/interpretation_models.dart';

class InterpretationState {
  const InterpretationState({
    this.context,
    this.mode = InterpretationMode.deep,
    this.selectedTab = InterpretationTab.overview,
    this.selectedPalace,
    this.sections = const [],
    this.canonicalUnlockedKeys = const {},
    this.legacyUnlockKeys = const [],
    this.contentByMode = const {},
    this.isLoadingChart = false,
    this.isLoadingSections = false,
    this.isLoadingUnlocks = false,
    this.isLoadingInterpretation = false,
    this.isSavingChart = false,
    this.unlockStatusBySection = const {},
    this.chartError,
    this.catalogError,
    this.permissionError,
    this.contentError,
    this.unlockError,
  });

  final InterpretationChartContext? context;
  final InterpretationMode mode;
  final InterpretationTab selectedTab;
  final String? selectedPalace;
  final List<ReadingSection> sections;
  final Set<ReadingSectionKey> canonicalUnlockedKeys;
  final List<LegacyUnlockKey> legacyUnlockKeys;
  final Map<InterpretationMode, InterpretationData> contentByMode;
  final bool isLoadingChart;
  final bool isLoadingSections;
  final bool isLoadingUnlocks;
  final bool isLoadingInterpretation;
  final bool isSavingChart;
  final Map<String, UnlockStatus> unlockStatusBySection;
  final String? chartError;
  final String? catalogError;
  final String? permissionError;
  final String? contentError;
  final String? unlockError;

  InterpretationData? get interpretation => contentByMode[mode];
  bool get isBusy => isLoadingChart || isSavingChart;
  bool get isUnlocking => unlockStatusBySection.values.any(
    (status) =>
        status == UnlockStatus.confirming ||
        status == UnlockStatus.submitting ||
        status == UnlockStatus.syncing,
  );
  String? get errorMessage =>
      unlockError ??
      permissionError ??
      contentError ??
      catalogError ??
      chartError;

  InterpretationState copyWith({
    InterpretationChartContext? context,
    InterpretationMode? mode,
    InterpretationTab? selectedTab,
    String? selectedPalace,
    bool clearSelectedPalace = false,
    List<ReadingSection>? sections,
    Set<ReadingSectionKey>? canonicalUnlockedKeys,
    List<LegacyUnlockKey>? legacyUnlockKeys,
    Map<InterpretationMode, InterpretationData>? contentByMode,
    bool? isLoadingChart,
    bool? isLoadingSections,
    bool? isLoadingUnlocks,
    bool? isLoadingInterpretation,
    bool? isSavingChart,
    Map<String, UnlockStatus>? unlockStatusBySection,
    String? chartError,
    bool clearChartError = false,
    String? catalogError,
    bool clearCatalogError = false,
    String? permissionError,
    bool clearPermissionError = false,
    String? contentError,
    bool clearContentError = false,
    String? unlockError,
    bool clearUnlockError = false,
  }) => InterpretationState(
    context: context ?? this.context,
    mode: mode ?? this.mode,
    selectedTab: selectedTab ?? this.selectedTab,
    selectedPalace: clearSelectedPalace
        ? null
        : selectedPalace ?? this.selectedPalace,
    sections: sections ?? this.sections,
    canonicalUnlockedKeys: canonicalUnlockedKeys ?? this.canonicalUnlockedKeys,
    legacyUnlockKeys: legacyUnlockKeys ?? this.legacyUnlockKeys,
    contentByMode: contentByMode ?? this.contentByMode,
    isLoadingChart: isLoadingChart ?? this.isLoadingChart,
    isLoadingSections: isLoadingSections ?? this.isLoadingSections,
    isLoadingUnlocks: isLoadingUnlocks ?? this.isLoadingUnlocks,
    isLoadingInterpretation:
        isLoadingInterpretation ?? this.isLoadingInterpretation,
    isSavingChart: isSavingChart ?? this.isSavingChart,
    unlockStatusBySection: unlockStatusBySection ?? this.unlockStatusBySection,
    chartError: clearChartError ? null : chartError ?? this.chartError,
    catalogError: clearCatalogError ? null : catalogError ?? this.catalogError,
    permissionError: clearPermissionError
        ? null
        : permissionError ?? this.permissionError,
    contentError: clearContentError ? null : contentError ?? this.contentError,
    unlockError: clearUnlockError ? null : unlockError ?? this.unlockError,
  );
}

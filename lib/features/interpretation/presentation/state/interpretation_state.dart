import '../../domain/interpretation_models.dart';

class InterpretationState {
  const InterpretationState({
    this.context,
    this.mode = InterpretationMode.deep,
    this.selectedTab = InterpretationTab.overview,
    this.selectedPalace,
    this.sections = const [],
    this.unlockedKeys = const {},
    this.contentByMode = const {},
    this.isLoadingChart = false,
    this.isLoadingSections = false,
    this.isLoadingUnlocks = false,
    this.isLoadingInterpretation = false,
    this.isSavingChart = false,
    this.unlockingSectionId,
    this.errorMessage,
  });

  final InterpretationChartContext? context;
  final InterpretationMode mode;
  final InterpretationTab selectedTab;
  final String? selectedPalace;
  final List<ReadingSection> sections;
  final Set<String> unlockedKeys;
  final Map<InterpretationMode, InterpretationData> contentByMode;
  final bool isLoadingChart;
  final bool isLoadingSections;
  final bool isLoadingUnlocks;
  final bool isLoadingInterpretation;
  final bool isSavingChart;
  final String? unlockingSectionId;
  final String? errorMessage;

  InterpretationData? get interpretation => contentByMode[mode];
  bool get isBusy => isLoadingChart || isSavingChart;

  InterpretationState copyWith({
    InterpretationChartContext? context,
    InterpretationMode? mode,
    InterpretationTab? selectedTab,
    String? selectedPalace,
    bool clearSelectedPalace = false,
    List<ReadingSection>? sections,
    Set<String>? unlockedKeys,
    Map<InterpretationMode, InterpretationData>? contentByMode,
    bool? isLoadingChart,
    bool? isLoadingSections,
    bool? isLoadingUnlocks,
    bool? isLoadingInterpretation,
    bool? isSavingChart,
    String? unlockingSectionId,
    bool clearUnlockingSection = false,
    String? errorMessage,
    bool clearError = false,
  }) => InterpretationState(
    context: context ?? this.context,
    mode: mode ?? this.mode,
    selectedTab: selectedTab ?? this.selectedTab,
    selectedPalace: clearSelectedPalace
        ? null
        : selectedPalace ?? this.selectedPalace,
    sections: sections ?? this.sections,
    unlockedKeys: unlockedKeys ?? this.unlockedKeys,
    contentByMode: contentByMode ?? this.contentByMode,
    isLoadingChart: isLoadingChart ?? this.isLoadingChart,
    isLoadingSections: isLoadingSections ?? this.isLoadingSections,
    isLoadingUnlocks: isLoadingUnlocks ?? this.isLoadingUnlocks,
    isLoadingInterpretation:
        isLoadingInterpretation ?? this.isLoadingInterpretation,
    isSavingChart: isSavingChart ?? this.isSavingChart,
    unlockingSectionId: clearUnlockingSection
        ? null
        : unlockingSectionId ?? this.unlockingSectionId,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

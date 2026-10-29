import 'package:flutter/foundation.dart';

import '../../domain/interpretation_models.dart';

@immutable
class InterpretationCatalogState {
  const InterpretationCatalogState({
    this.sections = const [],
    this.catalog,
    this.selectedTab = InterpretationTab.overview,
    this.isLoading = false,
    this.error,
  });

  final List<ReadingSection> sections;
  final ReadingCatalog? catalog;
  final InterpretationTab selectedTab;
  final bool isLoading;
  final String? error;

  List<ReadingSection> get selectedSections => sections
      .where((section) => tabForSection(section) == selectedTab)
      .toList(growable: false);

  static InterpretationTab tabForSection(ReadingSection section) {
    return switch (section.groupSlug) {
      'chi_tiet_12_cung' => InterpretationTab.palaces,
      'dai_van_tieu_han' ||
      'van_han_theo_thoi_gian' => InterpretationTab.fortunes,
      'goi_y_ung_dung' ||
      'phong_thuy_cai_van' ||
      'phong_thuy_va_cai_van' => InterpretationTab.guidance,
      _ => InterpretationTab.overview,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterpretationCatalogState &&
          identical(sections, other.sections) &&
          identical(catalog, other.catalog) &&
          selectedTab == other.selectedTab &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
    identityHashCode(sections),
    identityHashCode(catalog),
    selectedTab,
    isLoading,
    error,
  );
}

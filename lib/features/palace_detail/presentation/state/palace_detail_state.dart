import '../../domain/palace_detail_models.dart';
import '../../../horoscope/domain/chart_result.dart';
import '../../../interpretation/domain/interpretation_models.dart';

class PalaceDetailState {
  const PalaceDetailState({
    this.context,
    this.relatedPalaces = const [],
    this.rules = const [],
    this.triadRules = const [],
    this.readingSection,
    this.unlockedKeys = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final PalaceDetailContext? context;
  final List<ChartPalace> relatedPalaces;
  final List<PalaceRule> rules;
  final List<TriadRule> triadRules;
  final ReadingSection? readingSection;
  final Set<String> unlockedKeys;
  final bool isLoading;
  final String? errorMessage;

  String? get freeSummary {
    for (final rule in rules) {
      if (rule.summary.trim().isNotEmpty) return rule.summary;
    }
    return readingSection?.summary.trim().isNotEmpty == true
        ? readingSection!.summary
        : null;
  }

  bool get isUnlocked {
    final section = readingSection;
    final chartId = context?.chartId;
    if (section == null) return false;
    if (section.isFree) return true;
    if (chartId == null) return false;
    final base = '$chartId:${section.groupSlug}:${section.sectionSlug}';
    return unlockedKeys.contains(base) ||
        unlockedKeys.any((key) => key.startsWith('$base:'));
  }
}

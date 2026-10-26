import '../../horoscope/domain/chart_request.dart';
import '../../horoscope/domain/chart_result.dart';
import '../../horoscope/domain/saved_chart.dart';

enum InterpretationMode {
  deep('chuyen-sau', 'Cổ Thư Chuyên Sâu'),
  everyday('doi-thuong', 'Ngôn Ngữ Đời Thường');

  const InterpretationMode(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum InterpretationTab { overview, palaces, fortunes, guidance }

class InterpretationChartContext {
  const InterpretationChartContext({
    required this.name,
    required this.chartData,
    this.chartId,
    this.request,
    this.generatedResult,
    this.savedSummary,
  });

  final String name;
  final String? chartId;
  final Map<String, dynamic> chartData;
  final ChartRequest? request;
  final ChartResult? generatedResult;
  final SavedChart? savedSummary;

  bool get isSaved => chartId != null && chartId!.trim().isNotEmpty;

  InterpretationChartContext copyWith({String? chartId}) =>
      InterpretationChartContext(
        name: name,
        chartId: chartId ?? this.chartId,
        chartData: chartData,
        request: request,
        generatedResult: generatedResult,
        savedSummary: savedSummary,
      );
}

class ReadingSection {
  const ReadingSection({
    required this.id,
    required this.groupSlug,
    required this.groupTitle,
    required this.sectionSlug,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.iconName,
    required this.coinCost,
    required this.order,
  });

  final String id;
  final String groupSlug;
  final String groupTitle;
  final String sectionSlug;
  final String title;
  final String subtitle;
  final String summary;
  final String iconName;
  final int coinCost;
  final int order;

  bool get isFree => coinCost <= 0;

  factory ReadingSection.fromJson(Map<String, dynamic> json) => ReadingSection(
    id: _text(json['id']),
    groupSlug: _text(json['groupSlug'] ?? json['group_slug']),
    groupTitle: _text(json['groupTitle'] ?? json['group_title']),
    sectionSlug: _text(json['sectionSlug'] ?? json['section_slug']),
    title: _text(json['title']),
    subtitle: _text(json['subtitle']),
    summary: _text(json['summary']),
    iconName: _text(json['iconName'] ?? json['icon_name']),
    coinCost: _integer(json['coinCost'] ?? json['coin_cost']),
    order: _integer(json['order']),
  );
}

class PalaceInterpretation {
  const PalaceInterpretation({
    required this.palace,
    required this.star,
    required this.summary,
  });

  final String palace;
  final String star;
  final String summary;

  factory PalaceInterpretation.fromJson(Map<String, dynamic> json) =>
      PalaceInterpretation(
        palace: _text(json['palace'] ?? json['name']),
        star: _text(json['star'] ?? json['stars']),
        summary: _text(json['summary'] ?? json['content']),
      );
}

class InterpretationData {
  const InterpretationData({
    this.personalityCore,
    this.careerFame,
    this.wealthAccumulation,
    this.marriageFamily,
    this.healthVitality,
    this.fengshuiAdvice,
    this.aiShortSummary,
    this.decennialFortune,
    this.yearlyFortune,
    this.palaces = const [],
    this.rawData = const {},
  });

  final String? personalityCore;
  final String? careerFame;
  final String? wealthAccumulation;
  final String? marriageFamily;
  final String? healthVitality;
  final String? fengshuiAdvice;
  final String? aiShortSummary;
  final String? decennialFortune;
  final String? yearlyFortune;
  final List<PalaceInterpretation> palaces;
  final Map<String, dynamic> rawData;

  bool get isEmpty =>
      personalityCore == null &&
      careerFame == null &&
      wealthAccumulation == null &&
      marriageFamily == null &&
      healthVitality == null &&
      fengshuiAdvice == null &&
      aiShortSummary == null &&
      decennialFortune == null &&
      yearlyFortune == null &&
      palaces.isEmpty;

  factory InterpretationData.fromJson(Map<String, dynamic> json) {
    final overview = _map(json['overview']);
    final general = _map(json['generalReading'] ?? json['general_reading']);
    final rawPalaces = json['palacesDetails'] ?? json['palaces_details'];
    return InterpretationData(
      personalityCore: _optional(
        json['personalityCore'] ??
            overview?['personality'] ??
            general?['personality'],
      ),
      careerFame: _optional(
        json['careerFame'] ?? overview?['career'] ?? general?['careerReading'],
      ),
      wealthAccumulation: _optional(
        json['wealthAccumulation'] ??
            overview?['wealth'] ??
            general?['wealthReading'],
      ),
      marriageFamily: _optional(
        json['marriageFamily'] ??
            overview?['relationships'] ??
            general?['loveReading'],
      ),
      healthVitality: _optional(
        json['healthVitality'] ??
            overview?['health'] ??
            general?['healthReading'],
      ),
      fengshuiAdvice: _optional(
        json['fengshuiAdvice'] ?? json['advice'] ?? json['dailyAdvice'],
      ),
      aiShortSummary: _optional(
        json['aiShortSummary'] ??
            json['summary'] ??
            general?['currentYearFortune'],
      ),
      decennialFortune: _optional(
        json['decennialFortune'] ?? json['majorFortune'],
      ),
      yearlyFortune: _optional(json['yearlyFortune'] ?? json['annualFortune']),
      palaces: rawPalaces is List
          ? rawPalaces
                .whereType<Map>()
                .map(
                  (item) => PalaceInterpretation.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      rawData: Map.unmodifiable(json),
    );
  }
}

class ReadingUnlockResult {
  const ReadingUnlockResult({
    required this.wasAlreadyUnlocked,
    required this.balance,
    required this.cost,
    required this.saveCost,
    required this.unlockedKeys,
  });

  final bool wasAlreadyUnlocked;
  final int? balance;
  final int? cost;
  final int? saveCost;
  final Set<String> unlockedKeys;

  factory ReadingUnlockResult.fromJson(Map<String, dynamic> json) =>
      ReadingUnlockResult(
        wasAlreadyUnlocked: json['wasAlreadyUnlocked'] == true,
        balance: _nullableInteger(json['balance']),
        cost: _nullableInteger(json['cost']),
        saveCost: _nullableInteger(json['saveCost']),
        unlockedKeys: _stringSet(json['unlockedReadingKeys']),
      );
}

String _text(Object? value) => value?.toString().trim() ?? '';
String? _optional(Object? value) {
  final result = _text(value);
  return result.isEmpty ? null : result;
}

int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
int? _nullableInteger(Object? value) => value == null ? null : _integer(value);
Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
Set<String> _stringSet(Object? value) => value is List
    ? Set.unmodifiable(value.map((item) => item.toString()))
    : const {};

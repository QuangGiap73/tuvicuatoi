import '../../horoscope/domain/chart_request.dart';
import '../../horoscope/domain/chart_result.dart';
import '../../horoscope/domain/saved_chart.dart';
import 'section_content.dart';

enum InterpretationMode {
  deep('chuyen-sau', 'Cổ Thư Chuyên Sâu'),
  everyday('doi-thuong', 'Ngôn Ngữ Đời Thường');

  const InterpretationMode(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum InterpretationTab { overview, palaces, fortunes, guidance }

enum UnlockStatus { idle, confirming, submitting, syncing, unlocked, failed }

class ReadingSectionKey {
  const ReadingSectionKey({
    required this.chartId,
    required this.mode,
    required this.groupSlug,
    required this.sectionSlug,
  });

  final String chartId;
  final InterpretationMode mode;
  final String groupSlug;
  final String sectionSlug;

  String get value => '$chartId:$groupSlug:$sectionSlug:${mode.apiValue}';

  static ReadingSectionKey? tryParseCanonical(
    String raw, {
    required String expectedChartId,
  }) {
    final parts = raw.trim().split(':');
    if (parts.length != 4 || parts.first != expectedChartId) return null;
    InterpretationMode? mode;
    for (final candidate in InterpretationMode.values) {
      if (candidate.apiValue == parts[3]) {
        mode = candidate;
        break;
      }
    }
    if (mode == null || parts[1].isEmpty || parts[2].isEmpty) return null;
    return ReadingSectionKey(
      chartId: parts[0],
      groupSlug: parts[1],
      sectionSlug: parts[2],
      mode: mode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSectionKey &&
          chartId == other.chartId &&
          mode == other.mode &&
          groupSlug == other.groupSlug &&
          sectionSlug == other.sectionSlug;

  @override
  int get hashCode => Object.hash(chartId, mode, groupSlug, sectionSlug);
}

enum LegacyUnlockKeyKind {
  fingerprint,
  engineChartId,
  missingMode,
  foreignChart,
  malformed,
}

class LegacyUnlockKey {
  const LegacyUnlockKey({
    required this.raw,
    required this.decoded,
    required this.kind,
  });

  final String raw;
  final String decoded;
  final LegacyUnlockKeyKind kind;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LegacyUnlockKey &&
          raw == other.raw &&
          decoded == other.decoded &&
          kind == other.kind;

  @override
  int get hashCode => Object.hash(raw, decoded, kind);
}

class ReadingUnlockSnapshot {
  const ReadingUnlockSnapshot({
    this.canonicalKeys = const {},
    this.legacyKeys = const [],
  });

  final Set<ReadingSectionKey> canonicalKeys;
  final List<LegacyUnlockKey> legacyKeys;

  factory ReadingUnlockSnapshot.fromRaw(
    Iterable<String> values, {
    required String expectedChartId,
  }) {
    final canonical = <ReadingSectionKey>{};
    final legacy = <LegacyUnlockKey>[];
    for (final raw in values) {
      final parsed = ReadingSectionKey.tryParseCanonical(
        raw,
        expectedChartId: expectedChartId,
      );
      if (parsed != null) {
        canonical.add(parsed);
        continue;
      }
      legacy.add(
        LegacyUnlockKeyParser.parse(raw, expectedChartId: expectedChartId),
      );
    }
    return ReadingUnlockSnapshot(
      canonicalKeys: Set.unmodifiable(canonical),
      legacyKeys: List.unmodifiable(legacy),
    );
  }
}

abstract final class LegacyUnlockKeyParser {
  static LegacyUnlockKey parse(String raw, {required String expectedChartId}) {
    final decoded = _decode(raw.trim());
    final parts = decoded.split(':');
    final prefix = parts.isEmpty ? null : parts.first;
    final kind = switch (prefix) {
      'fp' => LegacyUnlockKeyKind.fingerprint,
      final value when value?.startsWith('chart-') == true =>
        LegacyUnlockKeyKind.engineChartId,
      final value when value == expectedChartId && parts.length == 3 =>
        LegacyUnlockKeyKind.missingMode,
      final value when _looksLikeUuid(value) && value != expectedChartId =>
        LegacyUnlockKeyKind.foreignChart,
      _ => LegacyUnlockKeyKind.malformed,
    };
    return LegacyUnlockKey(raw: raw, decoded: decoded, kind: kind);
  }

  static String _decode(String value) {
    var result = value;
    for (var index = 0; index < 2; index++) {
      if (!RegExp(r'%[0-9a-fA-F]{2}').hasMatch(result)) break;
      try {
        final decoded = Uri.decodeComponent(result);
        if (decoded == result) break;
        result = decoded;
      } catch (_) {
        break;
      }
    }
    return result;
  }

  static bool _looksLikeUuid(String? value) =>
      value != null &&
      RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
      ).hasMatch(value);
}

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
    this.isPublicOverview = false,
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
  final bool isPublicOverview;

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
    isPublicOverview:
        json['isPublicOverview'] == true || json['is_public_overview'] == true,
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
        palace: _text(
          json['palace'] ??
              json['palaceName'] ??
              json['palace_name'] ??
              json['name'],
        ),
        star: _readableText(
          json['star'] ??
              json['stars'] ??
              json['mainStars'] ??
              json['main_stars'],
        ),
        summary: _readableText(
          json['summary'] ??
              json['content'] ??
              json['interpretation'] ??
              json['meaning'] ??
              json['description'] ??
              json['detail'],
        ),
      );
}

class ReadingContentItem {
  const ReadingContentItem({required this.title, required this.content});

  final String title;
  final String content;

  factory ReadingContentItem.fromJson(Map<String, dynamic> json) =>
      ReadingContentItem(
        title: _text(json['title'] ?? json['name']),
        content: _text(
          json['content'] ?? json['summary'] ?? json['description'],
        ),
      );
}

class StructuredReadingSection {
  const StructuredReadingSection({
    required this.id,
    required this.title,
    this.summary = '',
    this.items = const [],
    this.isUnlocked = false,
  });

  final String id;
  final String title;
  final String summary;
  final List<ReadingContentItem> items;
  final bool isUnlocked;

  String get fullText {
    final parts = <String>[
      if (summary.trim().isNotEmpty) summary.trim(),
      for (final item in items) ...[
        if (item.title.trim().isNotEmpty) item.title.trim(),
        if (item.content.trim().isNotEmpty) item.content.trim(),
      ],
    ];
    return parts.join('\n\n');
  }

  factory StructuredReadingSection.fromJson(Map<String, dynamic> json) =>
      StructuredReadingSection(
        id: _text(
          json['id'] ?? json['topicId'] ?? json['topic_id'] ?? json['palaceId'],
        ),
        title: _text(
          json['title'] ?? json['name'] ?? json['palaceName'] ?? json['palace'],
        ),
        summary: _text(json['summary']),
        items: _parseReadingItems(json['items']),
        isUnlocked: json['isUnlocked'] == true || json['is_unlocked'] == true,
      );
}

class TimingReading {
  const TimingReading({
    this.daiVan,
    this.tieuVan,
    this.nguyetVan,
    this.nhatVan,
  });

  final StructuredReadingSection? daiVan;
  final StructuredReadingSection? tieuVan;
  final StructuredReadingSection? nguyetVan;
  final StructuredReadingSection? nhatVan;

  bool get isEmpty =>
      daiVan == null && tieuVan == null && nguyetVan == null && nhatVan == null;

  factory TimingReading.fromJson(Object? value) {
    final json = _map(value);
    StructuredReadingSection? section(String key) {
      final data = _map(json?[key]);
      return data == null ? null : StructuredReadingSection.fromJson(data);
    }

    return TimingReading(
      daiVan: section('daiVan'),
      tieuVan: section('tieuVan'),
      nguyetVan: section('nguyetVan'),
      nhatVan: section('nhatVan'),
    );
  }
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
    this.fieldSources = const {},
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
  final Map<String, ContentSource> fieldSources;

  List<StructuredReadingSection> get overviewSections =>
      _parseStructuredSections(_interpretationSource(rawData)['overview']);

  List<StructuredReadingSection> get palaceReadingSections =>
      _parseStructuredSections(
        _interpretationSource(rawData)['palaceReadings'] ??
            _interpretationSource(rawData)['palace_readings'],
      );

  List<StructuredReadingSection> get guidanceSections =>
      _parseStructuredSections(_interpretationSource(rawData)['guidance']);

  TimingReading get timing =>
      TimingReading.fromJson(_interpretationSource(rawData)['timing']);

  ContentSource sourceFor(String field) =>
      fieldSources[field] ?? ContentSource.unavailable;

  InterpretationData withSource(ContentSource source) {
    final sources = <String, ContentSource>{};
    void add(String key, Object? value) {
      if (value is String && value.trim().isNotEmpty) sources[key] = source;
    }

    add('personalityCore', personalityCore);
    add('careerFame', careerFame);
    add('wealthAccumulation', wealthAccumulation);
    add('marriageFamily', marriageFamily);
    add('healthVitality', healthVitality);
    add('fengshuiAdvice', fengshuiAdvice);
    add('aiShortSummary', aiShortSummary);
    add('decennialFortune', decennialFortune);
    add('yearlyFortune', yearlyFortune);
    if (palaces.isNotEmpty) sources['palaces'] = source;
    return _copyWith(fieldSources: Map.unmodifiable(sources));
  }

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
      palaces.isEmpty &&
      overviewSections.isEmpty &&
      palaceReadingSections.isEmpty &&
      guidanceSections.isEmpty &&
      timing.isEmpty;

  InterpretationData mergeDetailed(InterpretationData other) {
    String? detailed(String? left, String? right) {
      final a = left?.trim() ?? '';
      final b = right?.trim() ?? '';
      if (a.isEmpty) return b.isEmpty ? null : b;
      if (b.isEmpty) return a;
      return b.length > a.length ? b : a;
    }

    final result = InterpretationData(
      personalityCore: detailed(personalityCore, other.personalityCore),
      careerFame: detailed(careerFame, other.careerFame),
      wealthAccumulation: detailed(
        wealthAccumulation,
        other.wealthAccumulation,
      ),
      marriageFamily: detailed(marriageFamily, other.marriageFamily),
      healthVitality: detailed(healthVitality, other.healthVitality),
      fengshuiAdvice: detailed(fengshuiAdvice, other.fengshuiAdvice),
      aiShortSummary: detailed(aiShortSummary, other.aiShortSummary),
      decennialFortune: detailed(decennialFortune, other.decennialFortune),
      yearlyFortune: detailed(yearlyFortune, other.yearlyFortune),
      palaces: other.palaces.length > palaces.length ? other.palaces : palaces,
      rawData: Map.unmodifiable({...rawData, ...other.rawData}),
    );
    final sources = <String, ContentSource>{};
    for (final entry in <String, (String?, String?, String?)>{
      'personalityCore': (
        personalityCore,
        other.personalityCore,
        result.personalityCore,
      ),
      'careerFame': (careerFame, other.careerFame, result.careerFame),
      'wealthAccumulation': (
        wealthAccumulation,
        other.wealthAccumulation,
        result.wealthAccumulation,
      ),
      'marriageFamily': (
        marriageFamily,
        other.marriageFamily,
        result.marriageFamily,
      ),
      'healthVitality': (
        healthVitality,
        other.healthVitality,
        result.healthVitality,
      ),
      'fengshuiAdvice': (
        fengshuiAdvice,
        other.fengshuiAdvice,
        result.fengshuiAdvice,
      ),
      'aiShortSummary': (
        aiShortSummary,
        other.aiShortSummary,
        result.aiShortSummary,
      ),
      'decennialFortune': (
        decennialFortune,
        other.decennialFortune,
        result.decennialFortune,
      ),
      'yearlyFortune': (
        yearlyFortune,
        other.yearlyFortune,
        result.yearlyFortune,
      ),
    }.entries) {
      final (left, right, selected) = entry.value;
      if (selected == null) continue;
      sources[entry.key] = selected == right && right != left
          ? other.sourceFor(entry.key)
          : sourceFor(entry.key);
    }
    if (result.palaces.isNotEmpty) {
      sources['palaces'] = identical(result.palaces, other.palaces)
          ? other.sourceFor('palaces')
          : sourceFor('palaces');
    }
    return result._copyWith(fieldSources: Map.unmodifiable(sources));
  }

  InterpretationData _copyWith({Map<String, ContentSource>? fieldSources}) =>
      InterpretationData(
        personalityCore: personalityCore,
        careerFame: careerFame,
        wealthAccumulation: wealthAccumulation,
        marriageFamily: marriageFamily,
        healthVitality: healthVitality,
        fengshuiAdvice: fengshuiAdvice,
        aiShortSummary: aiShortSummary,
        decennialFortune: decennialFortune,
        yearlyFortune: yearlyFortune,
        palaces: palaces,
        rawData: rawData,
        fieldSources: fieldSources ?? this.fieldSources,
      );

  factory InterpretationData.fromJson(Map<String, dynamic> json) {
    // The saved-reading and generated-reading endpoints do not always wrap the
    // payload in the same way. Unwrap only known envelope keys and keep the
    // original response in rawData so new backend fields remain discoverable.
    final source = _unwrapInterpretation(json);
    final overview = _map(source['overview']);
    final overviewSections = _parseStructuredSections(source['overview']);
    final palaceReadingSections = _parseStructuredSections(
      source['palaceReadings'] ?? source['palace_readings'],
    );
    final guidanceSections = _parseStructuredSections(source['guidance']);
    final timing = TimingReading.fromJson(source['timing']);
    String? overviewText(String id) =>
        _optional(_findStructuredSection(overviewSections, id)?.fullText);
    final guidanceText = _optional(
      guidanceSections
          .map((section) => section.fullText)
          .where((text) => text.trim().isNotEmpty)
          .join('\n\n'),
    );
    final general = _map(
      source['generalReading'] ??
          source['general_reading'] ??
          source['general'],
    );
    final rawPalaces =
        source['palacesDetails'] ??
        source['palaces_details'] ??
        source['palaces'] ??
        _findValue(json, const [
          'palacesDetails',
          'palaces_details',
          'palaceReadings',
          'palace_readings',
          'palaces',
        ], allowCollection: true);
    return InterpretationData(
      personalityCore: _optional(
        source['personalityCore'] ??
            source['personality_core'] ??
            source['personality'] ??
            source['destiny'] ??
            overview?['personality'] ??
            overview?['personalityCore'] ??
            overview?['personality_core'] ??
            overview?['destiny'] ??
            general?['personalityCore'] ??
            general?['personality_core'] ??
            general?['personality'] ??
            general?['destiny'] ??
            overviewText('CD01_TINH_CACH_BAN_THAN') ??
            _findValue(json, const [
              'personalityCore',
              'personality_core',
              'personality',
              'destiny',
              'banMenhThan',
              'ban_menh_than',
            ]),
      ),
      careerFame: _optional(
        source['careerFame'] ??
            source['career_fame'] ??
            overview?['career'] ??
            general?['careerFame'] ??
            general?['career_fame'] ??
            general?['careerReading'] ??
            general?['career_reading'] ??
            overviewText('CD02_CONG_DANH') ??
            _findValue(json, const [
              'careerFame',
              'career_fame',
              'careerReading',
              'career_reading',
              'career',
            ]),
      ),
      wealthAccumulation: _optional(
        source['wealthAccumulation'] ??
            source['wealth_accumulation'] ??
            overview?['wealth'] ??
            general?['wealthAccumulation'] ??
            general?['wealth_accumulation'] ??
            general?['wealthReading'] ??
            general?['wealth_reading'] ??
            overviewText('CD04_TAI_SAN_DIEN_SAN') ??
            _findValue(json, const [
              'wealthAccumulation',
              'wealth_accumulation',
              'wealthReading',
              'wealth_reading',
              'wealth',
            ]),
      ),
      marriageFamily: _optional(
        source['marriageFamily'] ??
            source['marriage_family'] ??
            overview?['relationships'] ??
            general?['marriageFamily'] ??
            general?['marriage_family'] ??
            general?['loveReading'] ??
            general?['love_reading'] ??
            overviewText('CD03_TINH_DUYEN_HON_NHAN_GIA_DINH') ??
            _findValue(json, const [
              'marriageFamily',
              'marriage_family',
              'loveReading',
              'love_reading',
              'relationships',
            ]),
      ),
      healthVitality: _optional(
        source['healthVitality'] ??
            source['health_vitality'] ??
            overview?['health'] ??
            general?['healthVitality'] ??
            general?['health_vitality'] ??
            general?['healthReading'] ??
            general?['health_reading'] ??
            overviewText('CD05_SUC_KHOE_BENH_TAT') ??
            _findValue(json, const [
              'healthVitality',
              'health_vitality',
              'healthReading',
              'health_reading',
              'health',
            ]),
      ),
      fengshuiAdvice: _optional(
        source['fengshuiAdvice'] ??
            source['fengshui_advice'] ??
            source['advice'] ??
            source['dailyAdvice'] ??
            source['daily_advice'] ??
            guidanceText ??
            _findValue(json, const [
              'fengshuiAdvice',
              'fengshui_advice',
              'fengShuiAdvice',
              'advice',
            ]),
      ),
      aiShortSummary: _optional(
        source['aiShortSummary'] ??
            source['ai_short_summary'] ??
            source['summary'] ??
            _findValue(json, const [
              'aiShortSummary',
              'ai_short_summary',
              'overallSummary',
              'overall_summary',
            ]),
      ),
      decennialFortune: _optional(
        source['decennialFortune'] ??
            source['decennial_fortune'] ??
            source['majorFortune'] ??
            source['major_fortune'] ??
            timing.daiVan?.fullText ??
            _findValue(json, const [
              'decennialFortune',
              'decennial_fortune',
              'majorFortune',
              'major_fortune',
            ]),
      ),
      yearlyFortune: _optional(
        source['yearlyFortune'] ??
            source['yearly_fortune'] ??
            source['annualFortune'] ??
            source['annual_fortune'] ??
            timing.tieuVan?.fullText ??
            _findValue(json, const [
              'yearlyFortune',
              'yearly_fortune',
              'annualFortune',
              'annual_fortune',
            ]),
      ),
      palaces: palaceReadingSections.isNotEmpty
          ? palaceReadingSections
                .map(
                  (section) => PalaceInterpretation(
                    palace: section.title,
                    star: '',
                    summary: section.fullText,
                  ),
                )
                .toList(growable: false)
          : _parsePalaces(rawPalaces),
      rawData: Map.unmodifiable(json),
    );
  }
}

Map<String, dynamic> _interpretationSource(Map<String, dynamic> rawData) =>
    _unwrapInterpretation(rawData);

List<ReadingContentItem> _parseReadingItems(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable(
    value
        .whereType<Map>()
        .map(
          (item) =>
              ReadingContentItem.fromJson(Map<String, dynamic>.from(item)),
        )
        .where(
          (item) =>
              item.title.trim().isNotEmpty || item.content.trim().isNotEmpty,
        ),
  );
}

List<StructuredReadingSection> _parseStructuredSections(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable(
    value
        .whereType<Map>()
        .map(
          (item) => StructuredReadingSection.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (section) =>
              section.id.trim().isNotEmpty ||
              section.title.trim().isNotEmpty ||
              section.fullText.trim().isNotEmpty,
        ),
  );
}

StructuredReadingSection? _findStructuredSection(
  List<StructuredReadingSection> sections,
  String id,
) {
  final wanted = _normalizedKey(id);
  for (final section in sections) {
    if (_normalizedKey(section.id) == wanted) return section;
  }
  return null;
}

Object? _findValue(
  Object? node,
  List<String> keys, {
  int depth = 0,
  bool allowCollection = false,
}) {
  if (depth > 12) return null;
  final wanted = keys.map(_normalizedKey).toSet();
  if (node is Map) {
    for (final entry in node.entries) {
      if (wanted.contains(_normalizedKey(entry.key.toString()))) {
        final value = entry.value;
        if (allowCollection && (value is Map || value is List)) return value;
        if (value != null && _readableText(value).isNotEmpty) return value;
      }
    }
    for (final value in node.values) {
      final found = _findValue(
        value,
        keys,
        depth: depth + 1,
        allowCollection: allowCollection,
      );
      if (found != null) return found;
    }
  } else if (node is List) {
    for (final value in node) {
      final found = _findValue(
        value,
        keys,
        depth: depth + 1,
        allowCollection: allowCollection,
      );
      if (found != null) return found;
    }
  }
  return null;
}

String _normalizedKey(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

Map<String, dynamic> _unwrapInterpretation(Map<String, dynamic> json) {
  var current = json;
  for (var depth = 0; depth < 4; depth++) {
    Map<String, dynamic>? nested;
    for (final key in const [
      'interpretation',
      'reading',
      'result',
      'content',
      'data',
    ]) {
      nested = _map(current[key]);
      if (nested != null) break;
    }
    if (nested == null || identical(nested, current)) break;
    current = nested;
  }
  return current;
}

List<PalaceInterpretation> _parsePalaces(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              PalaceInterpretation.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((item) => item.palace.isNotEmpty || item.summary.isNotEmpty)
        .toList(growable: false);
  }
  if (raw is! Map) return const [];
  final result = <PalaceInterpretation>[];
  for (final entry in raw.entries) {
    final value = entry.value;
    if (value is Map) {
      final item = Map<String, dynamic>.from(value);
      if (item['palace'] == null &&
          item['palaceName'] == null &&
          item['palace_name'] == null &&
          item['name'] == null) {
        item['palace'] = entry.key.toString();
      }
      result.add(PalaceInterpretation.fromJson(item));
    } else if (value != null && value.toString().trim().isNotEmpty) {
      result.add(
        PalaceInterpretation(
          palace: entry.key.toString(),
          star: '',
          summary: value.toString().trim(),
        ),
      );
    }
  }
  return List.unmodifiable(result);
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
String _readableText(Object? value) {
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) {
            return _text(item['name'] ?? item['title'] ?? item['content']);
          }
          return _text(item);
        })
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
  if (value is Map) {
    return _text(
      value['content'] ??
          value['summary'] ??
          value['meaning'] ??
          value['description'] ??
          value['detail'],
    );
  }
  return _text(value);
}

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

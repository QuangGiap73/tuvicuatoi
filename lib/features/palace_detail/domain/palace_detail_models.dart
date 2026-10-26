import '../../horoscope/domain/chart_result.dart';
import '../../interpretation/domain/interpretation_models.dart';

class PalaceDetailContext {
  const PalaceDetailContext({
    required this.chart,
    required this.palace,
    this.chartId,
  });

  final ChartResult chart;
  final ChartPalace palace;
  final String? chartId;

  bool get isSaved => chartId != null && chartId!.trim().isNotEmpty;
}

class PalaceRule {
  const PalaceRule({
    required this.id,
    required this.name,
    required this.palace,
    required this.stars,
    required this.summary,
    required this.content,
  });

  final String id;
  final String name;
  final String palace;
  final List<String> stars;
  final String summary;
  final String content;

  factory PalaceRule.fromJson(Map<String, dynamic> json) => PalaceRule(
    id: _text(json['id']),
    name: _text(json['name'] ?? json['title']),
    palace: _text(json['palace']),
    stars: _strings(json['stars']),
    summary: _text(
      json['summary'] ?? json['shortSummary'] ?? json['description'],
    ),
    content: _text(json['content'] ?? json['meaning'] ?? json['detail']),
  );
}

class TriadRule {
  const TriadRule({
    required this.title,
    required this.nature,
    required this.meaning,
  });

  final String title;
  final String nature;
  final String meaning;

  factory TriadRule.fromJson(Map<String, dynamic> json) => TriadRule(
    title: _text(json['title'] ?? json['name']),
    nature: _text(json['nature'] ?? json['summary']),
    meaning: _text(json['meaning'] ?? json['content']),
  );
}

class PalaceDetailPayload {
  const PalaceDetailPayload({
    this.rules = const [],
    this.triadRules = const [],
  });

  final List<PalaceRule> rules;
  final List<TriadRule> triadRules;
}

ReadingSection? readingSectionForPalace(
  Iterable<ReadingSection> sections,
  String palaceName,
) {
  final palaceSlug = normalizePalaceSlug(palaceName);
  for (final section in sections) {
    final sectionSlug = normalizePalaceSlug(
      '${section.groupSlug}_${section.sectionSlug}_${section.title}',
    );
    if (sectionSlug.contains('cung_$palaceSlug') ||
        sectionSlug.endsWith(palaceSlug)) {
      return section;
    }
  }
  return null;
}

String normalizePalaceSlug(String value) {
  var result = value.trim().toLowerCase();
  const replacements = <String, String>{
    'áàảãạăắằẳẵặâấầẩẫậ': 'a',
    'éèẻẽẹêếềểễệ': 'e',
    'íìỉĩị': 'i',
    'óòỏõọôốồổỗộơớờởỡợ': 'o',
    'úùủũụưứừửữự': 'u',
    'ýỳỷỹỵ': 'y',
    'đ': 'd',
  };
  for (final entry in replacements.entries) {
    for (final character in entry.key.split('')) {
      result = result.replaceAll(character, entry.value);
    }
  }
  return result
      .replaceFirst(RegExp(r'^cung\s+'), '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

String _text(Object? value) => value?.toString().trim() ?? '';
List<String> _strings(Object? value) => value is List
    ? value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false)
    : const [];

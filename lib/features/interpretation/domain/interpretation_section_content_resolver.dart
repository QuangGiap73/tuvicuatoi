import 'interpretation_models.dart';
import 'section_content.dart';

class InterpretationSectionContentResolver {
  const InterpretationSectionContentResolver();

  static const _palaceBySection = <String, String>{
    'cung_menh': 'MỆNH',
    'cung_phu_mau': 'PHỤ MẪU',
    'cung_phu_the': 'PHU THÊ',
    'cung_quan_loc': 'QUAN LỘC',
    'cung_tai_bach': 'TÀI BẠCH',
    'cung_tat_ach': 'TẬT ÁCH',
    'cung_dien_trach': 'ĐIỀN TRẠCH',
  };

  SectionContent resolve({
    required ReadingSection section,
    required InterpretationData interpretation,
    required Map<String, dynamic> chartData,
  }) {
    final resolved = switch (section.sectionSlug) {
      'ban_menh_va_than' =>
        _fromInterpretation(
              interpretation.personalityCore,
              interpretation.sourceFor('personalityCore'),
            ) ??
            _fromGeneral(chartData, 'menhReading'),
      'am_duong_ngu_hanh' => _amDuongNguHanh(chartData),
      'tong_quan_nhan_sinh' =>
        _fromInterpretation(
              interpretation.aiShortSummary,
              interpretation.sourceFor('aiShortSummary'),
            ) ??
            _fromChartField(chartData, 'aiSummary'),
      final slug when _palaceBySection.containsKey(slug) => _palace(
        palaceName: _palaceBySection[slug]!,
        interpretation: interpretation,
        chartData: chartData,
      ),
      'dai_van_10_nam' => _fromInterpretation(
        interpretation.decennialFortune,
        interpretation.sourceFor('decennialFortune'),
      ),
      'tieu_han_nam_nay' =>
        _fromInterpretation(
              interpretation.yearlyFortune,
              interpretation.sourceFor('yearlyFortune'),
            ) ??
            _fromGeneral(chartData, 'currentYearFortune'),
      'luu_nien_5_nam' => null,
      'phong_thuy_ung_dung' => _fromInterpretation(
        interpretation.fengshuiAdvice,
        interpretation.sourceFor('fengshuiAdvice'),
      ),
      'loi_khuyen_nghe_nghiep' =>
        _fromInterpretation(
              interpretation.careerFame,
              interpretation.sourceFor('careerFame'),
            ) ??
            _fromGeneral(chartData, 'careerReading'),
      'tuong_hop_nhan_duyen' =>
        _fromInterpretation(
              interpretation.marriageFamily,
              interpretation.sourceFor('marriageFamily'),
            ) ??
            _fromGeneral(chartData, 'loveReading'),
      _ => null,
    };

    if (resolved != null) {
      final preview = section.sectionSlug == 'am_duong_ngu_hanh'
          ? resolved.text
          : _firstText([section.summary, section.subtitle, resolved.text]);
      return SectionContent(
        preview: preview,
        fullContent: resolved.text,
        source: resolved.source,
        isFallback: resolved.isFallback,
      );
    }
    return _catalogFallback(section);
  }

  _Resolved? _palace({
    required String palaceName,
    required InterpretationData interpretation,
    required Map<String, dynamic> chartData,
  }) {
    final chartPalace = _findChartPalace(chartData, palaceName);
    if (chartPalace != null) {
      final starNames = _mainStarNames(chartPalace);
      for (final palace in interpretation.palaces) {
        if (_palaceKey(palace.palace) != _palaceKey(palaceName)) continue;
        if ((_starsMatch(palace.star, starNames) ||
                _starsMatch(palace.summary, starNames)) &&
            palace.summary.trim().isNotEmpty) {
          return _Resolved(
            palace.summary.trim(),
            interpretation.sourceFor('palaces'),
            false,
          );
        }
      }

      final summary = _firstMapText(chartPalace, const [
        'summary',
        'interpretation',
        'description',
        'meaning',
      ]);
      if (summary != null) {
        return _Resolved(summary, ContentSource.chartPalace, true);
      }
      final descriptions = _mainStarDescriptions(chartPalace);
      if (descriptions.isNotEmpty) {
        return _Resolved(
          descriptions.join('\n\n'),
          ContentSource.chartPalace,
          true,
        );
      }
    }
    return null;
  }

  _Resolved? _amDuongNguHanh(Map<String, dynamic> chartData) {
    const fields = <(String, String)>[
      ('amDuong', 'Âm dương'),
      ('amDuongThuanLy', 'Thuận lý âm dương'),
      ('menh', 'Mệnh'),
      ('cuc', 'Cục'),
      ('menhCucBinhHoa', 'Quan hệ Mệnh – Cục'),
      ('thanCu', 'Thân cư'),
      ('chuMenh', 'Chủ mệnh'),
      ('chuThan', 'Chủ thân'),
    ];
    final lines = <String>[];
    for (final (key, label) in fields) {
      final value = _text(chartData[key]);
      if (value != null) lines.add('$label: $value');
    }
    if (lines.isEmpty) return null;
    return _Resolved(lines.join('\n'), ContentSource.chartGeneralReading, true);
  }

  static _Resolved? _fromInterpretation(String? value, ContentSource source) {
    final text = _text(value);
    if (text == null) return null;
    return _Resolved(text, source, false);
  }

  static _Resolved? _fromGeneral(Map<String, dynamic> chartData, String field) {
    final general = _map(
      chartData['generalReading'] ?? chartData['general_reading'],
    );
    final text = _text(general?[field]);
    return text == null
        ? null
        : _Resolved(text, ContentSource.chartGeneralReading, true);
  }

  static _Resolved? _fromChartField(
    Map<String, dynamic> chartData,
    String field,
  ) {
    final text = _text(chartData[field]);
    return text == null
        ? null
        : _Resolved(text, ContentSource.chartGeneralReading, true);
  }

  static SectionContent _catalogFallback(ReadingSection section) {
    final text = _firstText([section.summary, section.subtitle]);
    if (text.isEmpty) {
      return const SectionContent(
        preview: '',
        fullContent: null,
        source: ContentSource.unavailable,
        isFallback: true,
      );
    }
    return SectionContent(
      preview: text,
      fullContent: text,
      source: ContentSource.catalogSummary,
      isFallback: true,
    );
  }

  static Map<String, dynamic>? _findChartPalace(
    Map<String, dynamic> chartData,
    String palaceName,
  ) {
    final raw = chartData['palaces'];
    final values = raw is Map
        ? raw.values
        : raw is List
        ? raw
        : const <Object?>[];
    for (final value in values) {
      final palace = _map(value);
      if (palace == null) continue;
      final name = _text(
        palace['name'] ?? palace['palace'] ?? palace['palaceName'],
      );
      if (name != null && _palaceKey(name) == _palaceKey(palaceName)) {
        return palace;
      }
    }
    return null;
  }

  static List<String> _mainStarNames(Map<String, dynamic> palace) =>
      _mainStars(palace)
          .map((star) => _text(star['name']))
          .whereType<String>()
          .toList(growable: false);

  static List<String> _mainStarDescriptions(Map<String, dynamic> palace) =>
      _mainStars(palace)
          .map(
            (star) => _firstMapText(star, const [
              'description',
              'summary',
              'meaning',
            ]),
          )
          .whereType<String>()
          .toList(growable: false);

  static List<Map<String, dynamic>> _mainStars(Map<String, dynamic> palace) =>
      (palace['mainStars'] ?? palace['main_stars']) is List
      ? ((palace['mainStars'] ?? palace['main_stars']) as List)
            .map(_map)
            .whereType<Map<String, dynamic>>()
            .toList(growable: false)
      : const [];

  static bool _starsMatch(String interpretationStars, List<String> chartStars) {
    if (chartStars.isEmpty || interpretationStars.trim().isEmpty) return false;
    final interpreted = _normalize(interpolation: interpretationStars);
    return chartStars.any((star) {
      final expected = _normalize(interpolation: star);
      return expected.isNotEmpty &&
          (interpreted.contains(expected) || expected.contains(interpreted));
    });
  }

  static String _palaceKey(String value) =>
      _normalize(interpolation: value).replaceFirst(RegExp(r'^CUNG '), '');

  static String _normalize({required String interpolation}) {
    var value = interpolation.toUpperCase().trim();
    const groups = <String, String>{
      'A': 'ÁÀẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬ',
      'E': 'ÉÈẺẼẸÊẾỀỂỄỆ',
      'I': 'ÍÌỈĨỊ',
      'O': 'ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ',
      'U': 'ÚÙỦŨỤƯỨỪỬỮỰ',
      'Y': 'ÝỲỶỸỴ',
      'D': 'Đ',
    };
    for (final entry in groups.entries) {
      for (final rune in entry.value.runes) {
        value = value.replaceAll(String.fromCharCode(rune), entry.key);
      }
    }
    return value.replaceAll(RegExp(r'[^A-Z0-9]+'), ' ').trim();
  }

  static String? _firstMapText(Map<String, dynamic> map, List<String> fields) {
    for (final field in fields) {
      final value = _text(map[field]);
      if (value != null) return value;
    }
    return null;
  }

  static String _firstText(Iterable<Object?> values) {
    for (final value in values) {
      final text = _text(value);
      if (text != null) return text;
    }
    return '';
  }

  static String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static Map<String, dynamic>? _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;
}

class _Resolved {
  const _Resolved(this.text, this.source, this.isFallback);
  final String text;
  final ContentSource source;
  final bool isFallback;
}

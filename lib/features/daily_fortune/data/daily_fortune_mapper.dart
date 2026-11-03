import '../domain/daily_calendar.dart';
import '../domain/daily_fortune.dart';
import '../domain/fortune_hour.dart';
import '../domain/personal_fortune.dart';

class DailyFortuneMapper {
  const DailyFortuneMapper._();

  static DailyFortune fromResponse(
    Map<dynamic, dynamic> response,
    DateTime fallbackDate,
  ) {
    final root = _map(response);
    final nested = _map(root['data']);
    final envelope = nested.containsKey('dailyCalendar') ? nested : root;
    final calendarJson = _map(envelope['dailyCalendar']);
    if (calendarJson.isEmpty) {
      throw const FormatException('Thiếu dailyCalendar');
    }
    final date = DateTime.tryParse(_text(envelope['date'])) ?? fallbackDate;
    final calendar = _calendar(calendarJson, date);
    final personalJson = _map(envelope['personalFortune']);
    return DailyFortune(
      date: DateTime(date.year, date.month, date.day),
      calendar: calendar,
      personal: personalJson.isEmpty ? null : _personal(personalJson),
      aiSuggestedPrompt: _nullable(envelope['aiSuggestedPrompt']),
      rawData: Map.unmodifiable(envelope),
    );
  }

  static DailyCalendar _calendar(Map<String, dynamic> json, DateTime fallback) {
    final truc = _map(json['trucInfo']);
    final mansion = _map(json['tuInfo']);
    return DailyCalendar(
      solarDate: DateTime.tryParse(_text(json['solarDateStr'])) ?? fallback,
      dayOfWeek: _text(json['dayOfWeek']),
      lunarDay: _integer(json['lunarDay']),
      lunarMonth: _integer(json['lunarMonth']),
      lunarYear: _integer(json['lunarYear']),
      isLeapMonth: json['isLeapMonth'] == true,
      canChiDay: _text(json['canChiDay']),
      canChiMonth: _text(json['canChiMonth']),
      canChiYear: _text(json['canChiYear']),
      canChiHour: _text(json['canChiHour']),
      dayNayin: _text(json['dayNayin']),
      dayElement: _text(json['dayElement']),
      solarTerm: _text(json['solarTerm']),
      truc: truc.isEmpty
          ? null
          : CalendarTruc(
              name: _text(truc['name']),
              type: _text(truc['type']),
              quality: _text(truc['quality']),
              summary: _text(truc['summary']),
              goodFor: _strings(truc['goodFor']),
              badFor: _strings(truc['badFor']),
            ),
      lunarMansion: mansion.isEmpty
          ? null
          : LunarMansion(
              name: _text(mansion['name']),
              element: _text(mansion['element']),
              animal: _text(mansion['animal']),
              nature: _text(mansion['nature']),
              description: _text(mansion['desc'] ?? mansion['description']),
            ),
      hours: _hours(json['hours']),
      joyDirection: _nullable(json['hyThan']),
      wealthDirection: _nullable(json['taiThan']),
      badDirection: _nullable(json['hacThan']),
      recommendedActivities: _strings(json['recommendedActivities']),
      restrictedActivities: _strings(json['restrictedActivities']),
    );
  }

  static PersonalFortune _personal(Map<String, dynamic> json) {
    final aspects = _map(
      json['lifeAspects'] ?? json['life_aspects'] ?? json['detailedAnalysis'],
    );
    final mutagens = <String, MutagenStar>{};
    for (final entry in _map(json['mutagenStars']).entries) {
      final value = _map(entry.value);
      if (value.isEmpty) continue;
      mutagens[entry.key] = MutagenStar(
        star: _text(value['star']),
        palace: _text(value['palace']),
      );
    }
    return PersonalFortune(
      chartName: _text(json['chartName']),
      birthYearCanChi: _text(json['birthYearCanChi']),
      birthBranch: _text(json['birthBranch']),
      destinyNayin: _text(json['destinyNayin']),
      destinyElement: _text(json['destinyElement']),
      palaceName: _text(json['palaceName']),
      palaceBranch: _text(json['palaceBranch']),
      majorStars: _strings(json['majorStars']),
      dailyStars: _strings(json['dailyStars']),
      branchRelationType: _text(json['branchRelationType']),
      branchRelationDescription: _text(json['branchRelationDesc']),
      elementRelationType: _text(json['elementRelationType']),
      elementRelationDescription: _text(json['elementRelationDesc']),
      mutagenStars: Map.unmodifiable(mutagens),
      overallScore: _integer(json['overallScore']).clamp(0, 100),
      overallRating: _text(json['overallRating']),
      careerAdvice: _firstText([
        json['careerAdvice'],
        json['career'],
        aspects['career'],
        aspects['work'],
      ]),
      wealthAdvice: _firstText([
        json['wealthAdvice'],
        json['wealth'],
        json['financeAdvice'],
        aspects['wealth'],
        aspects['finance'],
      ]),
      loveAdvice: _firstText([
        json['loveAdvice'],
        json['love'],
        json['relationshipAdvice'],
        aspects['love'],
        aspects['relationships'],
      ]),
      healthAdvice: _firstText([
        json['healthAdvice'],
        json['health'],
        aspects['health'],
      ]),
      luckyColor: _firstText([
        json['luckyColor'],
        json['lucky_color'],
        json['prosperityColor'],
      ]),
      luckyColorReason: _firstText([
        json['luckyColorReason'],
        json['lucky_color_reason'],
        json['colorAdvice'],
      ]),
      luckyDirection: _firstText([
        json['luckyDirection'],
        json['lucky_direction'],
        json['travelDirection'],
      ]),
      personalizedHours: _hours(json['personalizedHours']),
    );
  }

  static List<FortuneHour> _hours(Object? value) => value is List
      ? List.unmodifiable(
          value.whereType<Map>().map((item) {
            final map = _map(item);
            return FortuneHour(
              branch: _text(map['branch']),
              time: _text(map['time']),
              isAuspicious: map['isAuspicious'] == true,
              starName: _text(map['starName']),
              affinityType: _nullable(map['affinityType']),
              affinityLabel: _nullable(map['affinityLabel']),
              affinityBadge: _nullable(map['affinityBadge']),
            );
          }),
        )
      : const [];

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};
  static String _text(Object? value) => value?.toString().trim() ?? '';
  static String? _nullable(Object? value) {
    final result = _text(value);
    return result.isEmpty ? null : result;
  }

  static int _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse(_text(value)) ?? 0;
  static String _firstText(Iterable<Object?> values) {
    for (final value in values) {
      final text = _text(value);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static List<String> _strings(Object? value) => value is List
      ? List.unmodifiable(value.map(_text).where((item) => item.isNotEmpty))
      : const [];
}

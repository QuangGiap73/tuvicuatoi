import 'fortune_hour.dart';

class DailyCalendar {
  const DailyCalendar({
    required this.solarDate,
    required this.dayOfWeek,
    required this.lunarDay,
    required this.lunarMonth,
    required this.lunarYear,
    required this.isLeapMonth,
    required this.canChiDay,
    required this.canChiMonth,
    required this.canChiYear,
    required this.canChiHour,
    required this.dayNayin,
    required this.dayElement,
    required this.solarTerm,
    required this.hours,
    required this.recommendedActivities,
    required this.restrictedActivities,
    this.truc,
    this.lunarMansion,
    this.joyDirection,
    this.wealthDirection,
    this.badDirection,
  });
  final DateTime solarDate;
  final String dayOfWeek;
  final int lunarDay;
  final int lunarMonth;
  final int lunarYear;
  final bool isLeapMonth;
  final String canChiDay;
  final String canChiMonth;
  final String canChiYear;
  final String canChiHour;
  final String dayNayin;
  final String dayElement;
  final String solarTerm;
  final CalendarTruc? truc;
  final LunarMansion? lunarMansion;
  final List<FortuneHour> hours;
  final String? joyDirection;
  final String? wealthDirection;
  final String? badDirection;
  final List<String> recommendedActivities;
  final List<String> restrictedActivities;
  String get lunarDateLabel =>
      '$lunarDay/$lunarMonth${isLeapMonth ? ' nhuận' : ''}/$lunarYear';
}

class CalendarTruc {
  const CalendarTruc({
    required this.name,
    required this.type,
    required this.quality,
    required this.summary,
    required this.goodFor,
    required this.badFor,
  });
  final String name;
  final String type;
  final String quality;
  final String summary;
  final List<String> goodFor;
  final List<String> badFor;
}

class LunarMansion {
  const LunarMansion({
    required this.name,
    required this.element,
    required this.animal,
    required this.nature,
    required this.description,
  });
  final String name;
  final String element;
  final String animal;
  final String nature;
  final String description;
}

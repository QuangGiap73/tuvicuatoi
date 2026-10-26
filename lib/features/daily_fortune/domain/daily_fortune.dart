import 'daily_fortune_reading.dart';

class DailyFortune {
  const DailyFortune({
    required this.date,
    required this.summary,
    this.canChi,
    this.canChiDay,
    this.canChiMonth,
    this.canChiYear,
    this.canChiHour,
    this.lunarDate,
    this.napAm,
    this.dayElement,
    this.dayOfficer,
    this.dayRating,
    this.dayOfficerDescription,
    this.solarTerm,
    this.lunarMansion,
    this.lunarMansionRating,
    this.lunarMansionDescription,
    this.joyDirection,
    this.wealthDirection,
    this.dailyPalace,
    this.fortuneScore = 3,
    this.career,
    this.wealth,
    this.love,
    this.health,
    this.auspiciousHours = const [],
    this.inauspiciousHours = const [],
    this.shouldDo = const [],
    this.shouldAvoid = const [],
    this.advice,
    this.rawData = const {},
  });

  final DateTime date;
  final String summary;
  final String? canChi;
  final String? canChiDay;
  final String? canChiMonth;
  final String? canChiYear;
  final String? canChiHour;
  final String? lunarDate;
  final String? napAm;
  final String? dayElement;
  final String? dayOfficer;
  final String? dayRating;
  final String? dayOfficerDescription;
  final String? solarTerm;
  final String? lunarMansion;
  final String? lunarMansionRating;
  final String? lunarMansionDescription;
  final String? joyDirection;
  final String? wealthDirection;
  final String? dailyPalace;
  final double fortuneScore;
  final String? career;
  final String? wealth;
  final String? love;
  final String? health;
  final List<String> auspiciousHours;
  final List<String> inauspiciousHours;
  final List<String> shouldDo;
  final List<String> shouldAvoid;
  final String? advice;
  final Map<String, dynamic> rawData;

  DailyFortune applyReading(DailyFortuneReading reading) => DailyFortune(
    date: date,
    summary: reading.summary ?? summary,
    canChi: canChi,
    canChiDay: canChiDay,
    canChiMonth: canChiMonth,
    canChiYear: canChiYear,
    canChiHour: canChiHour,
    lunarDate: lunarDate,
    napAm: napAm,
    dayElement: dayElement,
    dayOfficer: reading.dayOfficer ?? dayOfficer,
    dayRating: reading.dayRating ?? dayRating,
    dayOfficerDescription:
        reading.dayOfficerDescription ?? dayOfficerDescription,
    solarTerm: reading.solarTerm ?? solarTerm,
    lunarMansion: reading.lunarMansion ?? lunarMansion,
    lunarMansionRating: reading.lunarMansionRating ?? lunarMansionRating,
    lunarMansionDescription:
        reading.lunarMansionDescription ?? lunarMansionDescription,
    joyDirection: reading.joyDirection ?? joyDirection,
    wealthDirection: reading.wealthDirection ?? wealthDirection,
    dailyPalace: reading.dailyPalace ?? dailyPalace,
    fortuneScore: reading.fortuneScore ?? fortuneScore,
    career: reading.career,
    wealth: reading.wealth,
    love: reading.love,
    health: reading.health,
    auspiciousHours: reading.auspiciousHours.isEmpty
        ? auspiciousHours
        : reading.auspiciousHours,
    inauspiciousHours: reading.inauspiciousHours.isEmpty
        ? inauspiciousHours
        : reading.inauspiciousHours,
    shouldDo: reading.shouldDo.isEmpty ? shouldDo : reading.shouldDo,
    shouldAvoid: reading.shouldAvoid.isEmpty
        ? shouldAvoid
        : reading.shouldAvoid,
    advice: reading.advice,
    rawData: {...rawData, 'reading': reading.rawData},
  );
}

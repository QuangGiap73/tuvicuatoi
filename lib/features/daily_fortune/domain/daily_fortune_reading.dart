class DailyFortuneReading {
  const DailyFortuneReading({
    this.summary,
    this.career,
    this.wealth,
    this.love,
    this.health,
    this.advice,
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
    this.fortuneScore,
    this.auspiciousHours = const [],
    this.inauspiciousHours = const [],
    this.shouldDo = const [],
    this.shouldAvoid = const [],
    this.rawData = const {},
  });

  final String? summary;
  final String? career;
  final String? wealth;
  final String? love;
  final String? health;
  final String? advice;
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
  final double? fortuneScore;
  final List<String> auspiciousHours;
  final List<String> inauspiciousHours;
  final List<String> shouldDo;
  final List<String> shouldAvoid;
  final Map<String, dynamic> rawData;
}

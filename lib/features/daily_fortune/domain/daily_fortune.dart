class DailyFortune {
  const DailyFortune({
    required this.date,
    required this.summary,
    this.canChi,
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
  final List<String> auspiciousHours;
  final List<String> inauspiciousHours;
  final List<String> shouldDo;
  final List<String> shouldAvoid;
  final String? advice;
  final Map<String, dynamic> rawData;
}

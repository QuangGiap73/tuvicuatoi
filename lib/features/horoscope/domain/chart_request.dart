class ChartRequest {
  const ChartRequest({
    required this.name,
    required this.gender,
    required this.day,
    required this.month,
    required this.year,
    required this.hour,
    required this.calendarType,
  });

  final String name;
  final String gender;
  final int day;
  final int month;
  final int year;
  final int hour;
  final String calendarType;

  Map<String, Object> toJson() => {
    'name': name.trim(),
    'gender': gender,
    'day': day,
    'month': month,
    'year': year,
    'hour': hour,
    'calendarType': calendarType,
  };
}

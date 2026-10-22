class ChartFormState {
  const ChartFormState({
    this.fullName = '',
    this.day = 15,
    this.month = 8,
    this.year = 1995,
    this.hour = 7,
    this.gender = 'Nam',
    this.calendarType = 'solar',
    this.errorMessage,
  });

  final String fullName;
  final int day;
  final int month;
  final int year;
  final int hour;
  final String gender;
  final String calendarType;
  final String? errorMessage;

  ChartFormState copyWith({
    String? fullName,
    int? day,
    int? month,
    int? year,
    int? hour,
    String? gender,
    String? calendarType,
    String? errorMessage,
    bool clearError = false,
  }) => ChartFormState(
    fullName: fullName ?? this.fullName,
    day: day ?? this.day,
    month: month ?? this.month,
    year: year ?? this.year,
    hour: hour ?? this.hour,
    gender: gender ?? this.gender,
    calendarType: calendarType ?? this.calendarType,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  String? validate() {
    if (fullName.trim().isEmpty) return 'Vui lòng nhập họ và tên sinh chủ.';
    if (year < 1900 || year > DateTime.now().year) {
      return 'Năm sinh không hợp lệ.';
    }
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Ngày sinh không hợp lệ.';
      }
    } on ArgumentError {
      return 'Ngày sinh không hợp lệ.';
    }
    return null;
  }
}

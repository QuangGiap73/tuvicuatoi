import 'daily_calendar.dart';
import 'fortune_hour.dart';
import 'personal_fortune.dart';

/// Snapshot nguyên tử của một ngày. Nếu có lá số, lịch và vận cá nhân luôn
/// đến từ cùng response để không hiển thị lệch ngày hoặc lệch lá số.
class DailyFortune {
  const DailyFortune({
    required this.date,
    required this.calendar,
    this.personal,
    this.aiSuggestedPrompt,
    this.rawData = const {},
  });
  final DateTime date;
  final DailyCalendar calendar;
  final PersonalFortune? personal;
  final String? aiSuggestedPrompt;
  final Map<String, dynamic> rawData;

  bool get isPersonalized => personal != null;
  DailyFortune get calendarOnly => personal == null
      ? this
      : DailyFortune(date: date, calendar: calendar, rawData: rawData);
  String get summary => personal == null
      ? calendar.truc?.summary ?? ''
      : [
          personal!.branchRelationDescription,
          personal!.elementRelationDescription,
        ].where((value) => value.isNotEmpty).join('\n\n');
  String get canChi => [canChiDay, canChiMonth, canChiYear].join(' • ');
  String get canChiDay => calendar.canChiDay;
  String get canChiMonth => calendar.canChiMonth;
  String get canChiYear => calendar.canChiYear;
  String get canChiHour => calendar.canChiHour;
  String get lunarDate => calendar.lunarDateLabel;
  String get napAm => calendar.dayNayin;
  String get dayElement => calendar.dayElement;
  String? get dayOfficer => calendar.truc?.name;
  String? get dayRating => calendar.truc?.quality;
  String? get dayOfficerDescription => calendar.truc?.summary;
  String get solarTerm => calendar.solarTerm;
  String? get lunarMansion => calendar.lunarMansion?.name;
  String? get lunarMansionRating => calendar.lunarMansion?.nature;
  String? get lunarMansionDescription => calendar.lunarMansion?.description;
  String? get joyDirection => calendar.joyDirection;
  String? get wealthDirection => calendar.wealthDirection;
  String? get dailyPalace => personal?.palaceName;
  int get fortuneScore => personal?.overallScore ?? 0;
  String? get career => _text(personal?.careerAdvice);
  String? get wealth => _text(personal?.wealthAdvice);
  String? get love => _text(personal?.loveAdvice);
  String? get health => _text(personal?.healthAdvice);
  List<FortuneHour> get hours => personal?.personalizedHours.isNotEmpty == true
      ? personal!.personalizedHours
      : calendar.hours;
  List<String> get shouldDo => calendar.recommendedActivities;
  List<String> get shouldAvoid => calendar.restrictedActivities;
  String? get advice => _text(personal?.luckyColorReason);

  static String? _text(String? value) =>
      value == null || value.trim().isEmpty ? null : value.trim();
}

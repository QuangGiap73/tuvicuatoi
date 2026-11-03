import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/daily_fortune/domain/daily_calendar.dart';
import 'package:tuvicuatoi/features/daily_fortune/domain/daily_fortune.dart';
import 'package:tuvicuatoi/features/daily_fortune/domain/fortune_hour.dart';
import 'package:tuvicuatoi/features/daily_fortune/domain/personal_fortune.dart';
import 'package:tuvicuatoi/features/daily_fortune/presentation/widgets/fortune_hours_card.dart';
import 'package:tuvicuatoi/features/daily_fortune/presentation/widgets/fortune_overview_card.dart';
import 'package:tuvicuatoi/features/daily_fortune/presentation/widgets/personal_fortune_details_card.dart';

void main() {
  testWidgets('personal fortune cards fit a compact phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(288, 760));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final fortune = _fortune();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                FortuneOverviewCard(fortune: fortune, loading: false),
                PersonalFortuneDetailsCard(fortune: fortune.personal!),
                FortuneHoursCard(fortune: fortune),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('62'), findsOneWidget);
    expect(find.text('/100'), findsOneWidget);
    expect(find.textContaining('Quý nhân tuổi Hợi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

DailyFortune _fortune() {
  const hour = FortuneHour(
    branch: 'Dần',
    time: '03:00 - 04:59',
    isAuspicious: false,
    starName: 'Hắc Đạo',
    affinityType: 'Lục Hợp',
    affinityBadge: 'Quý nhân tuổi Hợi',
  );
  const personal = PersonalFortune(
    chartName: 'Nguyễn Văn A',
    birthYearCanChi: 'Ất Hợi',
    birthBranch: 'Hợi',
    destinyNayin: 'Sơn Đầu Hỏa',
    destinyElement: 'Hỏa',
    palaceName: 'Phụ Mẫu',
    palaceBranch: 'Ngọ',
    majorStars: ['Tử Vi'],
    dailyStars: ['Lưu Văn Khúc'],
    branchRelationType: 'Bình Hòa',
    branchRelationDescription: 'Vận trình ổn định.',
    elementRelationType: 'Khắc Nhập',
    elementRelationDescription: 'Nên thận trọng và giữ sức khỏe.',
    mutagenStars: {'loc': MutagenStar(star: 'Thiên Đồng', palace: 'Tài Bạch')},
    overallScore: 62,
    overallRating: 'Bình Hòa An Ổn',
    careerAdvice: 'Công việc thuận lợi.',
    wealthAdvice: 'Tài chính ổn định.',
    loveAdvice: 'Gia đình hòa thuận.',
    healthAdvice: 'Nên nghỉ ngơi.',
    luckyColor: 'Xanh lá',
    luckyColorReason: 'Bồi đắp sinh khí.',
    luckyDirection: 'Tây Nam',
    personalizedHours: [hour],
  );
  return DailyFortune(
    date: DateTime(2026, 10, 29),
    calendar: DailyCalendar(
      solarDate: DateTime(2026, 10, 29),
      dayOfWeek: 'Thứ Năm',
      lunarDay: 20,
      lunarMonth: 9,
      lunarYear: 2026,
      isLeapMonth: false,
      canChiDay: 'Bính Tý',
      canChiMonth: 'Mậu Tuất',
      canChiYear: 'Bính Ngọ',
      canChiHour: 'Mậu Tý',
      dayNayin: 'Giản Hạ Thủy',
      dayElement: 'Thủy',
      solarTerm: 'Sương Giáng',
      hours: const [hour],
      recommendedActivities: const ['Khai trương'],
      restrictedActivities: const ['Tranh chấp'],
    ),
    personal: personal,
  );
}

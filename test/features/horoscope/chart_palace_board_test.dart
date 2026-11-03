import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_result.dart';
import 'package:tuvicuatoi/features/horoscope/presentation/widgets/chart_palace_board.dart';

void main() {
  for (final width in [288.0, 390.0, 720.0]) {
    testWidgets('chart board fits ${width.toInt()}dp viewport', (tester) async {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ChartPalaceBoard(result: _chart),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('LÁ SỐ TỬ VI'), findsOneWidget);
      expect(find.text('MỆNH'), findsOneWidget);
      final lastPalace = tester.getRect(find.text('CUNG 12'));
      expect(lastPalace.left, greaterThanOrEqualTo(0));
      expect(lastPalace.right, lessThanOrEqualTo(width));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SingleChildScrollView &&
              widget.scrollDirection == Axis.horizontal,
        ),
        findsNothing,
      );
    });
  }

  testWidgets('palace preview opens before navigating to detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ChartPalace? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChartPalaceBoard(
            result: _chart,
            onPalaceTap: (palace) => selected = palace,
          ),
        ),
      ),
    );

    await tester.tap(find.text('MỆNH'));
    await tester.pumpAndSettle();
    expect(find.text('CUNG MỆNH'), findsOneWidget);
    expect(find.text('Xem luận giải chi tiết'), findsOneWidget);
    expect(selected, isNull);

    await tester.tap(find.text('Xem luận giải chi tiết'));
    await tester.pumpAndSettle();
    expect(selected?.name, 'MỆNH');
    expect(find.text('CUNG MỆNH'), findsNothing);
  });
}

final _chart = ChartResult.fromJson({
  'id': 'chart-1',
  'fullName': 'Nguyễn Văn An',
  'gender': 'Nam',
  'solarDate': '15/08/1995',
  'solarTime': '07:00',
  'hourBranch': 'Thìn',
  'lunarDate': '20/07/Ất Hợi',
  'lunarYearCanChi': 'Ất Hợi',
  'namXem': '2026 (Bính Ngọ)',
  'amDuongThuanLy': 'Âm Dương thuận lý',
  'menhCucBinhHoa': 'Bản mệnh sinh Cục',
  'thanCu': 'Quan Lộc',
  'menh': 'Sơn Đầu Hỏa',
  'cuc': 'Mộc Tam Cục',
  'amDuong': 'Dương Nam',
  'chuMenh': 'Liêm Trinh',
  'chuThan': 'Thiên Cơ',
  'palaces': {
    for (var index = 0; index < 12; index++)
      'p$index': {
        'id': 'p$index',
        'branch': 'Tý',
        'canChi': 'Giáp Tý',
        'name': index == 0 ? 'MỆNH' : 'CUNG ${index + 1}',
        'element': 'Hỏa',
        'isThan': index == 6,
        'mainStars': [
          {'name': 'Tử Vi', 'tag': '(M)'},
          {'name': 'Thiên Phủ', 'tag': '(V)'},
        ],
        'luckyStars': ['Thiên Khôi', 'Thiên Việt', 'Hóa Khoa', 'Long Trì'],
        'badStars': ['Kình Dương', 'Đà La', 'Hóa Kỵ', 'Thiên Hư'],
        'vongTrangSinh': 'Trường Sinh',
        'daiHanAge': index * 10 + 4,
      },
  },
});

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/home/presentation/widgets/home_daily_message_card.dart';

void main() {
  testWidgets('long daily message expands the frame without overflow', (
    tester,
  ) async {
    const message =
        'Một ngày thuận lợi để học hỏi điều mới. Hãy kiên nhẫn quan sát, '
        'giữ tâm bình an và dành thời gian cân nhắc trước những quyết định '
        'quan trọng trong ngày hôm nay.';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 320,
              child: HomeDailyMessageCard(message: message, year: 2026),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(message), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(HomeDailyMessageCard)).height,
      greaterThan(320 / 2.205),
    );
  });
}

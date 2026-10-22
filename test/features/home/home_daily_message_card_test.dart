import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/home/presentation/widgets/home_daily_message_card.dart';

void main() {
  const longMessage =
      'Một lựa chọn nhỏ hôm nay có thể mở ra hành trình lớn. Hãy tin vào trực giác và dành thời gian quan sát thật kỹ.';

  for (final width in [288.0, 320.0, 398.0]) {
    testWidgets('daily card fits ${width.toInt()}dp width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 800),
              textScaler: const TextScaler.linear(1.25),
            ),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: const HomeDailyMessageCard(
                    message: longMessage,
                    year: 2026,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Ngày cát lành  ·  2026'), findsOneWidget);
    });
  }
}

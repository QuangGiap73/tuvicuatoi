import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/presentation/widgets/chart_result_actions.dart';

void main() {
  for (final width in [288.0, 320.0, 390.0, 430.0]) {
    testWidgets('chart result actions fit ${width.toInt()}dp', (tester) async {
      var savePressed = false;
      var interpretPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: ChartResultActions(
                isSaved: false,
                isSaving: false,
                onSave: () => savePressed = true,
                onInterpret: () => interpretPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.tap(find.text('LƯU LÁ SỐ'));
      await tester.tap(find.text('LUẬN GIẢI'));
      expect(savePressed, isTrue);
      expect(interpretPressed, isTrue);
    });
  }
}

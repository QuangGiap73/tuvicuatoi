import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/widgets/interpretation_tab_bar.dart';

void main() {
  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('interpretation tabs fit ${width.toInt()}dp', (tester) async {
      InterpretationTab? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(width, 800)),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width - 28,
                  child: InterpretationTabBar(
                    selectedTab: InterpretationTab.overview,
                    onChanged: (value) => selected = value,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.tap(find.text('12 cung'));
      expect(selected, InterpretationTab.palaces);
    });
  }
}

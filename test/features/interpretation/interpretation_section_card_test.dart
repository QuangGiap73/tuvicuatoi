import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/widgets/interpretation_section_card.dart';

void main() {
  const section = ReadingSection(
    id: 'wealth',
    groupSlug: 'ung_dung',
    groupTitle: 'Ứng dụng',
    sectionSlug: 'tai_loc',
    title: 'Tài lộc',
    subtitle: 'Tiềm năng tài chính, phương thức kiếm tiền và tích lũy.',
    summary: '',
    iconName: 'wealth',
    coinCost: 100,
    order: 1,
  );

  testWidgets('section card fits mobile and emits unlock action', (
    tester,
  ) async {
    var pressed = false;
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 292,
              child: InterpretationSectionCard(
                section: section,
                isUnlocked: false,
                unlockStatus: UnlockStatus.idle,
                onOpen: () => opened = true,
                onUnlock: () => pressed = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Mở khóa 100 Xu'), findsOneWidget);
    await tester.tap(find.text('Tài lộc'));
    expect(opened, isTrue);
    await tester.tap(find.text('Mở khóa 100 Xu'));
    expect(pressed, isTrue);
  });

  testWidgets('section card disables action while loading', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: InterpretationSectionCard(
          section: section,
          isUnlocked: false,
          unlockStatus: UnlockStatus.submitting,
          onOpen: () {},
          onUnlock: () => pressed = true,
        ),
      ),
    );

    await tester.tap(find.text('Đang mở...'));
    expect(pressed, isFalse);
  });

  testWidgets('section card prevents a second payment while syncing', (
    tester,
  ) async {
    var pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: InterpretationSectionCard(
          section: section,
          isUnlocked: false,
          unlockStatus: UnlockStatus.syncing,
          onOpen: () {},
          onUnlock: () => pressed = true,
        ),
      ),
    );

    expect(find.text('Đang đồng bộ quyền'), findsOneWidget);
    await tester.tap(find.text('Đang đồng bộ quyền'));
    expect(pressed, isFalse);
  });
}

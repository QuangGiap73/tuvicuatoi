import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/home/presentation/widgets/home_menu_sheet.dart';

void main() {
  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('home menu fits ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeMenuSheet(
              isAuthenticated: true,
              userName: 'Nguyễn Văn A với tên tài khoản rất dài',
              coinBalance: 123456789,
              onLogin: () {},
              onProfile: () {},
              onHoroscope: () {},
              onSavedCharts: () {},
              onInterpretation: () {},
              onDailyFortune: () {},
              onArticles: () {},
              onWallet: () {},
              onPremium: () {},
              onSettings: () {},
              onSupport: () {},
              onPolicy: () {},
              onLogout: () {},
            ),
          ),
        ),
      );

      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Lập lá số'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('guest menu presents login entry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeMenuSheet(
            isAuthenticated: false,
            userName: '',
            coinBalance: 0,
            onLogin: () {},
            onProfile: () {},
            onHoroscope: () {},
            onSavedCharts: () {},
            onInterpretation: () {},
            onDailyFortune: () {},
            onArticles: () {},
            onWallet: () {},
            onPremium: () {},
            onSettings: () {},
            onSupport: () {},
            onPolicy: () {},
            onLogout: () {},
          ),
        ),
      ),
    );

    expect(find.text('Khách hữu duyên'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Đăng xuất'), findsNothing);
  });
}

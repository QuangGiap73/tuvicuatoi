import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:tuvicuatoi/app/app.dart';
import 'package:tuvicuatoi/core/storage/token_storage.dart';

class _MemoryTokenStorage implements TokenStorage {
  String? token;
  @override
  Future<void> clear() async => token = null;
  @override
  Future<String?> read() async => token;
  @override
  Future<void> write(String token) async => this.token = token;
}

Widget _testApp() => ProviderScope(
  overrides: [tokenStorageProvider.overrideWithValue(_MemoryTokenStorage())],
  child: const TuViCuaToiApp(),
);

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var index = 0; index < 5; index++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('unauthenticated users see the welcome actions', (tester) async {
    await tester.pumpWidget(_testApp());
    await _pumpFrames(tester);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Đăng ký nhanh'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
    expect(find.text('Chat AI'), findsNothing);
  });

  testWidgets('can navigate from login to registration', (tester) async {
    await tester.pumpWidget(_testApp());
    await _pumpFrames(tester);
    await tester.tap(find.text('Đăng ký nhanh'));
    await _pumpFrames(tester);
    expect(find.text('Đăng Ký Nhanh'), findsWidgets);
    expect(find.text('XÁC NHẬN MẬT KHẨU'), findsOneWidget);
  });

  testWidgets('login form validates required fields', (tester) async {
    await tester.pumpWidget(_testApp());
    await _pumpFrames(tester);
    await tester.tap(find.text('Đăng nhập'));
    await _pumpFrames(tester);
    await tester.tap(find.text('ĐĂNG NHẬP NGAY'));
    await tester.pump();
    expect(find.text('Vui lòng nhập thông tin này'), findsNWidgets(2));
  });

  testWidgets('password strength only appears after typing', (tester) async {
    await tester.pumpWidget(_testApp());
    await _pumpFrames(tester);
    await tester.tap(find.text('Đăng ký nhanh'));
    await _pumpFrames(tester);

    expect(find.text('Độ mạnh mật khẩu:'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tối thiểu 8 ký tự'),
      'Abc123!@',
    );
    await tester.pump();
    expect(find.text('Độ mạnh mật khẩu:'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tối thiểu 8 ký tự'),
      '',
    );
    await tester.pump();
    expect(find.text('Độ mạnh mật khẩu:'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/auth/domain/auth_user.dart';
import 'package:tuvicuatoi/features/profile/presentation/account_settings_page.dart';
import 'package:tuvicuatoi/features/profile/presentation/providers/profile_providers.dart';

void main() {
  const passwordUser = AuthUser(
    id: 'user-id',
    email: 'member@example.com',
    fullName: 'Thành viên',
    coinBalance: 100,
    isPremium: false,
    role: 'member',
    authProvider: 'credentials',
    hasPassword: true,
  );

  testWidgets('settings exposes password and account deletion sections', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentProfileProvider.overrideWithValue(passwordUser)],
        child: const MaterialApp(home: AccountSettingsPage()),
      ),
    );

    expect(find.text('Thay đổi mật khẩu'), findsOneWidget);
    expect(find.text('Quên mật khẩu'), findsOneWidget);
    expect(find.text('Xóa tài khoản'), findsOneWidget);

    await tester.tap(find.text('Thay đổi mật khẩu'));
    await tester.pumpAndSettle();
    expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
    expect(find.text('Mật khẩu mới'), findsOneWidget);
    expect(find.text('Nhập lại mật khẩu mới'), findsOneWidget);
  });

  testWidgets('delete account explains missing backend support', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentProfileProvider.overrideWithValue(passwordUser)],
        child: const MaterialApp(home: AccountSettingsPage()),
      ),
    );

    await tester.tap(find.text('Xóa tài khoản'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa thể xóa tài khoản'), findsOneWidget);
    expect(find.textContaining('Backend chưa cung cấp API'), findsOneWidget);
  });
}

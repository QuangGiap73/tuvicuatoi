import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/core/widgets/mystic_notification_dialog.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('notification dialog fits ${width.toInt()}dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(width, 760)),
            child: Scaffold(
              body: MysticNotificationDialog(
                header: 'Mở khóa luận giải',
                title: 'Luận giải cung Quan Lộc',
                description: 'Đọc toàn bộ phân tích chi tiết dành cho lá số.',
                priceText: '100 Xu',
                items: const [
                  MysticNotificationItem('Nội dung thuộc bản tinh gọn'),
                  MysticNotificationItem('Có thể đọc lại bất kỳ lúc nào'),
                ],
                confirmLabel: 'Xác nhận mở khóa',
                onConfirm: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Xác nhận mở khóa'), findsOneWidget);
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/wallet/domain/wallet_models.dart';
import 'package:tuvicuatoi/features/wallet/presentation/widgets/payment_checkout_dialog.dart';

void main() {
  testWidgets('payment checkout fits compact phones and marks maintenance', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showPaymentCheckoutDialog(
                context: context,
                productName: 'Gói PREMIUM VIP',
                amount: 99000,
                featureKey: 'PREMIUM_PACKAGE',
                onValidateVoucher:
                    ({
                      required code,
                      required featureKey,
                      required originalCost,
                    }) async => const VoucherValidationResult(
                      id: 'voucher-1',
                      code: 'TUVI2026',
                      name: 'Ưu đãi',
                      discountType: 'PERCENT',
                      discountValue: 20,
                      discountAmount: 19800,
                      finalCost: 79200,
                      message: 'Áp dụng thành công',
                    ),
              ),
              child: const Text('Mở'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mở'));
    await tester.pumpAndSettle();

    expect(find.text('PAYOS / VIETQR'), findsOneWidget);
    expect(find.text('VÍ MOMO'), findsOneWidget);
    expect(find.text('VISA/MC'), findsOneWidget);
    expect(find.text('BẢO TRÌ'), findsNWidgets(2));
    await tester.enterText(find.byType(TextField), 'TUVI2026');
    await tester.tap(find.text('ÁP DỤNG'));
    await tester.pumpAndSettle();
    expect(find.text('Áp dụng thành công'), findsOneWidget);
    expect(find.text('79.200đ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

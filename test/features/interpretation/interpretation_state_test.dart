import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/state/interpretation_state.dart';

void main() {
  test('request errors are isolated by data source', () {
    const initial = InterpretationState(
      catalogError: 'catalog failed',
      permissionError: 'permission failed',
    );

    final contentLoading = initial.copyWith(
      clearContentError: true,
      isLoadingInterpretation: true,
    );

    expect(contentLoading.catalogError, 'catalog failed');
    expect(contentLoading.permissionError, 'permission failed');
    expect(contentLoading.contentError, isNull);
  });

  test('unlock activity is derived from each canonical section key', () {
    const key = 'chart-id:tong_quan_ban_menh:ban_menh_va_than:chuyen-sau';
    const syncing = InterpretationState(
      unlockStatusBySection: {key: UnlockStatus.syncing},
    );
    const failed = InterpretationState(
      unlockStatusBySection: {key: UnlockStatus.failed},
    );

    expect(syncing.isUnlocking, isTrue);
    expect(failed.isUnlocking, isFalse);
  });
}

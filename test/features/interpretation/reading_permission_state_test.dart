import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/state/reading_permission_state.dart';

void main() {
  const chartId = 'chart-id';
  const section = ReadingSection(
    id: 'section',
    groupSlug: 'tong_quan_ban_menh',
    groupTitle: 'Tổng quan',
    sectionSlug: 'ban_menh_va_than',
    title: 'Bản mệnh',
    subtitle: '',
    summary: '',
    iconName: '',
    coinCost: 100,
    order: 1,
  );
  const key = ReadingSectionKey(
    chartId: chartId,
    mode: InterpretationMode.deep,
    groupSlug: 'tong_quan_ban_menh',
    sectionSlug: 'ban_menh_va_than',
  );

  test('derives access and transaction status from the permission slice', () {
    final unlocked = ReadingPermissionState(
      chartId: chartId,
      unlockedKeys: {key},
    );
    final syncing = ReadingPermissionState(
      chartId: chartId,
      statusBySection: {key.value: UnlockStatus.syncing},
    );

    expect(unlocked.isUnlocked(section), isTrue);
    expect(unlocked.statusFor(section), UnlockStatus.unlocked);
    expect(unlocked.canPurchase(section), isFalse);
    expect(syncing.isUnlocked(section), isFalse);
    expect(syncing.statusFor(section), UnlockStatus.syncing);
    expect(syncing.canPurchase(section), isFalse);
    expect(syncing.hasPendingTransaction, isTrue);
  });

  test('uses value equality so unrelated parent updates do not notify UI', () {
    final left = ReadingPermissionState(
      chartId: chartId,
      unlockedKeys: {key},
      statusBySection: {key.value: UnlockStatus.unlocked},
    );
    final right = ReadingPermissionState(
      chartId: chartId,
      unlockedKeys: {key},
      statusBySection: {key.value: UnlockStatus.unlocked},
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';

void main() {
  const chartId = '63ee0f8d-c0d7-455f-a2bc-bc7b009fe469';
  const otherChartId = '935b744f-67c7-4a8f-96a1-edf7117834e6';

  test('accepts only an exact canonical key for the requested chart', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      '$chartId:tong_quan_ban_menh:ban_menh_va_than:chuyen-sau',
    ], expectedChartId: chartId);

    expect(
      snapshot.canonicalKeys,
      contains(
        const ReadingSectionKey(
          chartId: chartId,
          mode: InterpretationMode.deep,
          groupSlug: 'tong_quan_ban_menh',
          sectionSlug: 'ban_menh_va_than',
        ),
      ),
    );
    expect(snapshot.legacyKeys, isEmpty);
  });

  test('keeps modes isolated', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      '$chartId:tong_quan_ban_menh:ban_menh_va_than:doi-thuong',
    ], expectedChartId: chartId);

    expect(
      snapshot.canonicalKeys,
      contains(
        const ReadingSectionKey(
          chartId: chartId,
          mode: InterpretationMode.everyday,
          groupSlug: 'tong_quan_ban_menh',
          sectionSlug: 'ban_menh_va_than',
        ),
      ),
    );
    expect(
      snapshot.canonicalKeys,
      isNot(
        contains(
          const ReadingSectionKey(
            chartId: chartId,
            mode: InterpretationMode.deep,
            groupSlug: 'tong_quan_ban_menh',
            sectionSlug: 'ban_menh_va_than',
          ),
        ),
      ),
    );
  });

  test('does not grant access from another chart UUID', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      '$otherChartId:tong_quan_ban_menh:ban_menh_va_than:chuyen-sau',
    ], expectedChartId: chartId);

    expect(snapshot.canonicalKeys, isEmpty);
    expect(snapshot.legacyKeys.single.kind, LegacyUnlockKeyKind.foreignChart);
  });

  test('decodes fingerprint keys but keeps them diagnostic-only', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      'fp%3Agi%C3%A1p%3A15%2F01%2F2004%3A07%3A00%3Anam:'
          'tong_quan_ban_menh:ban_menh_va_than:chuyen-sau',
    ], expectedChartId: chartId);

    expect(snapshot.canonicalKeys, isEmpty);
    expect(snapshot.legacyKeys.single.kind, LegacyUnlockKeyKind.fingerprint);
    expect(snapshot.legacyKeys.single.decoded, startsWith('fp:giáp:'));
  });

  test('does not grant access to keys without a mode', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      '$chartId:tong_quan_ban_menh:ban_menh_va_than',
    ], expectedChartId: chartId);

    expect(snapshot.canonicalKeys, isEmpty);
    expect(snapshot.legacyKeys.single.kind, LegacyUnlockKeyKind.missingMode);
  });

  test('does not grant access from an engine chart id', () {
    final snapshot = ReadingUnlockSnapshot.fromRaw(const [
      'chart-1792380087740:tong_quan_ban_menh:'
          'ban_menh_va_than:chuyen-sau',
    ], expectedChartId: chartId);

    expect(snapshot.canonicalKeys, isEmpty);
    expect(snapshot.legacyKeys.single.kind, LegacyUnlockKeyKind.engineChartId);
  });
}

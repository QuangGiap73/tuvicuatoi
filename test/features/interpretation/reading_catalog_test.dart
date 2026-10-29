import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_section_content_resolver.dart';

void main() {
  test('parses canonical catalog pricing, groups and server permission', () {
    final catalog = ReadingCatalog.fromJson({
      'success': true,
      'allUnlocked': false,
      'pricing': {
        'unitCost': 100,
        'totalSections': 35,
        'remainingLockedCount': 33,
        'remainingBundleCost': 2357,
        'buyOneGetBothModes': true,
      },
      'groups': [
        {
          'groupSlug': 'tong_quan_ban_menh',
          'groupTitle': 'Tổng Quan Bản Mệnh',
          'totalSections': 15,
          'lockedCount': 14,
          'tabBundleCost': 1260,
          'sections': [
            {
              'id': 'section-1',
              'sectionSlug': 'ban_menh_va_tinh_cach_cot_loi',
              'topicCode': 'CD01',
              'aliases': ['ban_menh_va_than'],
              'title': 'Bản Mệnh & Tính Cách Cốt Lõi',
              'coinCost': 100,
              'isUnlocked': true,
              'order': 1,
            },
          ],
        },
      ],
    });

    expect(catalog.sections, hasLength(1));
    expect(catalog.sections.single.hasUnlockState, isTrue);
    expect(catalog.sections.single.isUnlocked, isTrue);
    expect(catalog.sections.single.topicCode, 'CD01');
    expect(catalog.groups.single.tabBundleCost, 1260);
    expect(catalog.pricing.totalSections, 35);
    expect(catalog.pricing.remainingBundleCost, 2357);
    expect(catalog.pricing.buyOneGetBothModes, isTrue);
  });

  test('resolves canonical engine content by topic code and palace name', () {
    const resolver = InterpretationSectionContentResolver();
    final interpretation = InterpretationData.fromJson({
      'overviewTopics': [
        {
          'id': 'CD01_TINH_CACH_BAN_THAN',
          'title': 'Tính cách',
          'items': [
            {'title': 'Mệnh', 'content': 'Nội dung CD01 cá nhân.'},
          ],
        },
      ],
      'palaceReadings': [
        {
          'palaceName': 'Tử Tức',
          'items': [
            {'title': 'Sao', 'content': 'Nội dung cung Tử Tức cá nhân.'},
          ],
        },
      ],
    });
    const overview = ReadingSection(
      id: 'overview',
      groupSlug: 'tong_quan_ban_menh',
      groupTitle: 'Tổng quan',
      sectionSlug: 'ban_menh_va_tinh_cach_cot_loi',
      topicCode: 'CD01',
      title: 'Bản mệnh',
      subtitle: '',
      summary: '',
      iconName: '',
      coinCost: 100,
      order: 1,
    );
    const palace = ReadingSection(
      id: 'palace',
      groupSlug: 'chi_tiet_12_cung',
      groupTitle: '12 cung',
      sectionSlug: 'cung_tu_tuc',
      title: 'Cung Tử Tức',
      subtitle: '',
      summary: '',
      iconName: '',
      coinCost: 100,
      order: 10,
    );

    expect(
      resolver
          .resolve(
            section: overview,
            interpretation: interpretation,
            chartData: const {},
          )
          .fullContent,
      contains('Nội dung CD01 cá nhân'),
    );
    expect(
      resolver
          .resolve(
            section: palace,
            interpretation: interpretation,
            chartData: const {},
          )
          .fullContent,
      contains('Nội dung cung Tử Tức cá nhân'),
    );
  });
}

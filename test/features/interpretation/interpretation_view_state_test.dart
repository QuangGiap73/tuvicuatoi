import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/state/interpretation_catalog_state.dart';
import 'package:tuvicuatoi/features/interpretation/presentation/state/interpretation_content_state.dart';

void main() {
  const overviewSection = ReadingSection(
    id: 'overview',
    groupSlug: 'tong_quan_ban_menh',
    groupTitle: 'Tong quan',
    sectionSlug: 'ban_menh',
    title: 'Ban menh',
    subtitle: '',
    summary: '',
    iconName: '',
    coinCost: 100,
    order: 1,
  );
  const palaceSection = ReadingSection(
    id: 'palace',
    groupSlug: 'chi_tiet_12_cung',
    groupTitle: '12 cung',
    sectionSlug: 'cung_menh',
    title: 'Cung Menh',
    subtitle: '',
    summary: '',
    iconName: '',
    coinCost: 100,
    order: 1,
  );

  test('catalog snapshot filters sections without permission state', () {
    final sections = [overviewSection, palaceSection];
    final state = InterpretationCatalogState(
      sections: sections,
      selectedTab: InterpretationTab.palaces,
    );

    expect(state.selectedSections, [palaceSection]);
    expect(
      InterpretationCatalogState.tabForSection(palaceSection),
      InterpretationTab.palaces,
    );
  });

  test('catalog snapshot uses identity equality for immutable payloads', () {
    final sections = [overviewSection];
    final left = InterpretationCatalogState(sections: sections);
    final right = InterpretationCatalogState(sections: sections);
    final replaced = InterpretationCatalogState(sections: [overviewSection]);

    expect(left, right);
    expect(left, isNot(replaced));
  });

  test('content snapshot ignores catalog and permission changes by design', () {
    const interpretation = InterpretationData(personalityCore: 'content');
    const left = InterpretationContentState(
      mode: InterpretationMode.deep,
      interpretation: interpretation,
    );
    const right = InterpretationContentState(
      mode: InterpretationMode.deep,
      interpretation: interpretation,
    );

    expect(left, right);
    expect(left.hashCode, right.hashCode);
  });
}

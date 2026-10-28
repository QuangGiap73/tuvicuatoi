import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/generated_overview_section_mapper.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';

void main() {
  test('maps engine IDs without inventing a coin price', () {
    const source = StructuredReadingSection(
      id: 'CD06_DUONG_CON_CAI',
      title: 'Con cái',
      items: [ReadingContentItem(title: 'Tử Tức', content: 'Nội dung cá nhân')],
    );

    final section = GeneratedOverviewSectionMapper.toSection(source);

    expect(section?.sectionSlug, 'con_cai');
    expect(section?.coinCost, 0);
    expect(section?.title, 'Con cái');
  });

  test('ignores unknown engine IDs', () {
    const source = StructuredReadingSection(id: 'UNKNOWN', title: 'Không rõ');

    expect(GeneratedOverviewSectionMapper.toSection(source), isNull);
  });

  test('supports every topic id documented by the engine', () {
    const ids = [
      'CD01_TINH_CACH_BAN_THAN',
      'CD02_CONG_DANH',
      'CD03_TINH_DUYEN_HON_NHAN_GIA_DINH',
      'CD04_TAI_SAN_DIEN_SAN',
      'CD05_SUC_KHOE_THE_CHAT_TINH_THAN',
      'CD06_DUONG_CON_CAI',
      'CD07_DONG_HO',
      'CD08_CAP_DUOI_DONG_NGHIEP',
      'CD09_HUYNH_DE_BANG_HUU_HOP_TAC',
      'CD10_PHU_MAU_GIA_DINH_SU_NGHIEP',
      'CD11_MOI_TRUONG_SINH_SONG_LAM_VIEC',
      'CD12_TAI_HOA_HOAN_NAN',
      'CD13_THOI_DIEM_QUAN_TRONG',
      'CD14_CACH_CUC',
      'CD15_THI_CU',
    ];

    for (final id in ids) {
      final section = GeneratedOverviewSectionMapper.toSection(
        StructuredReadingSection(id: id, title: id),
      );
      expect(section, isNotNull, reason: id);
    }
  });
}

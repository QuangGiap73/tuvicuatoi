import 'interpretation_models.dart';

/// Converts the stable engine topic IDs into UI identities only.
/// Prices and access are intentionally never invented here.
abstract final class GeneratedOverviewSectionMapper {
  static const _slugByTopicId = <String, String>{
    'CD01_TINH_CACH_BAN_THAN': 'ban_menh_va_than',
    'CD02_CONG_DANH': 'su_nghiep_cong_danh',
    'CD03_TINH_DUYEN_HON_NHAN_GIA_DINH': 'hon_nhan_tinh_cam',
    'CD04_TAI_SAN_DIEN_SAN': 'tai_loc',
    'CD05_SUC_KHOE_THE_CHAT_TINH_THAN': 'suc_khoe',
    'CD06_DUONG_CON_CAI': 'con_cai',
    'CD07_DONG_HO': 'phuc_duc_dong_toc',
    'CD08_CAP_DUOI_DONG_NGHIEP': 'no_boc_cong_su',
    'CD09_HUYNH_DE_BANG_HUU_HOP_TAC': 'huynh_de_bang_huu',
    'CD10_PHU_MAU_GIA_DINH_SU_NGHIEP': 'phu_mau_gia_dinh',
    'CD11_MOI_TRUONG_SINH_SONG_LAM_VIEC': 'thien_di_moi_truong',
    'CD12_TAI_HOA_HOAN_NAN': 'hoa_giai_tai_hoa',
    'CD13_THOI_DIEM_QUAN_TRONG': 'buoc_ngoat_cuoc_doi',
    'CD14_CACH_CUC': 'dai_cuc_la_so',
    'CD15_THI_CU': 'khoa_bang_hoc_van',
  };

  static ReadingSection? toSection(StructuredReadingSection source) {
    final slug = _slugByTopicId[source.id.trim().toUpperCase()];
    if (slug == null || source.title.trim().isEmpty) return null;
    final preview = source.summary.trim().isNotEmpty
        ? source.summary.trim()
        : source.items.isNotEmpty
        ? source.items.first.title.trim()
        : '';
    return ReadingSection(
      id: 'engine:${source.id}',
      groupSlug: 'tong_quan_ban_menh',
      groupTitle: 'Tổng Quan Bản Mệnh',
      sectionSlug: slug,
      title: source.title.trim(),
      subtitle: preview,
      summary: preview,
      iconName: 'BookOpen',
      coinCost: 0,
      order: 100,
    );
  }
}

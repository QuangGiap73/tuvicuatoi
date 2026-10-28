import 'interpretation_models.dart';

/// Maps only topic values confirmed against POST /api/luan/chuyen-de.
/// A missing mapping deliberately falls back to the chart interpretation API.
abstract final class InterpretationTopicMapper {
  static const _topicBySectionSlug = <String, String>{
    'ban_menh_va_than': 'tính cách',
    'cung_phu_mau': 'phụ mẫu',
    'cung_phu_the': 'hôn nhân',
    'cung_quan_loc': 'công danh',
    'cung_tat_ach': 'sức khỏe',
    'con_cai': 'con cái',
    'no_boc_cong_su': 'đồng nghiệp',
    'huynh_de_bang_huu': 'huynh đệ',
    'thien_di_moi_truong': 'môi trường',
    'loi_khuyen_nghe_nghiep': 'công danh',
    'tuong_hop_nhan_duyen': 'hôn nhân',
  };

  static String? topicFor(ReadingSection section) =>
      _topicBySectionSlug[section.sectionSlug];
}

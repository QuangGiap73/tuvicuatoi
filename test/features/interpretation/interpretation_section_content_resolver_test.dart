import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_section_content_resolver.dart';
import 'package:tuvicuatoi/features/interpretation/domain/section_content.dart';

void main() {
  const resolver = InterpretationSectionContentResolver();

  ReadingSection section(
    String slug, {
    String title = 'Tiêu đề không dùng để ánh xạ',
    String summary = 'Tóm tắt catalog',
    String subtitle = 'Phụ đề catalog',
  }) => ReadingSection(
    id: slug,
    groupSlug: 'group',
    groupTitle: 'Group',
    sectionSlug: slug,
    title: title,
    subtitle: subtitle,
    summary: summary,
    iconName: '',
    coinCost: 100,
    order: 1,
  );

  test('maps overview sections by exact sectionSlug', () {
    final interpretation = const InterpretationData(
      personalityCore: 'Nội dung bản mệnh',
      aiShortSummary: 'Tổng quan nhân sinh',
    ).withSource(ContentSource.savedInterpretation);
    final chart = <String, dynamic>{
      'generalReading': {'menhReading': 'Fallback mệnh'},
      'aiSummary': 'Fallback tổng quan',
    };

    final destiny = resolver.resolve(
      section: section('ban_menh_va_than'),
      interpretation: interpretation,
      chartData: chart,
    );
    final overview = resolver.resolve(
      section: section('tong_quan_nhan_sinh'),
      interpretation: interpretation,
      chartData: chart,
    );

    expect(destiny.fullContent, 'Nội dung bản mệnh');
    expect(destiny.source, ContentSource.savedInterpretation);
    expect(overview.fullContent, 'Tổng quan nhân sinh');
  });

  test('builds only structured basic yin-yang data from chart fields', () {
    final content = resolver.resolve(
      section: section('am_duong_ngu_hanh'),
      interpretation: const InterpretationData(),
      chartData: const {
        'amDuong': 'Âm Nam',
        'menh': 'Sơn Đầu Hỏa',
        'cuc': 'Kim Tứ Cục',
        'chuMenh': 'Vũ Khúc',
      },
    );

    expect(content.fullContent, contains('Âm dương: Âm Nam'));
    expect(content.fullContent, contains('Mệnh: Sơn Đầu Hỏa'));
    expect(content.source, ContentSource.chartGeneralReading);
    expect(content.isFallback, isTrue);
  });

  test('uses palace interpretation only when palace and main star match', () {
    final interpretation = const InterpretationData(
      palaces: [
        PalaceInterpretation(
          palace: 'Cung Quan Lộc',
          star: 'Thái Âm Miếu Địa',
          summary: 'Nội dung cung từ interpretation',
        ),
      ],
      fieldSources: {'palaces': ContentSource.savedInterpretation},
    );
    final chart = <String, dynamic>{
      'palaces': {
        'dan': {
          'name': 'QUAN LỘC',
          'summary': 'Summary đúng của chart',
          'mainStars': [
            {'name': 'Thái Âm'},
          ],
        },
      },
    };

    final content = resolver.resolve(
      section: section('cung_quan_loc'),
      interpretation: interpretation,
      chartData: chart,
    );

    expect(content.fullContent, 'Nội dung cung từ interpretation');
    expect(content.source, ContentSource.savedInterpretation);
    expect(content.isFallback, isFalse);
  });

  test('rejects mismatched palace stars and falls back to chart palace', () {
    final content = resolver.resolve(
      section: section('cung_quan_loc'),
      interpretation: const InterpretationData(
        palaces: [
          PalaceInterpretation(
            palace: 'QUAN LỘC',
            star: 'Phá Quân',
            summary: 'Không được dùng',
          ),
        ],
      ),
      chartData: const {
        'palaces': {
          'dan': {
            'name': 'QUAN LỘC',
            'summary': 'Summary từ chart',
            'mainStars': [
              {'name': 'Thái Âm'},
            ],
          },
        },
      },
    );

    expect(content.fullContent, 'Summary từ chart');
    expect(content.source, ContentSource.chartPalace);
  });

  test('uses main star descriptions after missing chart palace summary', () {
    final content = resolver.resolve(
      section: section('cung_menh'),
      interpretation: const InterpretationData(),
      chartData: const {
        'palaces': {
          'thin': {
            'name': 'MỆNH',
            'mainStars': [
              {'name': 'Tử Vi', 'description': 'Mô tả sao Tử Vi'},
              {'name': 'Thiên Phủ', 'description': 'Mô tả sao Thiên Phủ'},
            ],
          },
        },
      },
    );

    expect(content.fullContent, contains('Mô tả sao Tử Vi'));
    expect(content.fullContent, contains('Mô tả sao Thiên Phủ'));
  });

  test('maps all twelve palace slugs to exact palace names', () {
    const mappings = <String, String>{
      'cung_menh': 'MỆNH',
      'cung_phu_mau': 'PHỤ MẪU',
      'cung_phu_the': 'PHU THÊ',
      'cung_quan_loc': 'QUAN LỘC',
      'cung_tai_bach': 'TÀI BẠCH',
      'cung_tat_ach': 'TẬT ÁCH',
      'cung_dien_trach': 'ĐIỀN TRẠCH',
      'cung_tu_tuc': 'TỬ TỨC',
      'cung_phuc_duc': 'PHÚC ĐỨC',
      'cung_no_boc': 'NÔ BỘC',
      'cung_thien_di': 'THIÊN DI',
      'cung_huynh_de': 'HUYNH ĐỆ',
    };
    for (final entry in mappings.entries) {
      final content = resolver.resolve(
        section: section(entry.key),
        interpretation: const InterpretationData(),
        chartData: {
          'palaces': {
            'palace': {
              'name': entry.value,
              'summary': 'Nội dung ${entry.value}',
            },
          },
        },
      );
      expect(content.fullContent, 'Nội dung ${entry.value}', reason: entry.key);
      expect(content.source, ContentSource.chartPalace);
    }
  });

  test('uses documented generalReading fallbacks only', () {
    const chart = {
      'generalReading': {
        'menhReading': 'Mệnh fallback',
        'currentYearFortune': 'Năm nay fallback',
        'careerReading': 'Nghề fallback',
        'loveReading': 'Tình duyên fallback',
      },
    };
    const expected = <String, String>{
      'ban_menh_va_than': 'Mệnh fallback',
      'tieu_han_nam_nay': 'Năm nay fallback',
      'loi_khuyen_nghe_nghiep': 'Nghề fallback',
      'tuong_hop_nhan_duyen': 'Tình duyên fallback',
    };
    for (final entry in expected.entries) {
      final content = resolver.resolve(
        section: section(entry.key),
        interpretation: const InterpretationData(),
        chartData: chart,
      );
      expect(content.fullContent, entry.value, reason: entry.key);
      expect(content.source, ContentSource.chartGeneralReading);
    }
  });

  test('maps fortune and application sections without title matching', () {
    final interpretation = const InterpretationData(
      decennialFortune: 'Đại vận',
      yearlyFortune: 'Tiểu hạn',
      fengshuiAdvice: 'Phong thủy',
      careerFame: 'Nghề nghiệp',
      marriageFamily: 'Nhân duyên',
    ).withSource(ContentSource.generatedInterpretation);

    final expected = <String, String>{
      'dai_van_10_nam': 'Đại vận',
      'tieu_han_nam_nay': 'Tiểu hạn',
      'phong_thuy_ung_dung': 'Phong thủy',
      'loi_khuyen_nghe_nghiep': 'Nghề nghiệp',
      'tuong_hop_nhan_duyen': 'Nhân duyên',
    };
    for (final entry in expected.entries) {
      final content = resolver.resolve(
        section: section(entry.key, title: 'Không liên quan'),
        interpretation: interpretation,
        chartData: const {},
      );
      expect(content.fullContent, entry.value, reason: entry.key);
      expect(content.source, ContentSource.generatedInterpretation);
    }
  });

  test('does not invent a five-year forecast', () {
    final content = resolver.resolve(
      section: section(
        'luu_nien_5_nam',
        summary: '',
        subtitle: 'Backend chưa cung cấp dự báo năm năm',
      ),
      interpretation: const InterpretationData(
        yearlyFortune: 'Không được dùng cho năm năm',
      ),
      chartData: const {},
    );

    expect(content.fullContent, 'Backend chưa cung cấp dự báo năm năm');
    expect(content.source, ContentSource.catalogSummary);
    expect(content.isFallback, isTrue);
  });
}

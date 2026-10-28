import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_models.dart';
import 'package:tuvicuatoi/features/interpretation/domain/interpretation_topic_mapper.dart';

void main() {
  ReadingSection section(String slug) => ReadingSection(
    id: slug,
    groupSlug: 'tong_quan_ban_menh',
    groupTitle: 'Tổng Quan Bản Mệnh',
    sectionSlug: slug,
    title: slug,
    subtitle: '',
    summary: '',
    iconName: 'User',
    coinCost: 100,
    order: 1,
  );

  test('maps only backend-confirmed topic values', () {
    expect(
      InterpretationTopicMapper.topicFor(section('ban_menh_va_than')),
      'tính cách',
    );
    expect(InterpretationTopicMapper.topicFor(section('con_cai')), 'con cái');
    expect(
      InterpretationTopicMapper.topicFor(section('tuong_hop_nhan_duyen')),
      'hôn nhân',
    );
  });

  test('does not invent a topic for unsupported overview sections', () {
    expect(
      InterpretationTopicMapper.topicFor(section('am_duong_ngu_hanh')),
      isNull,
    );
    expect(
      InterpretationTopicMapper.topicFor(section('tong_quan_nhan_sinh')),
      isNull,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/horoscope/domain/chart_result.dart';
import 'package:tuvicuatoi/features/palace_detail/domain/palace_detail_models.dart';
import 'package:tuvicuatoi/features/palace_detail/presentation/widgets/palace_detail_sections.dart';

void main() {
  const star = ChartStar(
    name: 'Phá Quân',
    tag: 'M',
    brightness: 'Hãm địa',
    element: 'Thủy',
    type: 'chính tinh',
  );
  const palace = ChartPalace(
    id: 'Dan',
    branch: 'Dần',
    canChi: 'Mậu Dần',
    name: 'QUAN LỘC',
    element: 'Mộc',
    isThan: false,
    mainStars: [star],
    luckyStars: ['Văn Khúc', 'Thiên Việt', 'Thiên Phúc', 'Thiên Đức'],
    badStars: ['Kiếp Sát', 'Địa Không'],
    vongTrangSinh: 'Lâm Quan',
    daiHanAge: 34,
    tieuHanAges: [2, 14, 26],
  );
  const rule = PalaceRule(
    id: 'rule-1',
    name: 'Phá Quân cư Quan Lộc',
    palace: 'QUAN LỘC',
    stars: ['Phá Quân'],
    summary: 'Tinh chủ biến động, khai phá và đổi mới.',
    content: '',
  );

  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('palace sections fit ${width.toInt()}dp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const PalaceHeroCard(palace: palace),
                        const MainStarsSection(stars: [star], rules: [rule]),
                        FeaturedStarsSection(
                          luckyStars: palace.luckyStars,
                          badStars: palace.badStars,
                        ),
                        StarsGroupSection(
                          luckyStars: palace.luckyStars,
                          badStars: palace.badStars,
                        ),
                        const RelatedPalacesSection(
                          palaces: [palace, palace, palace, palace],
                          rules: [],
                        ),
                        const FreeIntroductionSection(
                          summary:
                              'Cung Quan Lộc chủ về công danh, sự nghiệp, khả năng lập nghiệp và vị thế xã hội. Nội dung dài phải tự mở rộng chiều cao của khung thay vì bị cắt hoặc tràn ra ngoài.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

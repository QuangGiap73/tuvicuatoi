import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';

class HomeFeaturedGrid extends StatelessWidget {
  const HomeFeaturedGrid({
    required this.onChartPressed,
    required this.onTodayPressed,
    required this.onChatPressed,
    required this.onArticlesPressed,
    required this.onViewAllPressed,
    super.key,
  });

  final VoidCallback onChartPressed;
  final VoidCallback onTodayPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onArticlesPressed;
  final VoidCallback onViewAllPressed;

  @override
  Widget build(BuildContext context) {
    final items = <_FeaturedItem>[
      _FeaturedItem(
        icon: Icons.menu_book_rounded,
        title: 'Lá số Tử Vi',
        description: 'Lá số chi tiết\nLuận giải chuyên sâu',
        backgroundAsset: MysticAssets.homeOutstandingA,
        onPressed: onChartPressed,
      ),
      _FeaturedItem(
        icon: Icons.calendar_month_rounded,
        title: 'Vận hạn hôm nay',
        description: 'Can Chi & Giờ hoàng đạo\nSoi vận trình mỗi ngày',
        backgroundAsset: MysticAssets.homeOutstandingB,
        onPressed: onTodayPressed,
      ),
      _FeaturedItem(
        icon: Icons.chat_bubble_rounded,
        title: 'Hỏi đáp Tử Vi',
        description: 'Trợ lý AI giải đáp\nthắc mắc vận mệnh',
        backgroundAsset: MysticAssets.homeOutstandingC,
        onPressed: onChatPressed,
      ),
      _FeaturedItem(
        icon: Icons.auto_stories_rounded,
        title: 'Bài viết & Kiến thức',
        description: 'Kho tàng tri thức\ntử vi',
        backgroundAsset: MysticAssets.homeOutstandingD,
        onPressed: onArticlesPressed,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tính năng nổi bật',
                style: TextStyle(
                  color: Color(0xFFFFE3A0),
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAllPressed,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD8B66F),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Xem tất cả', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 3),
                  Icon(Icons.chevron_right_rounded, size: 17),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 1.12,
          ),
          itemBuilder: (context, index) => _FeaturedTile(item: items[index]),
        ),
      ],
    );
  }
}

class _FeaturedItem {
  const _FeaturedItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.backgroundAsset,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? backgroundAsset;
  final VoidCallback onPressed;
}

class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({required this.item});

  final _FeaturedItem item;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cacheWidth =
          (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round();

      return Semantics(
        button: true,
        label: item.title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: item.onPressed,
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  margin: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xE60B1C2D), Color(0xE605111F)],
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                if (item.backgroundAsset != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(9),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Transform.scale(
                            scale: 1.08,
                            child: Image.asset(
                              item.backgroundAsset!,
                              fit: BoxFit.cover,
                              alignment: Alignment.centerRight,
                              cacheWidth: cacheWidth,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xC205111F), Color(0x5905111F)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Image.asset(
                  MysticAssets.homeFeatureFrame,
                  fit: BoxFit.fill,
                  cacheWidth: cacheWidth,
                  filterQuality: FilterQuality.medium,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 16, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 39,
                        height: 39,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xB30B1B28),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFBF8E32),
                            width: 1.1,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          size: 21,
                          color: const Color(0xFFFFD875),
                        ),
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item.title,
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            color: Color(0xFFF6DCA2),
                            fontFamily: 'serif',
                            fontSize: 13.5,
                            height: 1.08,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(color: Color(0xB3000000), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFC9C3B6),
                                fontSize: 10.5,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: Color(0xFFFFCD64),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

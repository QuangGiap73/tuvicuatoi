import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';

/// Card thông điệp thuần hiển thị; dữ liệu động được truyền từ bên ngoài.
class HomeDailyMessageCard extends StatelessWidget {
  const HomeDailyMessageCard({
    required this.message,
    required this.year,
    super.key,
  });

  final String message;
  final int year;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isNarrow = width < 350;
      final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context))
          .round();

      return SizedBox(
        // Giữ đúng tỷ lệ của PNG để khung không bị kéo giãn khác nhau giữa máy.
        height: width / 2.205,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              MysticAssets.homeDailyMessageCard,
              fit: BoxFit.fill,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                width * .145,
                width * .095,
                width * .07,
                width * .09,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Thông điệp hôm nay',
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xFFF6D990),
                        fontFamily: 'serif',
                        fontSize: 21,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(color: Color(0xB3000000), blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isNarrow ? 0 : 2),
                  const Text(
                    'Lời nhắn dành cho bạn',
                    style: TextStyle(
                      color: Color(0xFFE0B557),
                      fontFamily: 'serif',
                      fontSize: 11.5,
                      height: 1.1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: isNarrow ? 2 : 4),
                  Container(
                    width: 124,
                    height: .7,
                    color: const Color(0x99936D2D),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        message,
                        maxLines: isNarrow ? 3 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFFF0E7D5),
                          fontSize: isNarrow ? 11.5 : 12.5,
                          height: 1.28,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _AuspiciousDatePill(year: year, compact: isNarrow),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _AuspiciousDatePill extends StatelessWidget {
  const _AuspiciousDatePill({required this.year, required this.compact});

  final int year;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: compact ? 9 : 12,
      vertical: compact ? 6 : 7,
    ),
    decoration: BoxDecoration(
      color: const Color(0xB30A1725),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFC18D31), width: .8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.calendar_month_outlined,
          size: compact ? 13 : 15,
          color: const Color(0xFFF0C65F),
        ),
        SizedBox(width: compact ? 5 : 7),
        Text(
          'Ngày cát lành  ·  $year',
          maxLines: 1,
          style: TextStyle(
            color: const Color(0xFFECE2CC),
            fontSize: compact ? 10.5 : 11.5,
            height: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

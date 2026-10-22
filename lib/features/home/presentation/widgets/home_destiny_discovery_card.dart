import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../../../core/theme/mystic_colors.dart';

/// Khối giới thiệu lập lá số trên Home.
///
/// Widget chỉ hiển thị dữ liệu và phát sự kiện qua [onPressed].
/// Điều hướng, loading và nghiệp vụ được giữ ở controller bên ngoài.
class HomeDestinyDiscoveryCard extends StatelessWidget {
  const HomeDestinyDiscoveryCard({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cacheWidth =
          (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round();

      return AspectRatio(
        // Tỷ lệ gốc 1680 × 938 của card_home_A, tránh kéo méo viền ảnh.
        aspectRatio: 1680 / 938,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Transform.scale(
                  alignment: Alignment.topCenter,
                  scaleX: 1.045,
                  scaleY: 1.06,
                  child: Image.asset(
                    MysticAssets.homeDestinyCard,
                    fit: BoxFit.fill,
                    cacheWidth: cacheWidth,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 18, 17),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 7,
                      child: Transform.translate(
                        offset: const Offset(0, -12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text(
                          'LẬP LÁ SỐ TỬ VI',
                          style: TextStyle(
                            color: MysticColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.25,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Khám phá bản mệnh',
                            maxLines: 1,
                            softWrap: false,
                            style: TextStyle(
                              color: Color(0xFFFFE4AD),
                              fontFamily: 'serif',
                              fontSize: 18.5,
                              height: 1.12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: .1,
                              shadows: [
                                Shadow(
                                  color: Color(0xB3000000),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'Giải mã lá số – hiểu rõ bản thân\nNắm bắt thời vận.',
                          style: TextStyle(
                            color: Color(0xFFE1D9CA),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _DiscoveryButton(onPressed: onPressed),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DiscoveryButton extends StatelessWidget {
  const _DiscoveryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Lập lá số ngay',
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFDF78), Color(0xFFC98C16)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x667D4F08),
              blurRadius: 9,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(22),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LẬP LÁ SỐ NGAY',
                  style: TextStyle(
                    color: Color(0xFF392507),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .35,
                  ),
                ),
                SizedBox(width: 7),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 15,
                  color: Color(0xFF392507),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

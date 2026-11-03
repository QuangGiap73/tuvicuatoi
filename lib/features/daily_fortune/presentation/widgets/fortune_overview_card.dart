import 'package:flutter/material.dart';
import '../../../../core/assets/mystic_assets.dart';
import '../../domain/daily_fortune.dart';

class FortuneOverviewCard extends StatelessWidget {
  const FortuneOverviewCard({
    required this.fortune,
    required this.loading,
    this.errorMessage,
    super.key,
  });
  final DailyFortune fortune;
  final bool loading;
  final String? errorMessage;
  @override
  Widget build(BuildContext context) {
    final score = fortune.fortuneScore.clamp(0, 100);
    return Column(
      children: [
        _FortuneHero(fortune: fortune, score: score, loading: loading),
        if (errorMessage?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xCC321B1B),
              border: Border.all(color: const Color(0xFFB96B55)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFFFFC8B6),
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FortuneHero extends StatelessWidget {
  const _FortuneHero({
    required this.fortune,
    required this.score,
    required this.loading,
  });
  final DailyFortune fortune;
  final int score;
  final bool loading;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final height = (width * .255).clamp(88.0, 122.0);
      final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context))
          .round();
      final rating = fortune.personal?.overallRating.trim();
      return RepaintBoundary(
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                MysticAssets.dailyFortuneOverviewFrame,
                fit: BoxFit.fill,
                cacheWidth: cacheWidth,
                gaplessPlayback: true,
                filterQuality: FilterQuality.medium,
              ),
              Positioned(
                left: width * .145,
                width: width * .35,
                top: height * .20,
                height: height * .43,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontFamily: 'serif',
                          fontSize: 39,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD35D),
                          shadows: [
                            Shadow(
                              color: Color(0xAA000000),
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '/100',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 13,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFF1C4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: width * .178,
                width: width * .263,
                top: height * .61,
                height: height * .23,
                child: Align(
                  alignment: const Alignment(0, -0.08),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      rating == null || rating.isEmpty
                          ? 'Đang cập nhật'
                          : rating,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: Color(0xFF39240E),
                        fontSize: 9,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: width * .04,
                width: width * .34,
                top: height * .23,
                height: height * .55,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '✦  Cung Nhật Hạn',
                        style: TextStyle(
                          color: Color(0xFFD8C391),
                          fontSize: 8.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        fortune.dailyPalace ?? 'Chưa chọn lá số',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          color: Color(0xFFFFD77C),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          shadows: [Shadow(color: Colors.black, blurRadius: 1)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (loading)
                const Positioned(
                  right: 14,
                  top: 14,
                  child: SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFFD77C),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/daily_fortune.dart';

class DailyFortuneDateSelector extends StatelessWidget {
  const DailyFortuneDateSelector({
    required this.date,
    required this.fortune,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onRetry,
    this.errorMessage,
    super.key,
  });

  final DateTime date;
  final DailyFortune? fortune;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onRetry;

  static const _weekdays = [
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final compact = width < 340;
      final frameHeight = (width / 3).clamp(104.0, 144.0);
      return SizedBox(
        height: frameHeight + 10,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: frameHeight,
              child: RepaintBoundary(
                child: Image.asset(
                  MysticAssets.dailyFortuneDateFrame,
                  fit: BoxFit.fill,
                  cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                      .round(),
                  filterQuality: FilterQuality.medium,
                ),
              ),
            ),
            Positioned(
              left: compact ? 18 : 22,
              right: compact ? 18 : 22,
              top: frameHeight * .18,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Transform.translate(
                      offset: const Offset(0, 5),
                      child: _DateMoveButton(
                        icon: Icons.chevron_left_rounded,
                        label: 'Hôm trước',
                        compact: compact,
                        onPressed: onPrevious,
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 5 : 9),
                  Expanded(
                    flex: 4,
                    child: _DateCenter(
                      date: date,
                      fortune: fortune,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                      onRetry: onRetry,
                    ),
                  ),
                  SizedBox(width: compact ? 5 : 9),
                  Expanded(
                    flex: 3,
                    child: Transform.translate(
                      offset: const Offset(0, 5),
                      child: _DateMoveButton(
                        icon: Icons.chevron_right_rounded,
                        label: 'Hôm sau',
                        compact: compact,
                        iconAfter: true,
                        onPressed: onNext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: frameHeight * .62,
              width: compact ? 104 : 112,
              child: _DateMoveButton(
                icon: Icons.calendar_today_rounded,
                label: 'Hôm nay',
                compact: compact,
                onPressed: onToday,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _DateCenter extends StatelessWidget {
  const _DateCenter({
    required this.date,
    required this.fortune,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final DateTime date;
  final DailyFortune? fortune;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        DailyFortuneDateSelector._weekdays[date.weekday - 1],
        style: const TextStyle(
          color: Color(0xFF3A2412),
          fontFamily: 'serif',
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        '${_two(date.day)}/${_two(date.month)}/${date.year}',
        maxLines: 1,
        style: const TextStyle(
          color: Color(0xFF251305),
          fontFamily: 'serif',
          fontSize: 23,
          height: 1.05,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 2),
      if (isLoading)
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.7,
            color: Color(0xFF80551F),
          ),
        )
      else if (errorMessage != null)
        InkWell(
          onTap: onRetry,
          child: const Text(
            'Chạm để tải lại',
            style: TextStyle(
              color: Color(0xFF9A2931),
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      else
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _canChiText(fortune),
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF654321),
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );

  static String _canChiText(DailyFortune? fortune) {
    if (fortune == null) return 'Đang cập nhật lịch Can Chi';
    final parts = <String>[
      if (fortune.canChiDay != null) 'Ngày ${fortune.canChiDay}',
      if (fortune.canChiMonth != null) 'Tháng ${fortune.canChiMonth}',
      if (fortune.canChiYear != null) 'Năm ${fortune.canChiYear}',
    ];
    return parts.isEmpty ? 'Chưa có dữ liệu Can Chi' : parts.join(' • ');
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}

class _DateMoveButton extends StatelessWidget {
  const _DateMoveButton({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onPressed,
    this.iconAfter = false,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final bool iconAfter;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: compact ? 15 : 17,
      color: const Color(0xFF39210E),
    );
    final textWidget = Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: const Color(0xFF39210E),
            fontFamily: 'serif',
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
    return Opacity(
      opacity: onPressed == null ? .82 : 1,
      child: SizedBox(
        height: 40,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              MysticAssets.dailyFortuneButtonFrame,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: iconAfter
                        ? [textWidget, const SizedBox(width: 2), iconWidget]
                        : [iconWidget, const SizedBox(width: 2), textWidget],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

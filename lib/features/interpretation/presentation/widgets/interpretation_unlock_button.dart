import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';

class InterpretationUnlockButton extends StatelessWidget {
  const InterpretationUnlockButton({
    required this.lockedCount,
    required this.totalCost,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final int lockedCount;
  final int totalCost;
  final bool isLoading;
  final VoidCallback onPressed;

  bool get _isFullyUnlocked => !isLoading && lockedCount == 0;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: !isLoading,
    label: _isFullyUnlocked
        ? 'Đã mở toàn bộ luận giải'
        : 'Xem các mục luận giải chưa mở, tổng giá $totalCost Xu',
    child: AspectRatio(
      aspectRatio: 2065 / 372,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: _FrameBackground()),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(27, 7, 25, 7),
                child: Row(
                  children: [
                    Icon(
                      _isFullyUnlocked
                          ? Icons.verified_rounded
                          : Icons.card_giftcard_rounded,
                      color: const Color(0xFF6D3C12),
                      size: 23,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF593313),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF76501F),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isLoading)
                      const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF754713),
                        ),
                      )
                    else
                      Icon(
                        _isFullyUnlocked
                            ? Icons.check_circle_outline_rounded
                            : Icons.chevron_right_rounded,
                        color: const Color(0xFF633B15),
                        size: 21,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  String get _title => isLoading
      ? 'Đang kiểm tra quyền luận giải'
      : _isFullyUnlocked
      ? 'Đã mở toàn bộ luận giải'
      : 'Mở khóa toàn bộ luận giải';

  String get _subtitle => isLoading
      ? 'Đang tải bảng giá từ máy chủ...'
      : _isFullyUnlocked
      ? 'Bạn có thể xem tất cả nội dung'
      : '$lockedCount mục • Tổng giá hiện tại $totalCost Xu';
}

class _FrameBackground extends StatelessWidget {
  const _FrameBackground();

  @override
  Widget build(BuildContext context) => Image.asset(
    MysticAssets.upgradeFrameB,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.medium,
  );
}

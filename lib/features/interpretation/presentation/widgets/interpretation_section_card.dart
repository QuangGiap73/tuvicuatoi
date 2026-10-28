import 'package:flutter/material.dart';

import '../../domain/interpretation_models.dart';

class InterpretationSectionCard extends StatelessWidget {
  const InterpretationSectionCard({
    required this.section,
    required this.isUnlocked,
    required this.unlockStatus,
    required this.onOpen,
    required this.onUnlock,
    this.canUnlock = true,
    this.isSharedContent = false,
    super.key,
  });

  final ReadingSection section;
  final bool isUnlocked;
  final UnlockStatus unlockStatus;
  final VoidCallback onOpen;
  final VoidCallback onUnlock;
  final bool canUnlock;
  final bool isSharedContent;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.fromLTRB(12, 10, 11, 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5E3BC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFC79743), width: 1.1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SectionIcon(icon: _iconFor(section)),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF513118),
                      fontFamily: 'serif',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF786142),
                      fontSize: 10.5,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (isSharedContent) ...[
                    const _SharedContentBadge(),
                    const SizedBox(height: 5),
                  ],
                  _SectionAction(
                    isUnlocked: isUnlocked,
                    unlockStatus: unlockStatus,
                    coinCost: section.coinCost,
                    onPressed: onUnlock,
                    canUnlock: canUnlock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String get _description {
    if (section.subtitle.trim().isNotEmpty) return section.subtitle.trim();
    if (section.summary.trim().isNotEmpty) return section.summary.trim();
    return 'Nội dung luận giải chuyên sâu cho lá số này.';
  }

  static IconData _iconFor(ReadingSection section) {
    final value = '${section.iconName} ${section.sectionSlug} ${section.title}'
        .toLowerCase();
    if (value.contains('tai') ||
        value.contains('wealth') ||
        value.contains('money')) {
      return Icons.monetization_on_outlined;
    }
    if (value.contains('nghiep') ||
        value.contains('career') ||
        value.contains('cong_danh')) {
      return Icons.trending_up_rounded;
    }
    if (value.contains('hon') ||
        value.contains('tinh_cam') ||
        value.contains('love') ||
        value.contains('marriage')) {
      return Icons.favorite_rounded;
    }
    if (value.contains('suc_khoe') ||
        value.contains('health') ||
        value.contains('tat_ach')) {
      return Icons.spa_rounded;
    }
    if (value.contains('van_han') || value.contains('fortune')) {
      return Icons.auto_graph_rounded;
    }
    return Icons.menu_book_rounded;
  }
}

class _SharedContentBadge extends StatelessWidget {
  const _SharedContentBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0x1F986216),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0x66986216)),
    ),
    child: const Text(
      'Chuyên đề chung',
      style: TextStyle(
        color: Color(0xFF7B501A),
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0x33D6A443),
      border: Border.all(color: const Color(0x99C58A2D)),
      boxShadow: const [BoxShadow(color: Color(0x55D79E2C), blurRadius: 8)],
    ),
    alignment: Alignment.center,
    child: Icon(icon, color: const Color(0xFF93601A), size: 29),
  );
}

class _SectionAction extends StatelessWidget {
  const _SectionAction({
    required this.isUnlocked,
    required this.unlockStatus,
    required this.coinCost,
    required this.onPressed,
    required this.canUnlock,
  });

  final bool isUnlocked;
  final UnlockStatus unlockStatus;
  final int coinCost;
  final VoidCallback onPressed;
  final bool canUnlock;

  bool get _isLoading =>
      unlockStatus == UnlockStatus.submitting ||
      unlockStatus == UnlockStatus.confirming;

  bool get _isSyncing => unlockStatus == UnlockStatus.syncing;

  @override
  Widget build(BuildContext context) => Semantics(
    button: !isUnlocked,
    enabled: canUnlock && !isUnlocked && !_isLoading && !_isSyncing,
    label: isUnlocked
        ? 'Đã mở khóa'
        : _isSyncing
        ? 'Đang đồng bộ quyền'
        : canUnlock
        ? 'Mở khóa $coinCost Xu'
        : 'Chưa cấu hình giá',
    child: Material(
      color: isUnlocked ? const Color(0xFF437A5E) : const Color(0xFF986216),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: !canUnlock || isUnlocked || _isLoading || _isSyncing
            ? null
            : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading || _isSyncing)
                const SizedBox.square(
                  dimension: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.7,
                    color: Color(0xFFFFE4A3),
                  ),
                )
              else
                Icon(
                  isUnlocked
                      ? Icons.lock_open_rounded
                      : Icons.lock_outline_rounded,
                  color: const Color(0xFFFFE4A3),
                  size: 13,
                ),
              const SizedBox(width: 4),
              Text(
                _isSyncing
                    ? 'Đang đồng bộ quyền'
                    : _isLoading
                    ? 'Đang mở...'
                    : isUnlocked
                    ? 'Đã mở khóa'
                    : !canUnlock
                    ? 'Chưa cấu hình giá'
                    : 'Mở khóa $coinCost Xu',
                style: const TextStyle(
                  color: Color(0xFFFFE8B2),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

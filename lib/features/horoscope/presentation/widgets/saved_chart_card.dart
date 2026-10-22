import 'package:flutter/material.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../../domain/saved_chart.dart';

class SavedChartCard extends StatelessWidget {
  const SavedChartCard({
    required this.chart,
    required this.isDeleting,
    required this.onInterpret,
    required this.onAskAi,
    required this.onDelete,
    super.key,
  });

  final SavedChart chart;
  final bool isDeleting;
  final VoidCallback onInterpret;
  final VoidCallback onAskAi;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 350;
      final cacheWidth =
          (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
              .round();
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MysticAssets.myChartCardFrame,
              fit: BoxFit.fill,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 25 : 30,
              compact ? 25 : 30,
              compact ? 25 : 30,
              compact ? 23 : 27,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chart.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF33200F),
                    fontFamily: 'serif',
                    fontSize: compact ? 23 : 27,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ElementBadge(element: chart.element),
                    const SizedBox(width: 8),
                    _GenderBadge(gender: chart.gender),
                  ],
                ),
                const Divider(color: Color(0x559A6E31), height: 18),
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Dương lịch',
                  value: _fallback(chart.solarDate),
                  emphasized: true,
                ),
                _InfoRow(
                  icon: Icons.dark_mode_outlined,
                  label: 'Âm lịch',
                  value: _fallback(chart.lunarDate),
                ),
                _InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Giờ sinh',
                  value: chart.hourBranch ?? 'Chưa cập nhật',
                ),
                _InfoRow(
                  icon: Icons.article_outlined,
                  label: 'Tạo ngày',
                  value: _fallback(chart.createdAt),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _CardAction(
                        icon: Icons.menu_book_outlined,
                        label: 'LUẬN GIẢI',
                        onPressed: onInterpret,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CardAction(
                        icon: Icons.auto_awesome,
                        label: 'HỎI AI',
                        dark: true,
                        onPressed: onAskAi,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CardAction(
                        icon: Icons.delete_outline_rounded,
                        label: 'XÓA',
                        danger: true,
                        loading: isDeleting,
                        onPressed: isDeleting ? null : onDelete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  static String _fallback(String value) =>
      value.trim().isEmpty ? 'Chưa cập nhật' : value;
}

class _ElementBadge extends StatelessWidget {
  const _ElementBadge({required this.element});
  final String element;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (element) {
      'KIM' => (const Color(0xFF9A711F), Icons.diamond_outlined),
      'MỘC' => (const Color(0xFF138568), Icons.eco_rounded),
      'THỦY' => (const Color(0xFF226EAE), Icons.water_drop_outlined),
      'HỎA' => (const Color(0xFFB52D45), Icons.local_fire_department_rounded),
      'THỔ' => (const Color(0xFF9B651B), Icons.landscape_outlined),
      _ => (const Color(0xFF76613F), Icons.auto_awesome_outlined),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withValues(alpha: .7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            element.isEmpty ? 'BẢN MỆNH' : 'MỆNH $element',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  const _GenderBadge({required this.gender});
  final String gender;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x99EFE8D9),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFFBBAE95)),
    ),
    child: Text(
      gender.isEmpty ? '—' : gender,
      style: const TextStyle(
        color: Color(0xFF4A3825),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasized = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.5),
    child: Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF4E351B)),
        const SizedBox(width: 9),
        Text(
          '$label: ',
          style: const TextStyle(color: Color(0xFF5A4026), fontSize: 11.5),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF332414),
              fontSize: 11.5,
              fontWeight: emphasized ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.dark = false,
    this.danger = false,
    this.loading = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 43,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth =
            (constraints.maxWidth * MediaQuery.devicePixelRatioOf(context))
                .round();
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              MysticAssets.upgradeFrameB,
              fit: BoxFit.fill,
              cacheWidth: cacheWidth,
              filterQuality: FilterQuality.medium,
            ),
            TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                foregroundColor: danger
                    ? const Color(0xFFB51F35)
                    : dark
                    ? const Color(0xFF123A50)
                    : const Color(0xFF3D2A17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (loading)
                      const SizedBox.square(
                        dimension: 13,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(icon, size: 17),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

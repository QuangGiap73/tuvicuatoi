import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/assets/mystic_assets.dart';
import '../../../horoscope/domain/saved_chart.dart';
import '../../../horoscope/presentation/providers/chart_form_providers.dart';
import '../../../horoscope/presentation/state/my_charts_state.dart';

Future<SavedChart?> showChartPickerDialog(
  BuildContext context, {
  String? selectedChartId,
}) => showGeneralDialog<SavedChart>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Đóng danh sách lá số',
  barrierColor: const Color(0x99000000),
  transitionDuration: const Duration(milliseconds: 220),
  pageBuilder: (context, _, _) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
    child: Center(child: _ChartPickerDialog(selectedChartId: selectedChartId)),
  ),
  transitionBuilder: (context, animation, _, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween(
        begin: .96,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    ),
  ),
);

class _ChartPickerDialog extends ConsumerWidget {
  const _ChartPickerDialog({this.selectedChartId});
  final String? selectedChartId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myChartsControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = size.width.clamp(0, 382).toDouble() - 24;
    // Khung tăng theo số lá số thực tế. Từ lá số thứ tư trở đi chỉ danh
    // sách cuộn, tránh modal kéo quá dài trên màn hình nhỏ.
    final visibleChartSlots = state.charts.isEmpty
        ? 1
        : state.charts.length.clamp(1, 3);
    final desiredHeight = 248.0 + (visibleChartSlots * 84.0);
    final maxDialogHeight = size.height * .72;
    final dialogHeight = maxDialogHeight <= 332
        ? maxDialogHeight
        : desiredHeight.clamp(332.0, maxDialogHeight).toDouble();
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: Image.asset(
                MysticAssets.chartPickerBackground,
                fit: BoxFit.fill,
                cacheWidth: (dialogWidth * dpr).round(),
                filterQuality: FilterQuality.medium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: const Color(0xFFC69A53)),
                        ),
                        child: const Text(
                          '✧  CHỌN LÁ SỐ ĐÀM ĐẠO',
                          style: TextStyle(
                            color: Color(0xFF6B4A27),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _CloseButton(onTap: context.pop),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Lá Số Trong Kho Lưu Trữ',
                    style: TextStyle(
                      color: Color(0xFF342113),
                      fontFamily: 'serif',
                      fontSize: 19,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Divider(color: Color(0x449B713E), height: 18),
                  const Text(
                    'Chọn một lá số dưới đây để hệ thống nạp dữ liệu thiên bàn và 12 cung chức tương ứng:',
                    style: TextStyle(
                      color: Color(0xFF826747),
                      fontSize: 9.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: _ChartPickerBody(
                      state: state,
                      selectedId: selectedChartId,
                      onRetry: () =>
                          ref.read(myChartsControllerProvider.notifier).load(),
                    ),
                  ),
                  const Divider(color: Color(0x449B713E), height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            context.pop();
                            context.push(AppRoute.horoscope);
                          },
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: const Text('LẬP THÊM LÁ SỐ MỚI'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFE3A0),
                            backgroundColor: const Color(0xFF071827),
                            side: const BorderSide(color: Color(0xFFD5A64B)),
                            textStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      FilledButton(
                        onPressed: context.pop,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF4B2308),
                          foregroundColor: const Color(0xFFFFE8BD),
                        ),
                        child: const Text(
                          'ĐÓNG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartPickerBody extends StatelessWidget {
  const _ChartPickerBody({
    required this.state,
    required this.onRetry,
    this.selectedId,
  });
  final MyChartsState state;
  final VoidCallback onRetry;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.charts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9C6A25)),
      );
    }
    if (state.errorMessage != null && state.charts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8D2634)),
            ),
            TextButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      );
    }
    if (state.charts.isEmpty) {
      return const Center(child: Text('Bạn chưa lưu lá số nào.'));
    }
    return ListView.separated(
      shrinkWrap: true,
      itemCount: state.charts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final SavedChart chart = state.charts[index];
        final selected = selectedId != null && chart.id == selectedId;
        return _ChartOption(chart: chart, selected: selected);
      },
    );
  }
}

class _ChartOption extends StatelessWidget {
  const _ChartOption({required this.chart, required this.selected});
  final SavedChart chart;
  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFF2DCB0) : const Color(0xFFFFF8E9),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: selected ? const Color(0xFFB77B2E) : const Color(0xFFD8C6A6),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      chart.displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF352114),
                        fontFamily: 'serif',
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  _GenderPill(label: chart.gender),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${chart.menh ?? 'Chưa cập nhật bản mệnh'}\nSinh: ${chart.solarDate} (DL)  ·  Giờ ${chart.hourBranch ?? 'chưa rõ'}',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF78593A),
                  fontSize: 9.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: selected ? null : () => Navigator.pop(context, chart),
          style: FilledButton.styleFrom(
            disabledBackgroundColor: const Color(0xFF4B2308),
            disabledForegroundColor: const Color(0xFFFFE8BD),
            backgroundColor: const Color(0xFF4B2308),
            foregroundColor: const Color(0xFFFFE8BD),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          ),
          child: Text(
            selected ? '✓  Đang đàm\nđạo' : 'CHỌN LÁ\nNÀY',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF49301C),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFFFFE9BE),
        fontSize: 7,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      width: 29,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF071827),
        border: Border.all(color: const Color(0xFFD7A747)),
      ),
      child: const Icon(Icons.close, color: Color(0xFFFFE5AA), size: 17),
    ),
  );
}

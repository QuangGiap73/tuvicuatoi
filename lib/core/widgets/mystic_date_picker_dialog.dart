import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../assets/mystic_assets.dart';

class MysticDatePickerDialog extends StatefulWidget {
  const MysticDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title = 'Chọn ngày xem vận hạn',
    this.showTodayButton = true,
    super.key,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final bool showTodayButton;

  @override
  State<MysticDatePickerDialog> createState() => _MysticDatePickerDialogState();
}

class _MysticDatePickerDialogState extends State<MysticDatePickerDialog> {
  static const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

  late final DateTime selectedDate;
  late DateTime visibleMonth;

  @override
  void initState() {
    super.initState();
    final initial = DateUtils.dateOnly(widget.initialDate);
    final first = DateUtils.dateOnly(widget.firstDate);
    final last = DateUtils.dateOnly(widget.lastDate);
    selectedDate = initial.isBefore(first)
        ? first
        : initial.isAfter(last)
        ? last
        : initial;
    visibleMonth = DateTime(selectedDate.year, selectedDate.month);
  }

  bool get canGoPrevious => !DateTime(
    visibleMonth.year,
    visibleMonth.month - 1,
  ).isBefore(DateTime(widget.firstDate.year, widget.firstDate.month));

  bool get canGoNext => !DateTime(
    visibleMonth.year,
    visibleMonth.month + 1,
  ).isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));

  void changeMonth(int delta) {
    if ((delta < 0 && !canGoPrevious) || (delta > 0 && !canGoNext)) return;
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + delta);
    });
  }

  Future<void> pickMonthAndYear() async {
    final firstYear = widget.firstDate.year;
    final lastYear = widget.lastDate.year;
    var pendingMonth = visibleMonth.month;
    var pendingYear = visibleMonth.year;
    final monthController = FixedExtentScrollController(
      initialItem: pendingMonth - 1,
    );
    final yearController = FixedExtentScrollController(
      initialItem: pendingYear - firstYear,
    );

    final result = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x9900050A),
      builder: (sheetContext) => _MonthYearPickerSheet(
        firstYear: firstYear,
        lastYear: lastYear,
        monthController: monthController,
        yearController: yearController,
        onMonthChanged: (index) => pendingMonth = index + 1,
        onYearChanged: (index) => pendingYear = firstYear + index,
        onCancel: () => Navigator.pop(sheetContext),
        onConfirm: () {
          var value = DateTime(pendingYear, pendingMonth);
          final firstMonth = DateTime(
            widget.firstDate.year,
            widget.firstDate.month,
          );
          final lastMonth = DateTime(
            widget.lastDate.year,
            widget.lastDate.month,
          );
          if (value.isBefore(firstMonth)) value = firstMonth;
          if (value.isAfter(lastMonth)) value = lastMonth;
          Navigator.pop(sheetContext, value);
        },
      ),
    );
    monthController.dispose();
    yearController.dispose();
    if (result != null && mounted) setState(() => visibleMonth = result);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final compact = screen.height < 680 || screen.width < 350;
    final dialogHeight = (screen.height - 56).clamp(460.0, 540.0);
    final today = DateUtils.dateOnly(DateTime.now());

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 350, maxHeight: dialogHeight),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF061725),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFE0AC3D), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                const Positioned.fill(child: _CalendarBackdrop()),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 16,
                    compact ? 8 : 10,
                    compact ? 12 : 16,
                    compact ? 5 : 8,
                  ),
                  child: Column(
                    children: [
                      _DialogHeader(
                        title: widget.title,
                        onClose: () => Navigator.pop(context),
                      ),
                      SizedBox(height: compact ? 7 : 10),
                      _MonthNavigation(
                        month: visibleMonth,
                        canGoPrevious: canGoPrevious,
                        canGoNext: canGoNext,
                        onPrevious: () => changeMonth(-1),
                        onNext: () => changeMonth(1),
                        onPickMonth: pickMonthAndYear,
                      ),
                      SizedBox(height: compact ? 6 : 8),
                      const _WeekdayHeader(),
                      const SizedBox(height: 4),
                      Expanded(
                        child: _CalendarGrid(
                          visibleMonth: visibleMonth,
                          selectedDate: selectedDate,
                          firstDate: widget.firstDate,
                          lastDate: widget.lastDate,
                          today: today,
                          onSelected: (date) => Navigator.pop(context, date),
                        ),
                      ),
                      if (widget.showTodayButton)
                        _TodayButton(
                          onPressed: () {
                            if (!today.isBefore(widget.firstDate) &&
                                !today.isAfter(widget.lastDate)) {
                              Navigator.pop(context, today);
                            }
                          },
                        ),
                      SizedBox(height: compact ? 2 : 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarBackdrop extends StatelessWidget {
  const _CalendarBackdrop();

  @override
  Widget build(BuildContext context) {
    final requestedWidth =
        (MediaQuery.sizeOf(context).width.clamp(0, 350) *
                MediaQuery.devicePixelRatioOf(context))
            .round();
    final decodedWidth = requestedWidth.clamp(1, 800);
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              MysticAssets.fortuneCalendarBackground,
              fit: BoxFit.fill,
              cacheWidth: decodedWidth,
              filterQuality: FilterQuality.medium,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x16000000),
                    Color(0x08000000),
                    Color(0x12000000),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 680;
    return SizedBox(
      height: compact ? 50 : 58,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 3,
            right: 3,
            bottom: -10,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFFFFE5A2),
                  fontFamily: 'serif',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black, blurRadius: 3)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Đóng',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 17),
              color: const Color(0xFFFFD36B),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0x9910202C),
                side: const BorderSide(color: Color(0xFFB57B22)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  const _MonthNavigation({
    required this.month,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onPickMonth,
  });
  final DateTime month;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onPickMonth;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _MonthArrow(
        icon: Icons.chevron_left_rounded,
        enabled: canGoPrevious,
        onTap: onPrevious,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPickMonth,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0x99102B3C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFB57B22)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tháng ${month.month} ${month.year}',
                    style: const TextStyle(
                      color: Color(0xFFFFE1A0),
                      fontFamily: 'serif',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Color(0xFFE7AF3D),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      _MonthArrow(
        icon: Icons.chevron_right_rounded,
        enabled: canGoNext,
        onTap: onNext,
      ),
    ],
  );
}

class _MonthArrow extends StatelessWidget {
  const _MonthArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: enabled ? onTap : null,
    icon: Icon(icon),
    color: const Color(0xFFFFD36B),
    disabledColor: const Color(0x556E6E6E),
    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
    padding: EdgeInsets.zero,
    style: IconButton.styleFrom(
      backgroundColor: const Color(0x9910202C),
      side: BorderSide(
        color: enabled ? const Color(0xFFB57B22) : const Color(0x334F4F4F),
      ),
    ),
  );
}

class _MonthYearPickerSheet extends StatelessWidget {
  const _MonthYearPickerSheet({
    required this.firstYear,
    required this.lastYear,
    required this.monthController,
    required this.yearController,
    required this.onMonthChanged,
    required this.onYearChanged,
    required this.onCancel,
    required this.onConfirm,
  });

  final int firstYear;
  final int lastYear;
  final FixedExtentScrollController monthController;
  final FixedExtentScrollController yearController;
  final ValueChanged<int> onMonthChanged;
  final ValueChanged<int> onYearChanged;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      height: 300,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF071927),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9A338), width: 1.3),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 14)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 4),
              child: Row(
                children: [
                  TextButton(onPressed: onCancel, child: const Text('Hủy')),
                  const Expanded(
                    child: Text(
                      'Chọn tháng và năm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFE1A0),
                        fontFamily: 'serif',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(onPressed: onConfirm, child: const Text('Xong')),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0x886E531F)),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 43,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0x332E91A8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x99C8942E)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker.builder(
                          scrollController: monthController,
                          itemExtent: 43,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: onMonthChanged,
                          childCount: 12,
                          itemBuilder: (context, index) => Center(
                            child: Text(
                              'Tháng ${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFFFFEDC3),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker.builder(
                          scrollController: yearController,
                          itemExtent: 43,
                          selectionOverlay: const SizedBox.shrink(),
                          onSelectedItemChanged: onYearChanged,
                          childCount: lastYear - firstYear + 1,
                          itemBuilder: (context, index) => Center(
                            child: Text(
                              '${firstYear + index}',
                              style: const TextStyle(
                                color: Color(0xFFFFEDC3),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
    ),
  );
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x88111E28),
      border: Border.symmetric(
        horizontal: BorderSide(
          color: const Color(0xFF8C641F).withValues(alpha: .7),
        ),
      ),
    ),
    child: Row(
      children: _MysticDatePickerDialogState.weekdays
          .map(
            (day) => Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFF5D786),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(growable: false),
    ),
  );
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: onPressed,
    icon: const Icon(Icons.calendar_today_outlined, size: 13),
    label: const Text('Hôm nay'),
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFFDE89),
      minimumSize: const Size(96, 30),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      visualDensity: VisualDensity.compact,
      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
  );
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.today,
    required this.onSelected,
  });
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final leadingEmptyDays = firstDay.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final minimumDate = DateUtils.dateOnly(firstDate);
    final maximumDate = DateUtils.dateOnly(lastDate);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 7;
        final cellHeight = (constraints.maxHeight - 8) / 6;
        final childAspectRatio = (cellWidth / cellHeight).clamp(.85, 1.5);
        final markerSize = cellHeight.clamp(30.0, 36.0);
        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final day = index - leadingEmptyDays + 1;
            if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
            final date = DateTime(visibleMonth.year, visibleMonth.month, day);
            final enabled =
                !date.isBefore(minimumDate) && !date.isAfter(maximumDate);
            final selected = DateUtils.isSameDay(date, selectedDate);
            final isToday = DateUtils.isSameDay(date, today);

            return Semantics(
              button: enabled,
              selected: selected,
              label: '$day/${visibleMonth.month}/${visibleMonth.year}',
              child: InkResponse(
                onTap: enabled ? () => onSelected(date) : null,
                radius: 23,
                child: Center(
                  child: Container(
                    width: markerSize,
                    height: markerSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? const Color(0xFFFFCF55)
                          : Colors.transparent,
                      border: isToday && !selected
                          ? Border.all(color: const Color(0xFFC8942E))
                          : null,
                      boxShadow: selected
                          ? const [
                              BoxShadow(
                                color: Color(0x99FFB900),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: !enabled
                            ? const Color(0x556F7780)
                            : selected
                            ? const Color(0xFF352000)
                            : const Color(0xFFFFF0C8),
                        fontFamily: 'serif',
                        fontSize: 17,
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

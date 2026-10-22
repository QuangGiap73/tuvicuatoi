import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/assets/mystic_assets.dart';
import '../providers/chart_form_providers.dart';

class ChartBirthFormCard extends ConsumerStatefulWidget {
  const ChartBirthFormCard({
    required this.onSubmit,
    this.isSubmitting = false,
    super.key,
  });

  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  ConsumerState<ChartBirthFormCard> createState() => _ChartBirthFormCardState();
}

class _ChartBirthFormCardState extends ConsumerState<ChartBirthFormCard> {
  late final TextEditingController _nameController;
  late final List<int> _years;

  static const _hours = <(int, String)>[
    (23, 'Giờ Tý (23:00 - 00:59)'),
    (1, 'Giờ Sửu (01:00 - 02:59)'),
    (3, 'Giờ Dần (03:00 - 04:59)'),
    (5, 'Giờ Mão (05:00 - 06:59)'),
    (7, 'Giờ Thìn (07:00 - 08:59)'),
    (9, 'Giờ Tỵ (09:00 - 10:59)'),
    (11, 'Giờ Ngọ (11:00 - 12:59)'),
    (13, 'Giờ Mùi (13:00 - 14:59)'),
    (15, 'Giờ Thân (15:00 - 16:59)'),
    (17, 'Giờ Dậu (17:00 - 18:59)'),
    (19, 'Giờ Tuất (19:00 - 20:59)'),
    (21, 'Giờ Hợi (21:00 - 22:59)'),
  ];

  @override
  void initState() {
    super.initState();
    _years = List<int>.generate(
      DateTime.now().year - 1899,
      (index) => DateTime.now().year - index,
      growable: false,
    );
    _nameController = TextEditingController(
      text: ref.read(chartFormControllerProvider).fullName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chartFormControllerProvider);
    final controller = ref.read(chartFormControllerProvider.notifier);
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            MysticAssets.horoscopeFormFrame,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nhập thông tin sinh chủ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF3F2914),
                  fontFamily: 'serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Họ và tên', isRequired: true),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                onChanged: controller.setFullName,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Color(0xFF332414), fontSize: 14),
                decoration: _inputDecoration('Nhập họ và tên sinh chủ'),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: _FieldLabel('Ngày sinh')),
                  SizedBox(width: 8),
                  Expanded(child: _FieldLabel('Tháng sinh')),
                  SizedBox(width: 8),
                  Expanded(child: _FieldLabel('Năm sinh')),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _MysticDropdown<int>(
                      value: state.day,
                      items: List<int>.generate(31, (index) => index + 1),
                      labelBuilder: (value) => '$value',
                      onChanged: controller.setDay,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MysticDropdown<int>(
                      value: state.month,
                      items: List<int>.generate(12, (index) => index + 1),
                      labelBuilder: (value) => value.toString().padLeft(2, '0'),
                      onChanged: controller.setMonth,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MysticDropdown<int>(
                      value: state.year,
                      items: _years,
                      labelBuilder: (value) => '$value',
                      onChanged: controller.setYear,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Giờ sinh'),
              const SizedBox(height: 6),
              _MysticDropdown<int>(
                value: _nearestHour(state.hour),
                items: _hours.map((item) => item.$1).toList(growable: false),
                labelBuilder: (value) =>
                    _hours.firstWhere((item) => item.$1 == value).$2,
                prefix: const Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: Color(0xFF74512A),
                ),
                onChanged: controller.setHour,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Giới tính'),
              const SizedBox(height: 6),
              _MysticDropdown<String>(
                value: state.gender,
                items: const ['Nam', 'Nữ'],
                labelBuilder: (value) => value,
                prefix: Icon(
                  state.gender == 'Nam'
                      ? Icons.male_rounded
                      : Icons.female_rounded,
                  size: 18,
                  color: const Color(0xFF74512A),
                ),
                onChanged: controller.setGender,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Dương lịch / Âm lịch'),
              const SizedBox(height: 4),
              Wrap(
                spacing: 16,
                children: [
                  _CalendarChoice(
                    label: 'Dương lịch',
                    selected: state.calendarType == 'solar',
                    onTap: () => controller.setCalendarType('solar'),
                  ),
                  _CalendarChoice(
                    label: 'Âm lịch',
                    selected: state.calendarType == 'lunar',
                    onTap: () => controller.setCalendarType('lunar'),
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFF9B2F24),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _GenerateChartButton(
                isLoading: widget.isSubmitting,
                onPressed: widget.onSubmit,
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF8A6B45),
                  ),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'Thông tin của bạn được bảo mật tuyệt đối.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8A6B45),
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _nearestHour(int hour) {
    if (hour == 0) return 23;
    if (hour.isEven) return hour - 1;
    return _hours.any((item) => item.$1 == hour) ? hour : 7;
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF9AA0A8), fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF8F3E9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    enabledBorder: _inputBorder,
    focusedBorder: _inputBorder.copyWith(
      borderSide: const BorderSide(color: Color(0xFFB77C22), width: 1.4),
    ),
  );

  OutlineInputBorder get _inputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFCDB68E)),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {this.isRequired = false});
  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: label,
      children: [
        if (isRequired)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFB13C27)),
          ),
      ],
    ),
    style: const TextStyle(
      color: Color(0xFF5D4630),
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _MysticDropdown<T> extends StatefulWidget {
  const _MysticDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.prefix,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final Widget? prefix;

  @override
  State<_MysticDropdown<T>> createState() => _MysticDropdownState<T>();
}

class _MysticDropdownState<T> extends State<_MysticDropdown<T>> {
  static const _itemHeight = 42.0;
  static const _maxMenuHeight = 218.0;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ScrollController? _menuScrollController;

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeMenu();
      return;
    }

    final renderBox = context.findRenderObject()! as RenderBox;
    final menuWidth = renderBox.size.width;
    final selectedIndex = widget.items.indexOf(widget.value);
    final contentHeight = widget.items.length * _itemHeight;
    final menuHeight = contentHeight.clamp(0.0, _maxMenuHeight);
    final maxScrollOffset = (contentHeight - menuHeight).clamp(
      0.0,
      double.infinity,
    );
    final scrollController = ScrollController(
      initialScrollOffset: selectedIndex <= 0
          ? 0
          : (selectedIndex * _itemHeight).clamp(0.0, maxScrollOffset),
    );
    _menuScrollController = scrollController;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeMenu,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 48),
            child: Material(
              color: const Color(0xFFFFF8E9),
              elevation: 8,
              shadowColor: const Color(0x66000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
                side: const BorderSide(color: Color(0xFFB98A42)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: menuWidth,
                height: menuHeight,
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  itemExtent: _itemHeight,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = item == widget.value;
                    return InkWell(
                      onTap: () {
                        _removeMenu();
                        widget.onChanged(item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.labelBuilder(item),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF9A651D)
                                  : const Color(0xFF3D2D1E),
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _menuScrollController?.dispose();
    _menuScrollController = null;
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
    link: _layerLink,
    child: InkWell(
      onTap: _toggleMenu,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 43,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F3E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFCDB68E)),
        ),
        child: Row(
          children: [
            if (widget.prefix != null) ...[
              widget.prefix!,
              const SizedBox(width: 7),
            ],
            Expanded(
              child: Text(
                widget.labelBuilder(widget.value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF3D2D1E), fontSize: 12),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF725D43),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CalendarChoice extends StatelessWidget {
  const _CalendarChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 17,
            color: selected ? const Color(0xFF9A651D) : const Color(0xFF725D43),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF4A3826), fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _GenerateChartButton extends StatelessWidget {
  const _GenerateChartButton({
    required this.isLoading,
    required this.onPressed,
  });
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(MysticAssets.bottomFrameA, fit: BoxFit.fill),
        TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFF3D2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFD46F),
                  ),
                )
              : const Text(
                  'LẬP LÁ SỐ NGAY',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
        ),
      ],
    ),
  );
}

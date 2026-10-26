import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/interpretation_models.dart';
import 'controllers/interpretation_controller.dart';
import 'state/interpretation_state.dart';
import 'widgets/interpretation_tab_bar.dart';
import 'widgets/interpretation_unlock_button.dart';

class InterpretationPage extends ConsumerWidget {
  const InterpretationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(interpretationControllerProvider);
    final controller = ref.read(interpretationControllerProvider.notifier);
    final balance = ref.watch(
      authControllerProvider.select(
        (value) => value.asData?.value?.user.coinBalance ?? 0,
      ),
    );
    final chart = state.context;
    final lockedSections = state.sections
        .where((section) => !controller.isUnlocked(section))
        .toList(growable: false);
    final totalUnlockCost = lockedSections.fold<int>(
      0,
      (total, section) => total + section.coinCost,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF06141F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
            filterQuality: FilterQuality.medium,
          ),
          const ColoredBox(color: Color(0xB0030A12)),
          SafeArea(
            child: chart == null
                ? _MissingChart(onBack: () => context.go(AppRoute.horoscope))
                : CustomScrollView(
                    key: const PageStorageKey('interpretation-scroll'),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          chart: chart,
                          balance: balance,
                          onBack: context.pop,
                          onChangeChart: () => context.go(AppRoute.myCharts),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 110),
                        sliver: SliverList.list(
                          children: [
                            _ModeSwitch(
                              value: state.mode,
                              onChanged: controller.changeMode,
                            ),
                            const SizedBox(height: 10),
                            InterpretationUnlockButton(
                              lockedCount: lockedSections.length,
                              totalCost: totalUnlockCost,
                              isLoading:
                                  state.isLoadingSections ||
                                  state.isLoadingUnlocks,
                              onPressed: () =>
                                  _showUnlockOverview(context, lockedSections),
                            ),
                            const SizedBox(height: 12),
                            InterpretationTabBar(
                              selectedTab: state.selectedTab,
                              onChanged: controller.selectTab,
                            ),
                            const SizedBox(height: 12),
                            if (state.isLoadingChart)
                              const _LoadingCard(
                                message: 'Đang tải dữ liệu lá số...',
                              )
                            else if (state.context!.chartData.isEmpty)
                              _ErrorCard(
                                message:
                                    state.errorMessage ??
                                    'Không tìm thấy dữ liệu chi tiết của lá số.',
                                onRetry: null,
                              )
                            else ...[
                              if (!chart.isSaved)
                                _UnsavedNotice(
                                  saving: state.isSavingChart,
                                  onSave: () => _save(context, ref),
                                ),
                              if (state.errorMessage != null) ...[
                                _ErrorCard(
                                  message: state.errorMessage!,
                                  onRetry: () {
                                    controller.loadSections();
                                    controller.loadUnlocks();
                                    controller.loadInterpretation(force: true);
                                  },
                                ),
                                const SizedBox(height: 10),
                              ],
                              if (state.isLoadingInterpretation &&
                                  state.interpretation == null)
                                const _LoadingCard(
                                  message: 'Đang tải nội dung luận giải...',
                                )
                              else
                                _TabContent(
                                  state: state,
                                  isUnlocked: controller.isUnlocked,
                                  onUnlock: (section) =>
                                      _confirmUnlock(context, ref, section),
                                  onSelectPalace: controller.selectPalace,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showUnlockOverview(
    BuildContext context,
    List<ReadingSection> sections,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF6E5BD),
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Các mục luận giải chưa mở',
                style: TextStyle(
                  color: Color(0xFF553315),
                  fontFamily: 'serif',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (sections.isEmpty)
                const Text('Bạn đã mở toàn bộ nội dung hiện có.')
              else
                ...sections
                    .take(6)
                    .map(
                      (section) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 16,
                              color: Color(0xFF8B5A18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(section.title)),
                            Text('${section.coinCost} Xu'),
                          ],
                        ),
                      ),
                    ),
              if (sections.length > 6)
                Text('Và ${sections.length - 6} mục khác...'),
              const SizedBox(height: 12),
              const Text(
                'Mỗi mục được xác nhận và mở khóa riêng theo giá backend để tránh trừ Xu ngoài ý muốn.',
                style: TextStyle(fontSize: 12, color: Color(0xFF765C39)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(interpretationControllerProvider.notifier)
        .saveCurrentChart();
    if (!context.mounted) return;
    final message = ref.read(interpretationControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Đã lưu lá số. Bạn có thể mở khóa luận giải.'
              : message ?? 'Không thể lưu lá số.',
        ),
      ),
    );
  }

  Future<void> _confirmUnlock(
    BuildContext context,
    WidgetRef ref,
    ReadingSection section,
  ) async {
    final state = ref.read(interpretationControllerProvider);
    if (state.context?.isSaved != true) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFF6E5BD),
          title: const Text('Cần lưu lá số'),
          content: const Text(
            'Backend yêu cầu mã lá số đã lưu để mở khóa nội dung. Bạn có muốn lưu lá số này trước không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Để sau'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu lá số'),
            ),
          ],
        ),
      );
      if (shouldSave == true && context.mounted) await _save(context, ref);
      return;
    }
    final balance =
        ref.read(authControllerProvider).asData?.value?.user.coinBalance ?? 0;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF6E5BD),
        title: Text('Mở khóa ${section.title}?'),
        content: Text(
          'Chi phí do máy chủ xác nhận: ${section.coinCost} Xu.\nSố dư hiện tại: $balance Xu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final result = await ref
        .read(interpretationControllerProvider.notifier)
        .unlock(section);
    if (!context.mounted) return;
    final error = ref.read(interpretationControllerProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? result.wasAlreadyUnlocked
                    ? 'Mục này đã được mở khóa trước đó.'
                    : 'Đã mở khóa ${section.title}.'
              : error ?? 'Không thể mở khóa nội dung.',
        ),
        action: result == null && balance < section.coinCost
            ? SnackBarAction(
                label: 'NẠP XU',
                onPressed: () => context.go(AppRoute.wallet),
              )
            : null,
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.state,
    required this.isUnlocked,
    required this.onUnlock,
    required this.onSelectPalace,
  });

  final InterpretationState state;
  final bool Function(ReadingSection) isUnlocked;
  final ValueChanged<ReadingSection> onUnlock;
  final ValueChanged<String?> onSelectPalace;

  @override
  Widget build(BuildContext context) {
    final data = state.interpretation;
    final sections = _sectionsForTab(state.sections, state.selectedTab);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data != null) ..._contentCards(data, state.selectedTab),
        if (data == null || data.isEmpty)
          const _EmptyCard(
            message: 'Backend chưa trả về nội dung cho chế độ đọc này.',
          ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'CÁC MỤC LUẬN GIẢI',
            style: TextStyle(
              color: Color(0xFFFFD978),
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SectionCard(
                section: section,
                unlocked: isUnlocked(section),
                loading: state.unlockingSectionId == section.id,
                onUnlock: () => onUnlock(section),
              ),
            ),
        ] else if (!state.isLoadingSections)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: _EmptyCard(
              message:
                  'Backend chưa cấu hình danh mục mở khóa cho nhóm nội dung này.',
            ),
          ),
      ],
    );
  }

  List<Widget> _contentCards(
    InterpretationData data,
    InterpretationTab tab,
  ) => switch (tab) {
    InterpretationTab.overview => [
      if (data.aiShortSummary != null)
        _PaperCard(title: 'Tổng quan', content: data.aiShortSummary!),
      if (data.personalityCore != null &&
          _canRead(const ['ban_menh', 'tong_quan', 'cung_menh', 'overview']))
        _PaperCard(
          title: 'Bản mệnh và tính cách',
          content: data.personalityCore!,
        ),
    ],
    InterpretationTab.palaces =>
      data.palaces
          .where(
            (item) => _canRead([
              'cung_${_slug(item.palace.replaceFirst(RegExp(r'^cung\s+', caseSensitive: false), ''))}',
              _slug(item.palace),
            ]),
          )
          .map(
            (item) => _PaperCard(
              title: item.palace,
              subtitle: item.star,
              content: item.summary,
              onTap: () => onSelectPalace(item.palace),
            ),
          )
          .toList(growable: false),
    InterpretationTab.fortunes => [
      if (data.decennialFortune != null &&
          _canRead(const ['dai_van', 'decennial']))
        _PaperCard(title: 'Đại vận', content: data.decennialFortune!),
      if (data.yearlyFortune != null && _canRead(const ['tieu_van', 'yearly']))
        _PaperCard(title: 'Tiểu vận', content: data.yearlyFortune!),
    ],
    InterpretationTab.guidance => [
      if (data.careerFame != null &&
          _canRead(const ['cong_danh', 'quan_loc', 'career']))
        _PaperCard(title: 'Công danh và sự nghiệp', content: data.careerFame!),
      if (data.wealthAccumulation != null &&
          _canRead(const ['tai_loc', 'tai_bach', 'wealth']))
        _PaperCard(title: 'Tài lộc', content: data.wealthAccumulation!),
      if (data.marriageFamily != null &&
          _canRead(const ['hon_nhan', 'phu_the', 'marriage']))
        _PaperCard(
          title: 'Hôn nhân và tình cảm',
          content: data.marriageFamily!,
        ),
      if (data.healthVitality != null &&
          _canRead(const ['suc_khoe', 'tat_ach', 'health']))
        _PaperCard(title: 'Sức khỏe', content: data.healthVitality!),
      if (data.fengshuiAdvice != null &&
          _canRead(const ['phong_thuy', 'fengshui']))
        _PaperCard(title: 'Phong thủy ứng dụng', content: data.fengshuiAdvice!),
    ],
  };

  bool _canRead(List<String> keywords) {
    final matches = state.sections.where((section) {
      final value = _slug(
        '${section.groupSlug} ${section.sectionSlug} ${section.title}',
      );
      return keywords.any((keyword) => value.contains(_slug(keyword)));
    });
    return matches.any(isUnlocked);
  }

  static String _slug(String value) {
    var result = value.trim().toLowerCase();
    const replacements = <String, String>{
      'áàảãạăắằẳẵặâấầẩẫậ': 'a',
      'éèẻẽẹêếềểễệ': 'e',
      'íìỉĩị': 'i',
      'óòỏõọôốồổỗộơớờởỡợ': 'o',
      'úùủũụưứừửữự': 'u',
      'ýỳỷỹỵ': 'y',
      'đ': 'd',
    };
    for (final entry in replacements.entries) {
      for (final character in entry.key.split('')) {
        result = result.replaceAll(character, entry.value);
      }
    }
    return result
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  static List<ReadingSection> _sectionsForTab(
    List<ReadingSection> sections,
    InterpretationTab tab,
  ) {
    bool matches(ReadingSection section) {
      final value = '${section.groupSlug} ${section.sectionSlug}'.toLowerCase();
      return switch (tab) {
        InterpretationTab.overview =>
          value.contains('ban_menh') ||
              value.contains('tong_quan') ||
              value.contains('overview'),
        InterpretationTab.palaces =>
          value.contains('cung') || value.contains('palace'),
        InterpretationTab.fortunes =>
          value.contains('van_han') ||
              value.contains('dai_van') ||
              value.contains('tieu_van') ||
              value.contains('fortune'),
        InterpretationTab.guidance =>
          value.contains('ung_dung') ||
              value.contains('chuyen_de') ||
              value.contains('phong_thuy') ||
              value.contains('career') ||
              value.contains('wealth') ||
              value.contains('health'),
      };
    }

    return sections.where(matches).toList(growable: false);
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.chart,
    required this.balance,
    required this.onBack,
    required this.onChangeChart,
  });
  final InterpretationChartContext chart;
  final int balance;
  final VoidCallback onBack;
  final VoidCallback onChangeChart;

  @override
  Widget build(BuildContext context) {
    final request = chart.request;
    final saved = chart.savedSummary;
    final gender = request?.gender ?? saved?.gender ?? '';
    final age = request == null ? null : DateTime.now().year - request.year;
    final details = [
      if (gender.trim().isNotEmpty) gender,
      if (age != null && age >= 0) '$age tuổi',
    ].join(' • ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 3, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: const Color(0xFFFFD978),
              ),
              const Expanded(
                child: Text(
                  'Luận giải lá số',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFE0A0),
                    fontFamily: 'serif',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$balance Xu',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFFEAC875),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0x448E7339), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 2, 4),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF233947),
                    border: Border.all(color: const Color(0xFFC69A43)),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFFE8D7AD),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chart.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFFFE8B5),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (details.isNotEmpty)
                        Text(
                          details,
                          style: const TextStyle(
                            color: Color(0xFFC8B78E),
                            fontSize: 11.5,
                          ),
                        ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: onChangeChart,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFE3A2),
                    side: const BorderSide(color: Color(0xFFB98A34)),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Đổi lá số',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.value, required this.onChanged});
  final InterpretationMode value;
  final ValueChanged<InterpretationMode> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _ModeCard(
          mode: InterpretationMode.everyday,
          selected: value == InterpretationMode.everyday,
          title: 'BẢN TINH GỌN',
          subtitle: 'Dành cho người mới\nbắt đầu',
          onTap: onChanged,
        ),
      ),
      const SizedBox(width: 9),
      Expanded(
        child: _ModeCard(
          mode: InterpretationMode.deep,
          selected: value == InterpretationMode.deep,
          title: 'BẢN CHUYÊN SÂU',
          subtitle: 'Dành cho người\nbiết về Tử Vi',
          onTap: onChanged,
        ),
      ),
    ],
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final InterpretationMode mode;
  final bool selected;
  final String title;
  final String subtitle;
  final ValueChanged<InterpretationMode> onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xE8082630) : const Color(0xFFF2DFC0),
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: () => onTap(mode),
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 108,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? const Color(0xFFFFD253) : const Color(0xFFC89B55),
            width: selected ? 1.7 : 1.1,
          ),
          boxShadow: selected
              ? const [BoxShadow(color: Color(0x6622D7D0), blurRadius: 12)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFFFE4A0)
                    : const Color(0xFF57391D),
                fontFamily: 'serif',
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected
                    ? const Color(0xFFD4E4DA)
                    : const Color(0xFF6B543B),
                fontSize: 11.5,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PaperCard extends StatelessWidget {
  const _PaperCard({
    required this.title,
    required this.content,
    this.subtitle,
    this.onTap,
  });
  final String title;
  final String content;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Material(
      color: const Color(0xFFF5E4BC),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFC99A42)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF6C3F18),
                  fontFamily: 'serif',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF9A632A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Text(
                content,
                style: const TextStyle(
                  color: Color(0xFF3F3325),
                  fontSize: 13.5,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.unlocked,
    required this.loading,
    required this.onUnlock,
  });
  final ReadingSection section;
  final bool unlocked;
  final bool loading;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: const Color(0xE20A1B27),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF9C7434)),
    ),
    child: Row(
      children: [
        Icon(
          unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
          color: unlocked ? const Color(0xFF69D7A8) : const Color(0xFFFFC963),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  color: Color(0xFFFFE5AD),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (section.subtitle.isNotEmpty)
                Text(
                  section.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBDB091),
                    fontSize: 10.5,
                  ),
                ),
            ],
          ),
        ),
        if (unlocked)
          const Text(
            'ĐÃ MỞ',
            style: TextStyle(
              color: Color(0xFF69D7A8),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          )
        else
          TextButton(
            onPressed: loading ? null : onUnlock,
            child: loading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('${section.coinCost} XU'),
          ),
      ],
    ),
  );
}

class _UnsavedNotice extends StatelessWidget {
  const _UnsavedNotice({required this.saving, required this.onSave});
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xE2382A18),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFB88A3A)),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Lưu lá số để mở khóa các mục luận giải chuyên sâu.',
            style: TextStyle(color: Color(0xFFFFE1A0), fontSize: 11.5),
          ),
        ),
        TextButton(
          onPressed: saving ? null : onSave,
          child: saving
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('LƯU'),
        ),
      ],
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: const Color(0xD00A1B27),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFF9C7434)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(
          dimension: 19,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFFFD978),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFE8D6AC)),
          ),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xDD351822),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFB95757)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFFF9B8F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFFFD3C8)),
          ),
        ),
        if (onRetry != null)
          IconButton(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFFFFD978),
          ),
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xD00A1B27),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFF796032)),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFFBDB091), height: 1.4),
    ),
  );
}

class _MissingChart extends StatelessWidget {
  const _MissingChart({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Chưa có lá số để luận giải.',
          style: TextStyle(color: Color(0xFFFFE4A4)),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onBack, child: const Text('Lập lá số')),
      ],
    ),
  );
}

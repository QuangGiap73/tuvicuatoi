import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_notification_dialog.dart';
import '../../ai_chat/presentation/widgets/chart_picker_dialog.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../domain/generated_overview_section_mapper.dart';
import '../domain/interpretation_models.dart';
import '../domain/interpretation_section_content_resolver.dart';
import '../domain/interpretation_topic_mapper.dart';
import '../domain/section_content.dart';
import 'controllers/interpretation_controller.dart';
import 'state/interpretation_state.dart';
import 'widgets/bundle_unlock_dialog.dart';
import 'widgets/interpretation_section_card.dart';
import 'widgets/interpretation_section_preview.dart';
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
        .where(controller.canPurchase)
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
                          onChangeChart: () =>
                              _changeChart(context, ref, chart.chartId),
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
                                  state.isLoadingUnlocks ||
                                  state.unlockStatusBySection.values.any(
                                    (status) =>
                                        status == UnlockStatus.submitting,
                                  ),
                              onPressed: () => _confirmBundleUnlock(
                                context,
                                ref,
                                lockedSections,
                                totalUnlockCost,
                                balance,
                              ),
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
                            else if (state.context!.chartData.isEmpty &&
                                !state.context!.isSaved)
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
                                  onUnlockGroup: (sections) =>
                                      _confirmBundleUnlock(
                                        context,
                                        ref,
                                        sections,
                                        sections.fold<int>(
                                          0,
                                          (total, section) =>
                                              total + section.coinCost,
                                        ),
                                        balance,
                                      ),
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

  Future<void> _confirmBundleUnlock(
    BuildContext context,
    WidgetRef ref,
    List<ReadingSection> sections,
    int estimatedCost,
    int balance,
  ) async {
    if (sections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn đã mở toàn bộ nội dung hiện có.')),
      );
      return;
    }
    final current = ref.read(interpretationControllerProvider);
    if (current.context?.isSaved != true) {
      await _save(context, ref);
      return;
    }
    final controller = ref.read(interpretationControllerProvider.notifier);
    controller.beginBundleUnlockConfirmation(sections);
    final request = await showBundleUnlockDialog(
      context,
      sectionCount: sections.length,
      estimatedCost: estimatedCost,
      balance: balance,
    );
    if (request == null || !context.mounted) {
      controller.cancelBundleUnlockConfirmation(sections);
      return;
    }
    final result = await controller.unlockBundle(
      sections,
      voucherCode: request.voucherCode,
    );
    if (!context.mounted) return;
    final after = ref.read(interpretationControllerProvider);
    final error = after.unlockError;
    final syncing = sections.any(
      (section) =>
          ref
              .read(interpretationControllerProvider.notifier)
              .statusFor(section) ==
          UnlockStatus.syncing,
    );
    final actualCost = result?.cost ?? estimatedCost;
    final savedCost = result?.saveCost ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          syncing
              ? 'Đã thanh toán, đang đồng bộ quyền đọc.'
              : result == null
              ? error ?? 'Không thể mở trọn gói luận giải.'
              : result.wasAlreadyUnlocked
              ? 'Các mục này đã được mở trước đó.'
              : 'Đã mở ${sections.length} mục với $actualCost Xu'
                    '${savedCost > 0 ? ' (tiết kiệm $savedCost Xu)' : ''}'
                    '${result.balance != null ? '. Số dư: ${result.balance} Xu' : ''}.',
        ),
        action: result == null && balance < estimatedCost
            ? SnackBarAction(
                label: 'NẠP XU',
                onPressed: () => context.go(AppRoute.wallet),
              )
            : null,
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final success = await ref
        .read(interpretationControllerProvider.notifier)
        .saveCurrentChart();
    if (!context.mounted) return;
    final message = ref.read(interpretationControllerProvider).chartError;
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

  Future<void> _changeChart(
    BuildContext context,
    WidgetRef ref,
    String? currentChartId,
  ) async {
    final selected = await showChartPickerDialog(
      context,
      selectedChartId: currentChartId,
    );
    if (selected == null || selected.id == currentChartId || !context.mounted) {
      return;
    }
    ref.read(interpretationControllerProvider.notifier).openSaved(selected);
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
    final unlockController = ref.read(
      interpretationControllerProvider.notifier,
    );
    final currentStatus = unlockController.statusFor(section);
    if (!unlockController.canPurchase(section)) {
      if (currentStatus == UnlockStatus.syncing && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thanh toán, đang đồng bộ quyền đọc.'),
          ),
        );
      }
      return;
    }
    final balance =
        ref.read(authControllerProvider).asData?.value?.user.coinBalance ?? 0;
    final modeName = state.mode == InterpretationMode.everyday
        ? 'Bản Tinh Gọn'
        : 'Bản Chuyên Sâu';
    unlockController.beginUnlockConfirmation(section);
    final confirmed = await MysticNotificationDialog.show<bool>(
      context,
      dialog: MysticNotificationDialog(
        header: 'Mở khóa luận giải',
        title: section.title,
        description: section.subtitle.trim().isNotEmpty
            ? section.subtitle
            : section.summary,
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33D09A2C),
            border: Border.all(color: const Color(0xFFBF8623)),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            color: Color(0xFF9A6416),
            size: 34,
          ),
        ),
        priceLabel: 'Chi phí mở khóa',
        priceText: '${section.coinCost} Xu',
        priceNote: 'Số dư hiện tại: $balance Xu',
        items: [
          MysticNotificationItem('Nội dung này thuộc $modeName'),
          const MysticNotificationItem(
            'Sau khi mở khóa, bạn có thể đọc lại bất kỳ lúc nào trên lá số này.',
            icon: Icons.done_rounded,
            color: Color(0xFF625038),
          ),
        ],
        cancelLabel: 'Hủy',
        confirmLabel: 'Xác nhận mở khóa',
        onConfirm: () => Navigator.pop(context, true),
      ),
    );
    final controller = unlockController;
    if (confirmed != true || !context.mounted) {
      controller.cancelUnlockConfirmation(section);
      return;
    }
    final result = await ref
        .read(interpretationControllerProvider.notifier)
        .unlock(section);
    if (!context.mounted) return;
    final after = ref.read(interpretationControllerProvider);
    final error = after.unlockError;
    final status = controller.statusFor(section);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status == UnlockStatus.syncing
              ? 'Đã thanh toán, đang đồng bộ quyền đọc.'
              : result != null
              ? result.wasAlreadyUnlocked
                    ? 'Mục này đã được mở khóa trước đó.'
                    : 'Đã mở khóa ${section.title} với '
                          '${result.cost ?? section.coinCost} Xu'
                          '${result.balance != null ? '. Số dư: ${result.balance} Xu' : ''}.'
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
    required this.onUnlockGroup,
    required this.onSelectPalace,
  });

  final InterpretationState state;
  final bool Function(ReadingSection) isUnlocked;
  final ValueChanged<ReadingSection> onUnlock;
  final ValueChanged<List<ReadingSection>> onUnlockGroup;
  final ValueChanged<String?> onSelectPalace;
  static const _contentResolver = InterpretationSectionContentResolver();

  @override
  Widget build(BuildContext context) {
    final data = state.interpretation;
    final sections = _sectionsForTab(state.sections, state.selectedTab);
    final lockedSections = sections
        .where((section) {
          final status = _statusForSection(section);
          return !_canRead(section) &&
              status != UnlockStatus.confirming &&
              status != UnlockStatus.submitting &&
              status != UnlockStatus.syncing;
        })
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data == null || data.isEmpty)
          const _EmptyCard(
            message: 'Backend chưa trả về nội dung cho chế độ đọc này.',
          ),
        if (sections.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'CÁC MỤC LUẬN GIẢI',
                  style: TextStyle(
                    color: Color(0xFFFFD978),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
              ),
              if (lockedSections.isNotEmpty)
                TextButton.icon(
                  onPressed:
                      state.unlockStatusBySection.values.any(
                        (status) =>
                            status == UnlockStatus.confirming ||
                            status == UnlockStatus.submitting,
                      )
                      ? null
                      : () => onUnlockGroup(lockedSections),
                  icon: const Icon(Icons.lock_open_rounded, size: 14),
                  label: Text(
                    'MỞ FULL (${lockedSections.fold<int>(0, (total, section) => total + section.coinCost)} XU)',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD978),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          for (final section in sections)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InterpretationSectionCard(
                section: section,
                isUnlocked: _canRead(section),
                unlockStatus: _statusForSection(section),
                isSharedContent:
                    _resolveContent(section).source !=
                        ContentSource.generatedInterpretation &&
                    InterpretationTopicMapper.topicFor(section) != null,
                onOpen: () => showInterpretationSectionPreview(
                  context,
                  section: section,
                  content: _resolveContent(section),
                  isUnlocked: _canRead(section),
                  topic:
                      _canRead(section) &&
                          _resolveContent(section).source !=
                              ContentSource.generatedInterpretation
                      ? InterpretationTopicMapper.topicFor(section)
                      : null,
                  isSharedContent:
                      _resolveContent(section).source !=
                          ContentSource.generatedInterpretation &&
                      InterpretationTopicMapper.topicFor(section) != null,
                  onUnlock: () => onUnlock(section),
                ),
                onUnlock: () => onUnlock(section),
              ),
            ),
          if (state.selectedTab == InterpretationTab.overview)
            ..._generatedOverviewCards(context),
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

  UnlockStatus _statusForSection(ReadingSection section) {
    if (_serverUnlockFor(section) == false && isUnlocked(section)) {
      return UnlockStatus.syncing;
    }
    if (_canRead(section)) return UnlockStatus.unlocked;
    final chartId = state.context?.chartId;
    if (chartId == null) return UnlockStatus.idle;
    final key = ReadingSectionKey(
      chartId: chartId,
      mode: state.mode,
      groupSlug: section.groupSlug,
      sectionSlug: section.sectionSlug,
    );
    return state.unlockStatusBySection[key.value] ?? UnlockStatus.idle;
  }

  SectionContent _resolveContent(ReadingSection section) =>
      _contentResolver.resolve(
        section: section,
        interpretation: state.interpretation ?? const InterpretationData(),
        chartData: state.context?.chartData ?? const {},
      );

  bool _canRead(ReadingSection section) {
    final serverValue = _serverUnlockFor(section);
    return serverValue ?? isUnlocked(section);
  }

  bool? _serverUnlockFor(ReadingSection section) {
    final interpretation = state.interpretation;
    if (interpretation == null) return null;
    for (final generated in interpretation.overviewSections) {
      final mapped = GeneratedOverviewSectionMapper.toSection(generated);
      if (mapped?.sectionSlug == section.sectionSlug) {
        return generated.isUnlocked;
      }
    }
    const palaceBySlug = <String, String>{
      'cung_menh': 'Mệnh',
      'cung_phu_mau': 'Phụ Mẫu',
      'cung_phu_the': 'Phu Thê',
      'cung_quan_loc': 'Quan Lộc',
      'cung_tai_bach': 'Tài Bạch',
      'cung_tat_ach': 'Tật Ách',
      'cung_dien_trach': 'Điền Trạch',
    };
    final palaceName = palaceBySlug[section.sectionSlug];
    if (palaceName != null) {
      for (final palace in interpretation.palaceReadingSections) {
        final title = palace.title.toLowerCase();
        if (title == palaceName.toLowerCase() ||
            title == 'cung ${palaceName.toLowerCase()}') {
          return palace.isUnlocked;
        }
      }
    }
    final timingSection = switch (section.sectionSlug) {
      'dai_van_10_nam' => interpretation.timing.daiVan,
      'tieu_han_nam_nay' => interpretation.timing.tieuVan,
      _ => null,
    };
    if (timingSection != null) return timingSection.isUnlocked;
    if (section.sectionSlug == 'phong_thuy_ung_dung' &&
        interpretation.guidanceSections.isNotEmpty) {
      return interpretation.guidanceSections.every((item) => item.isUnlocked);
    }
    return null;
  }

  List<Widget> _generatedOverviewCards(BuildContext context) {
    final interpretation = state.interpretation;
    if (interpretation == null) return const [];
    final configuredSlugs = state.sections
        .where((section) => section.groupSlug == 'tong_quan_ban_menh')
        .map((section) => section.sectionSlug)
        .toSet();
    final cards = <Widget>[];
    for (final generated in interpretation.overviewSections) {
      final section = GeneratedOverviewSectionMapper.toSection(generated);
      if (section == null || configuredSlugs.contains(section.sectionSlug)) {
        continue;
      }
      final unlocked = generated.isUnlocked;
      final content = SectionContent(
        preview: section.subtitle,
        fullContent: generated.fullText.trim().isEmpty
            ? null
            : generated.fullText.trim(),
        source: ContentSource.generatedInterpretation,
        isFallback: false,
      );
      cards.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InterpretationSectionCard(
            section: section,
            isUnlocked: unlocked,
            unlockStatus: unlocked ? UnlockStatus.unlocked : UnlockStatus.idle,
            canUnlock: false,
            onOpen: () => showInterpretationSectionPreview(
              context,
              section: section,
              content: content,
              isUnlocked: unlocked,
              canUnlock: false,
              onUnlock: () {},
            ),
            onUnlock: () {},
          ),
        ),
      );
    }
    return cards;
  }

  // Kept temporarily while the backend catalog is being aligned with Web.
  // ignore: unused_element
  List<Widget> _contentCards(BuildContext context, InterpretationTab tab) =>
      switch (tab) {
        InterpretationTab.overview => [
          ..._paperFor(
            context,
            groupSlug: 'tong_quan_ban_menh',
            sectionSlug: 'tong_quan_nhan_sinh',
            title: 'Tổng quan nhân sinh',
          ),
          ..._paperFor(
            context,
            groupSlug: 'tong_quan_ban_menh',
            sectionSlug: 'ban_menh_va_than',
            title: 'Bản mệnh và tính cách',
          ),
          ..._paperFor(
            context,
            groupSlug: 'tong_quan_ban_menh',
            sectionSlug: 'am_duong_ngu_hanh',
            title: 'Âm dương ngũ hành',
          ),
        ],
        InterpretationTab.palaces => [
          for (final entry in const <String, String>{
            'cung_menh': 'Cung Mệnh',
            'cung_phu_mau': 'Cung Phụ Mẫu',
            'cung_phu_the': 'Cung Phu Thê',
            'cung_quan_loc': 'Cung Quan Lộc',
            'cung_tai_bach': 'Cung Tài Bạch',
            'cung_tat_ach': 'Cung Tật Ách',
            'cung_dien_trach': 'Cung Điền Trạch',
          }.entries)
            ..._paperFor(
              context,
              groupSlug: 'chi_tiet_12_cung',
              sectionSlug: entry.key,
              title: entry.value,
              palaceName: entry.value,
            ),
        ],
        InterpretationTab.fortunes => [
          ..._paperFor(
            context,
            groupSlug: 'dai_van_tieu_han',
            sectionSlug: 'dai_van_10_nam',
            title: 'Đại vận',
          ),
          ..._paperFor(
            context,
            groupSlug: 'dai_van_tieu_han',
            sectionSlug: 'tieu_han_nam_nay',
            title: 'Tiểu hạn năm nay',
          ),
          ..._paperFor(
            context,
            groupSlug: 'dai_van_tieu_han',
            sectionSlug: 'luu_nien_5_nam',
            title: 'Lưu niên 5 năm',
          ),
        ],
        InterpretationTab.guidance => [
          ..._paperFor(
            context,
            groupSlug: 'goi_y_ung_dung',
            sectionSlug: 'phong_thuy_ung_dung',
            title: 'Phong thủy ứng dụng',
          ),
          ..._paperFor(
            context,
            groupSlug: 'goi_y_ung_dung',
            sectionSlug: 'loi_khuyen_nghe_nghiep',
            title: 'Lời khuyên nghề nghiệp',
          ),
          ..._paperFor(
            context,
            groupSlug: 'goi_y_ung_dung',
            sectionSlug: 'tuong_hop_nhan_duyen',
            title: 'Tương hợp nhân duyên',
          ),
        ],
      };

  List<Widget> _paperFor(
    BuildContext context, {
    required String groupSlug,
    required String sectionSlug,
    required String title,
    String? palaceName,
  }) {
    final section = state.sections.cast<ReadingSection?>().firstWhere(
      (item) =>
          item?.groupSlug == groupSlug && item?.sectionSlug == sectionSlug,
      orElse: () => null,
    );
    if (section == null) return const [];
    final canReadFull = section.isPublicOverview || isUnlocked(section);
    if (!canReadFull) return const [];
    final content = _resolveContent(section);
    if (content.displayContent.isEmpty) return const [];
    return [
      _PaperCard(
        title: title,
        content: content.displayContent,
        onTap: () {
          if (palaceName != null) onSelectPalace(palaceName);
          showInterpretationSectionPreview(
            context,
            section: section,
            content: content,
            isUnlocked: true,
            topic: InterpretationTopicMapper.topicFor(section),
            onUnlock: () => onUnlock(section),
          );
        },
      ),
    ];
  }

  static List<ReadingSection> _sectionsForTab(
    List<ReadingSection> sections,
    InterpretationTab tab,
  ) => sections
      .where((section) => _tabForSection(section) == tab)
      .toList(growable: false);

  static InterpretationTab _tabForSection(ReadingSection section) {
    return switch (section.groupSlug) {
      'chi_tiet_12_cung' => InterpretationTab.palaces,
      'dai_van_tieu_han' => InterpretationTab.fortunes,
      'goi_y_ung_dung' => InterpretationTab.guidance,
      _ => InterpretationTab.overview,
    };
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
  const _PaperCard({required this.title, required this.content, this.onTap});
  final String title;
  final String content;
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

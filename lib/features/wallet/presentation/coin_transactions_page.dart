import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/assets/mystic_assets.dart';
import '../../../core/widgets/mystic_scaffold.dart';
import '../domain/wallet_models.dart';
import 'transaction_history_controller.dart';

const _gold = Color(0xFFE5BA50);
const _paper = Color(0xFFF7E8C2);

class CoinTransactionsPage extends ConsumerStatefulWidget {
  const CoinTransactionsPage({super.key});
  @override
  ConsumerState<CoinTransactionsPage> createState() =>
      _CoinTransactionsPageState();
}

class _CoinTransactionsPageState extends ConsumerState<CoinTransactionsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    Future.microtask(
      ref.read(transactionHistoryControllerProvider.notifier).refreshIfStale,
    );
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 280) {
      ref.read(transactionHistoryControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionHistoryControllerProvider);
    return MysticScaffold(
      constrainBody: false,
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            MysticAssets.homeBackground,
            fit: BoxFit.cover,
            cacheWidth:
                (MediaQuery.sizeOf(context).width *
                        MediaQuery.devicePixelRatioOf(context))
                    .round(),
          ),
          const ColoredBox(color: Color(0xBC04101E)),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: ref
            .read(transactionHistoryControllerProvider.notifier)
            .refresh,
        child: CustomScrollView(
          key: const PageStorageKey<String>('coin-transaction-history'),
          controller: _scrollController,
          slivers: [
            const SliverToBoxAdapter(child: _HistoryHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
              sliver: SliverList.list(
                children: [
                  RepaintBoundary(child: _SummaryPanel(state: state)),
                  const SizedBox(height: 13),
                  RepaintBoundary(child: _FilterBar(state: state)),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            if (state.isLoading && state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(color: _gold)),
              )
            else if (state.error != null && state.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(message: state.error!),
              )
            else if (state.items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'Chưa có biến động Xu trong mục này.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                sliver: SliverList.builder(
                  itemCount:
                      state.items.length +
                      (state.isLoadingMore || state.error != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.items.length) {
                      return _ListFooter(state: state);
                    }
                    final item = state.items[index];
                    final previous = index == 0 ? null : state.items[index - 1];
                    final showDate =
                        index == 0 || _dateGroup(item) != _dateGroup(previous!);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate) _DateHeading(label: _dateGroup(item)),
                        RepaintBoundary(child: _TransactionTile(item: item)),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: const Color(0xB20A1623),
              shape: BoxShape.circle,
              border: Border.all(color: _gold),
            ),
            child: const Icon(Icons.chevron_left, color: Color(0xFFFFDD77)),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            children: [
              SizedBox(
                height: 30,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Nhật Ký Biến Động Xu',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFE39A),
                      fontFamily: 'serif',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Lịch sử nhận thưởng, nạp Xu và mở khóa',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: 9.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SizedBox(width: 39),
      ],
    ),
  );
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.state});
  final TransactionHistoryState state;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: _paper,
      border: Border.all(color: _gold, width: 1.4),
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
    ),
    child: Row(
      children: [
        Expanded(
          child: _SummaryItem(
            icon: Icons.south_rounded,
            label: 'TỔNG ĐÃ NHẬN',
            value: '+${_number(state.totalEarned)}',
            color: const Color(0xFF08765D),
          ),
        ),
        const _SummaryDivider(),
        Expanded(
          child: _SummaryItem(
            icon: Icons.north_rounded,
            label: 'TỔNG ĐÃ DÙNG',
            value: '-${_number(state.totalSpent.abs())}',
            color: const Color(0xFFB3264A),
          ),
        ),
        const _SummaryDivider(),
        Expanded(
          child: _SummaryItem(
            icon: Icons.monetization_on_outlined,
            label: 'SỐ DƯ',
            value: state.balance == null ? '—' : _number(state.balance!),
            color: const Color(0xFF3F2916),
          ),
        ),
      ],
    ),
  );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 3),
    child: Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 7),
        FittedBox(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF624A2D),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          child: Text(
            '$value Xu',
            style: TextStyle(
              color: color,
              fontFamily: 'serif',
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 80, color: const Color(0x99B88A34));
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.state});
  final TransactionHistoryState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: const Color(0xE3091727),
      border: Border.all(color: const Color(0xFF9A721F)),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Row(
      children: [
        _FilterButton(
          label: 'Tất cả (${state.total})',
          icon: Icons.list_alt,
          selected: state.filter == TransactionFilter.all,
          onTap: () => ref
              .read(transactionHistoryControllerProvider.notifier)
              .selectFilter(TransactionFilter.all),
        ),
        _FilterButton(
          label: 'Cộng',
          icon: Icons.arrow_upward,
          selected: state.filter == TransactionFilter.plus,
          accent: const Color(0xFF12D7A5),
          onTap: () => ref
              .read(transactionHistoryControllerProvider.notifier)
              .selectFilter(TransactionFilter.plus),
        ),
        _FilterButton(
          label: 'Đã dùng',
          icon: Icons.arrow_downward,
          selected: state.filter == TransactionFilter.minus,
          accent: const Color(0xFFFF6687),
          onTap: () => ref
              .read(transactionHistoryControllerProvider.notifier)
              .selectFilter(TransactionFilter.minus),
        ),
      ],
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accent = _gold,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: selected ? const Color(0xFFFFD86D) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: selected ? const Color(0xFF3D290E) : accent,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF3D290E)
                          : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _DateHeading extends StatelessWidget {
  const _DateHeading({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const Positioned(
        left: 16,
        top: 0,
        bottom: 0,
        child: ColoredBox(color: Color(0xFFAD8A36), child: SizedBox(width: 2)),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(42, 8, 0, 10),
        child: Row(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFFFD977),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(color: Color(0x998E691F))),
          ],
        ),
      ),
    ],
  );
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});
  final CoinTransaction item;
  @override
  Widget build(BuildContext context) {
    final plus = item.amount >= 0;
    final color = plus ? const Color(0xFF22DBB3) : const Color(0xFFFF7795);
    return Stack(
      children: [
        const Positioned(
          left: 16,
          top: 0,
          bottom: 0,
          child: ColoredBox(
            color: Color(0xFFAD8A36),
            child: SizedBox(width: 2),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 34,
              height: 100,
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 43,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B1725),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: plus ? _gold : Colors.white60,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 91),
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xEE091625),
                  border: Border.all(color: const Color(0xFF8F6B27)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: const Color(0xFF102034),
                        border: Border.all(color: _gold),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _transactionIcon(item),
                        color: const Color(0xFFFFDA70),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF4E7D0),
                              fontFamily: 'serif',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 7,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                _time(item),
                                style: const TextStyle(
                                  color: Color(0xFFFFD76D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.typeDisplay.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF173D53),
                                    border: Border.all(
                                      color: const Color(0xFF3FA6C9),
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.typeDisplay,
                                    style: const TextStyle(
                                      color: Color(0xFF9FE8FF),
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              if (item.balanceAfter != null)
                                Text(
                                  'Số dư: ${_number(item.balanceAfter!)} Xu',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 9.5,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${plus ? '+' : ''}${_number(item.amount)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Xu',
                          style: TextStyle(color: Colors.white60, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ListFooter extends ConsumerWidget {
  const _ListFooter({required this.state});
  final TransactionHistoryState state;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Padding(
    padding: const EdgeInsets.all(18),
    child: Center(
      child: state.isLoadingMore
          ? const CircularProgressIndicator(color: _gold)
          : TextButton(
              onPressed: ref
                  .read(transactionHistoryControllerProvider.notifier)
                  .loadMore,
              child: Text(state.error ?? 'Tải thêm'),
            ),
    ),
  );
}

class _ErrorState extends ConsumerWidget {
  const _ErrorState({required this.message});
  final String message;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, style: const TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: ref
              .read(transactionHistoryControllerProvider.notifier)
              .refresh,
          child: const Text('Thử lại'),
        ),
      ],
    ),
  );
}

String _dateGroup(CoinTransaction item) {
  if (item.dateLabel.trim().isNotEmpty) return item.dateLabel.trim();
  final date = item.createdAt?.toLocal();
  if (date == null) return 'Không rõ ngày';
  return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
}

String _time(CoinTransaction item) {
  if (item.time.trim().isNotEmpty) return item.time.trim();
  final date = item.createdAt?.toLocal();
  if (date == null) return '--:--';
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

IconData _transactionIcon(CoinTransaction item) {
  final value = '${item.typeDisplay} ${item.description}'.toLowerCase();
  if (value.contains('điểm danh')) return Icons.calendar_month_rounded;
  if (value.contains('luận giải') || value.contains('mở khóa')) {
    return Icons.lock_rounded;
  }
  if (value.contains('lưu lá số')) return Icons.description_rounded;
  if (item.amount >= 0) return Icons.card_giftcard_rounded;
  return Icons.monetization_on_rounded;
}

String _number(int value) {
  final text = value.abs().toString();
  final output = StringBuffer();
  for (var index = 0; index < text.length; index++) {
    if (index > 0 && (text.length - index) % 3 == 0) output.write('.');
    output.write(text[index]);
  }
  return '${value < 0 ? '-' : ''}$output';
}

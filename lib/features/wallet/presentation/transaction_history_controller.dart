import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/wallet_repository.dart';
import '../domain/wallet_models.dart';

enum TransactionFilter {
  all('ALL'),
  plus('PLUS'),
  minus('MINUS');

  const TransactionFilter(this.apiValue);
  final String apiValue;
}

class TransactionHistoryState {
  const TransactionHistoryState({
    this.items = const [],
    this.filter = TransactionFilter.all,
    this.total = 0,
    this.balance,
    this.totalEarned = 0,
    this.totalSpent = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });
  final List<CoinTransaction> items;
  final TransactionFilter filter;
  final int total;
  final int? balance;
  final int totalEarned;
  final int totalSpent;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  TransactionHistoryState copyWith({
    List<CoinTransaction>? items,
    TransactionFilter? filter,
    int? total,
    int? balance,
    int? totalEarned,
    int? totalSpent,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) => TransactionHistoryState(
    items: items ?? this.items,
    filter: filter ?? this.filter,
    total: total ?? this.total,
    balance: balance ?? this.balance,
    totalEarned: totalEarned ?? this.totalEarned,
    totalSpent: totalSpent ?? this.totalSpent,
    hasMore: hasMore ?? this.hasMore,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: clearError ? null : error ?? this.error,
  );
}

class TransactionHistoryController extends Notifier<TransactionHistoryState> {
  static const _pageSize = 30;
  static const _cacheTtl = Duration(seconds: 30);
  CancelToken? _token;
  int _session = 0;
  final Map<TransactionFilter, TransactionHistoryState> _filterCache = {};
  final Map<TransactionFilter, DateTime> _loadedAt = {};

  @override
  TransactionHistoryState build() {
    ref.onDispose(() => _token?.cancel());
    Future.microtask(refresh);
    return const TransactionHistoryState(isLoading: true);
  }

  Future<void> refresh() => _load(reset: true);

  Future<void> refreshIfStale() async {
    if (state.isLoading || state.isLoadingMore) return;
    final loadedAt = _loadedAt[state.filter];
    if (loadedAt == null || DateTime.now().difference(loadedAt) > _cacheTtl) {
      await _load(reset: true);
    }
  }

  Future<void> selectFilter(TransactionFilter filter) async {
    if (filter == state.filter || state.isLoading) return;
    final cached = _filterCache[filter];
    if (cached != null) {
      state = cached;
      await refreshIfStale();
      return;
    }
    state = TransactionHistoryState(filter: filter, isLoading: true);
    await _load(reset: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    final session = reset ? ++_session : _session;
    if (reset) {
      _token?.cancel('Tải lại lịch sử Xu');
      state = state.copyWith(isLoading: true, clearError: true);
    } else {
      state = state.copyWith(isLoadingMore: true, clearError: true);
    }
    final token = CancelToken();
    _token = token;
    try {
      final page = await ref
          .read(walletRepositoryProvider)
          .getTransactions(
            filter: state.filter.apiValue,
            limit: _pageSize,
            offset: reset ? 0 : state.items.length,
            cancelToken: token,
          );
      if (token.isCancelled || session != _session) return;
      final items = reset ? page.items : [...state.items, ...page.items];
      state = state.copyWith(
        items: List.unmodifiable(items),
        total: page.total,
        balance: page.balance,
        totalEarned: page.totalEarned,
        totalSpent: page.totalSpent,
        hasMore: page.hasMore,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
      _filterCache[state.filter] = state;
      _loadedAt[state.filter] = DateTime.now();
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      _fail(error.message ?? 'Không thể tải lịch sử Xu.');
    } on WalletException catch (error) {
      _fail(error.message);
    }
  }

  void _fail(String message) {
    state = state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      error: message,
    );
  }
}

final transactionHistoryControllerProvider =
    NotifierProvider<TransactionHistoryController, TransactionHistoryState>(
      TransactionHistoryController.new,
    );

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/wallet_repository.dart';
import '../../domain/wallet_models.dart';
import '../state/top_up_state.dart';

class TopUpController extends Notifier<TopUpState> {
  CancelToken? _loadToken;
  CancelToken? _orderToken;

  @override
  TopUpState build() {
    ref.onDispose(() {
      _loadToken?.cancel();
      _orderToken?.cancel();
    });
    Future.microtask(load);
    return const TopUpState(isLoading: true);
  }

  void selectTab(TopUpTab tab) {
    if (tab == state.selectedTab) return;
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> load() async {
    if (state.isLoading && state.coinPackages.isNotEmpty) return;
    _loadToken?.cancel('Tải lại danh sách gói');
    final token = CancelToken();
    _loadToken = token;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repository = ref.read(walletRepositoryProvider);
      final coinFuture = repository.getPackages(cancelToken: token);
      final membershipFuture = repository.getMembershipPackages(
        cancelToken: token,
      );
      final coinPackages = await coinFuture;
      final memberships = await membershipFuture;
      if (token.isCancelled) return;
      state = state.copyWith(
        coinPackages: coinPackages,
        memberships: memberships,
        isLoading: false,
        clearError: true,
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      state = state.copyWith(isLoading: false, error: error.message);
    } on WalletException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }

  Future<PaymentOrderResult?> createOrder({
    required String productId,
    required String productType,
  }) async {
    if (state.creatingProductId != null) return null;
    _orderToken?.cancel();
    final token = CancelToken();
    _orderToken = token;
    state = state.copyWith(creatingProductId: productId, clearError: true);
    try {
      return await ref
          .read(walletRepositoryProvider)
          .createOrder(
            productId: productId,
            productType: productType,
            cancelToken: token,
          );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      state = state.copyWith(error: error.message);
      return null;
    } on WalletException catch (error) {
      state = state.copyWith(error: error.message);
      return null;
    } finally {
      if (!token.isCancelled) state = state.copyWith(clearCreating: true);
    }
  }
}

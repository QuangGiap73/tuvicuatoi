import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_models.dart';
import '../state/payment_order_state.dart';

class PaymentOrderController extends Notifier<PaymentOrderState> {
  CancelToken? _token;

  @override
  PaymentOrderState build() {
    ref.onDispose(() => _token?.cancel());
    return const PaymentOrderState();
  }

  void track(PaymentOrderResult result) {
    _token?.cancel();
    state = PaymentOrderState(
      activeOrderId: result.orderId,
      order: result.order,
    );
  }

  Future<PaymentOrder?> check() async {
    final orderId = state.activeOrderId;
    if (orderId == null || orderId.isEmpty || state.isChecking) {
      return state.order;
    }
    _token?.cancel();
    final token = CancelToken();
    _token = token;
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final order = await ref
          .read(walletRepositoryProvider)
          .getOrder(orderId: orderId, cancelToken: token);
      if (token.isCancelled) return null;
      state = state.copyWith(order: order, isChecking: false);
      if (order.isSuccess) {
        try {
          await ref.read(authControllerProvider.notifier).refreshProfile();
        } catch (_) {
          // Payment is already confirmed; a profile refresh failure must not
          // turn the completed order back into a failed payment.
        }
      }
      return order;
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return null;
      state = state.copyWith(isChecking: false, error: error.message);
      return null;
    } on WalletException catch (error) {
      state = state.copyWith(isChecking: false, error: error.message);
      return null;
    }
  }

  void clear() {
    _token?.cancel();
    state = const PaymentOrderState();
  }
}

class PaymentOrdersController extends Notifier<PaymentOrdersState> {
  CancelToken? _token;

  @override
  PaymentOrdersState build() {
    ref.onDispose(() => _token?.cancel());
    return const PaymentOrdersState();
  }

  Future<void> load({bool force = false}) async {
    if (state.isLoading || (!force && state.isFresh)) return;
    _token?.cancel();
    final token = CancelToken();
    _token = token;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await ref
          .read(walletRepositoryProvider)
          .getMyOrders(cancelToken: token);
      if (token.isCancelled) return;
      state = state.copyWith(
        orders: orders,
        isLoading: false,
        fetchedAt: DateTime.now(),
      );
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) return;
      state = state.copyWith(isLoading: false, error: error.message);
    } on WalletException catch (error) {
      state = state.copyWith(isLoading: false, error: error.message);
    }
  }
}

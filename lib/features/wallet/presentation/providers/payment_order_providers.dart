import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/wallet_repository.dart';
import '../../domain/wallet_models.dart';
import '../controllers/payment_order_controller.dart';
import '../state/payment_order_state.dart';

final paymentOrderControllerProvider =
    NotifierProvider<PaymentOrderController, PaymentOrderState>(
      PaymentOrderController.new,
    );

final paymentOrdersControllerProvider =
    NotifierProvider<PaymentOrdersController, PaymentOrdersState>(
      PaymentOrdersController.new,
    );

final paymentOrderDetailProvider = FutureProvider.autoDispose
    .family<PaymentOrder, String>((ref, orderId) async {
      ref.watch(authSessionUserIdProvider);
      final token = CancelToken();
      ref.onDispose(() => token.cancel('Màn hình chi tiết đơn đã đóng'));
      return ref
          .read(walletRepositoryProvider)
          .getOrder(orderId: orderId, cancelToken: token);
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';

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

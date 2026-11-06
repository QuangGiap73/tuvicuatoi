import '../../domain/wallet_models.dart';

class PaymentOrderState {
  const PaymentOrderState({
    this.activeOrderId,
    this.order,
    this.checkoutUrl = '',
    this.qrCode = '',
    this.isChecking = false,
    this.error,
  });

  final String? activeOrderId;
  final PaymentOrder? order;
  final String checkoutUrl;
  final String qrCode;
  final bool isChecking;
  final String? error;

  PaymentOrderState copyWith({
    String? activeOrderId,
    PaymentOrder? order,
    String? checkoutUrl,
    String? qrCode,
    bool? isChecking,
    String? error,
    bool clearError = false,
    bool clearActive = false,
  }) => PaymentOrderState(
    activeOrderId: clearActive ? null : activeOrderId ?? this.activeOrderId,
    order: clearActive ? null : order ?? this.order,
    checkoutUrl: clearActive ? '' : checkoutUrl ?? this.checkoutUrl,
    qrCode: clearActive ? '' : qrCode ?? this.qrCode,
    isChecking: isChecking ?? this.isChecking,
    error: clearError ? null : error ?? this.error,
  );
}

class PaymentOrdersState {
  const PaymentOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.fetchedAt,
  });

  final List<PaymentOrder> orders;
  final bool isLoading;
  final String? error;
  final DateTime? fetchedAt;

  bool get isFresh =>
      fetchedAt != null && DateTime.now().difference(fetchedAt!).inSeconds < 30;

  PaymentOrdersState copyWith({
    List<PaymentOrder>? orders,
    bool? isLoading,
    String? error,
    DateTime? fetchedAt,
    bool clearError = false,
  }) => PaymentOrdersState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
}

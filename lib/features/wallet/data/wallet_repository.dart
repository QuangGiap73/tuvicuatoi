import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../domain/wallet_models.dart';

class WalletException implements Exception {
  const WalletException(this.message);
  final String message;

  @override
  String toString() => message;
}

class WalletRepository {
  WalletRepository(this._dio);
  final Dio _dio;

  Future<EarnCoinsInfo> getInfo({CancelToken? cancelToken}) async {
    final body = await _get('/monetization/earn-coins/info/', cancelToken);
    return EarnCoinsInfo.fromJson(body);
  }

  Future<CoinTransactionPage> getTransactions({
    String filter = 'ALL',
    int limit = 30,
    int offset = 0,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        '/monetization/transactions/',
        queryParameters: {'filter': filter, 'limit': limit, 'offset': offset},
        cancelToken: cancelToken,
      );
      return CoinTransactionPage.fromJson(_body(response.data));
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw WalletException(
        _message(error.response?.data) ?? error.userMessage,
      );
    }
  }

  Future<List<CoinPackage>> getPackages({CancelToken? cancelToken}) async {
    final body = await _get('/monetization/coin-packages/', cancelToken);
    return _maps(body['coinPackages'])
        .map(CoinPackage.fromJson)
        .where(
          (item) => item.id.isNotEmpty && item.totalCoins > 0 && item.price > 0,
        )
        .toList();
  }

  Future<List<MembershipPackage>> getMembershipPackages({
    CancelToken? cancelToken,
  }) async {
    final body = await _get('/monetization/packages/', cancelToken);
    final items =
        _maps(body['packages'])
            .map(MembershipPackage.fromJson)
            .where((item) => item.id.isNotEmpty)
            .toList()
          ..sort((left, right) => left.price.compareTo(right.price));
    return items;
  }

  Future<PaymentOrderResult> createOrder({
    required String productId,
    required String productType,
    String? voucherCode,
    CancelToken? cancelToken,
  }) async {
    final body = await _post('/monetization/create-order/', {
      'productId': productId,
      'productType': productType,
      if (voucherCode != null && voucherCode.trim().isNotEmpty)
        'voucherCode': voucherCode.trim(),
    }, cancelToken);
    final order = body['order'] is Map
        ? Map<String, dynamic>.from(body['order'] as Map)
        : const <String, dynamic>{};
    final checkoutUrl = body['checkoutUrl']?.toString() ?? '';
    if (checkoutUrl.isEmpty) {
      throw const WalletException('Máy chủ chưa trả về liên kết thanh toán.');
    }
    return PaymentOrderResult(
      checkoutUrl: checkoutUrl,
      orderId: order['id']?.toString() ?? '',
      order: PaymentOrder.fromJson(order),
      qrCode: body['qrCode']?.toString() ?? '',
    );
  }

  Future<PaymentOrder> getOrder({
    required String orderId,
    CancelToken? cancelToken,
  }) async {
    final body = await _get('/monetization/orders/$orderId/', cancelToken);
    final raw = body['order'];
    if (raw is! Map) {
      throw const WalletException('Máy chủ chưa trả về trạng thái đơn hàng.');
    }
    final user = body['user'] is Map
        ? Map<String, dynamic>.from(body['user'] as Map)
        : const <String, dynamic>{};
    return PaymentOrder.fromJson({
      ...Map<String, dynamic>.from(raw),
      if (raw['coinBalance'] == null && user['coinBalance'] != null)
        'coinBalance': user['coinBalance'],
    });
  }

  Future<List<PaymentOrder>> getMyOrders({CancelToken? cancelToken}) async {
    final body = await _get('/monetization/my-orders/', cancelToken);
    final orders =
        _maps(body['orders'])
            .map(PaymentOrder.fromJson)
            .where((order) => order.id.isNotEmpty)
            .toList(growable: false)
          ..sort((left, right) {
            final leftDate =
                left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final rightDate =
                right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return rightDate.compareTo(leftDate);
          });
    return List.unmodifiable(orders);
  }

  Future<VoucherValidationResult> validateVoucher({
    required String code,
    required String featureKey,
    required double originalCost,
    CancelToken? cancelToken,
  }) async {
    final body = await _post('/monetization/vouchers/validate/', {
      'code': code.trim(),
      'featureKey': featureKey,
      'originalCost': originalCost.round(),
    }, cancelToken);
    final raw = body['voucher'];
    if (raw is! Map) {
      throw const WalletException('Máy chủ chưa trả về thông tin voucher.');
    }
    final result = VoucherValidationResult.fromJson(
      Map<String, dynamic>.from(raw),
    );
    if (result.code.isEmpty) {
      throw const WalletException('Thông tin voucher không hợp lệ.');
    }
    return result;
  }

  Future<Map<String, dynamic>> checkIn({CancelToken? cancelToken}) =>
      _post('/monetization/earn-coins/checkin/', const {}, cancelToken);

  Future<Map<String, dynamic>> startMission(
    String code, {
    CancelToken? cancelToken,
  }) => _post('/monetization/earn-coins/start-mission/', {
    'missionCode': code,
  }, cancelToken);

  Future<Map<String, dynamic>> claimMission(
    String code, {
    CancelToken? cancelToken,
  }) => _post('/monetization/earn-coins/claim-mission/', {
    'missionCode': code,
  }, cancelToken);

  Future<void> recordChartCreation({CancelToken? cancelToken}) async {
    await _post(
      '/monetization/earn-coins/record-chart-creation/',
      const {},
      cancelToken,
    );
  }

  Future<void> recordMissionAction(
    String code, {
    CancelToken? cancelToken,
  }) async {
    await _post('/monetization/earn-coins/record-mission-action/', {
      'missionCode': code,
    }, cancelToken);
  }

  Future<Map<String, dynamic>> _get(String path, CancelToken? token) async {
    try {
      final response = await _dio.get<Object?>(path, cancelToken: token);
      return _body(response.data);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw WalletException(
        _message(error.response?.data) ?? error.userMessage,
      );
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> data,
    CancelToken? token,
  ) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: data,
        cancelToken: token,
      );
      return _body(response.data);
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) rethrow;
      throw WalletException(
        _message(error.response?.data) ?? error.userMessage,
      );
    }
  }

  static Map<String, dynamic> _body(Object? value) {
    if (value is! Map || value['success'] != true) {
      throw WalletException(
        _message(value) ?? 'Máy chủ trả về dữ liệu không hợp lệ.',
      );
    }
    return Map<String, dynamic>.from(value);
  }

  static String? _message(Object? value) {
    if (value is Map) {
      final error = value['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      return value['message']?.toString() ??
          error?.toString() ??
          value['detail']?.toString();
    }
    return null;
  }

  static List<Map<String, dynamic>> _maps(Object? value) => value is List
      ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
      : const [];
}

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepository(ref.watch(dioProvider)),
);

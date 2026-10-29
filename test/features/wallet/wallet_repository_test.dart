import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/wallet/data/wallet_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late WalletRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = WalletRepository(dio);
  });

  test('loads a single payment order status', () async {
    adapter.onGet(
      '/monetization/orders/PAY123/',
      (server) => server.reply(200, {
        'success': true,
        'order': {
          'id': 'PAY123',
          'orderCode': 123456,
          'status': 'SUCCESS',
          'productType': 'COIN',
          'productName': 'Gói Khởi Đầu',
          'amount': 9999,
          'coinsGranted': 500,
        },
        'user': {'coinBalance': 1500},
      }),
    );

    final order = await repository.getOrder(orderId: 'PAY123');

    expect(order.isSuccess, isTrue);
    expect(order.coinBalance, 1500);
    expect(order.coinsGranted, 500);
  });

  test('loads and sorts payment order history newest first', () async {
    adapter.onGet(
      '/monetization/my-orders/',
      (server) => server.reply(200, {
        'success': true,
        'orders': [
          {
            'id': 'old',
            'statusRaw': 'SUCCESS',
            'createdAt': '28/10/2026 10:00',
          },
          {
            'id': 'new',
            'statusRaw': 'PENDING',
            'createdAt': '29/10/2026 10:00',
          },
        ],
      }),
    );

    final orders = await repository.getMyOrders();

    expect(orders.map((order) => order.id), ['new', 'old']);
  });
}

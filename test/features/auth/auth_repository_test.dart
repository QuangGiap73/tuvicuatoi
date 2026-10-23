import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:tuvicuatoi/features/auth/data/auth_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late AuthRepository repository;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://tuvicuatoi.com/api'));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    repository = AuthRepository(dio);
  });

  test('login posts credentials and parses session', () async {
    adapter.onPost(
      '/auth/login/',
      (server) => server.reply(200, {
        'success': true,
        'token': 'login-token',
        'user': {
          'id': 'user-1',
          'email': 'member@example.com',
          'fullName': 'Nguyễn Văn An',
          'coinBalance': 300,
          'isPremium': false,
          'role': 'member',
          'authProvider': 'credentials',
          'createdAt': '2026-09-14T14:54:00Z',
        },
      }),
      data: {'email': 'member@example.com', 'password': 'MatKhau@123'},
    );

    final session = await repository.login(
      email: ' member@example.com ',
      password: 'MatKhau@123',
    );

    expect(session.token, 'login-token');
    expect(session.user.fullName, 'Nguyễn Văn An');
    expect(session.user.coinBalance, 300);
    expect(session.user.memberSince, '2026-09-14T14:54:00Z');
  });

  test(
    'register posts only supplied optional fields and parses session',
    () async {
      adapter.onPost(
        '/auth/register/',
        (server) => server.reply(200, {
          'success': true,
          'session_id': 'register-token',
          'user': {
            'id': 'user-2',
            'email': 'new@example.com',
            'fullName': 'Nguyễn Văn Bình',
            'coinBalance': 300,
            'isPremium': false,
            'role': 'member',
            'authProvider': 'credentials',
          },
        }),
        data: {
          'email': 'new@example.com',
          'password': 'MatKhau@123',
          'fullName': 'Nguyễn Văn Bình',
        },
      );

      final session = await repository.register(
        email: 'new@example.com',
        password: 'MatKhau@123',
        fullName: 'Nguyễn Văn Bình',
      );

      expect(session.token, 'register-token');
      expect(session.user.email, 'new@example.com');
    },
  );

  test('login exposes the backend error message', () async {
    adapter.onPost(
      '/auth/login/',
      (server) => server.reply(400, {
        'success': false,
        'message': 'Thông tin đăng nhập không chính xác',
      }),
      data: {'email': 'wrong@example.com', 'password': 'wrong-pass'},
    );

    expect(
      () =>
          repository.login(email: 'wrong@example.com', password: 'wrong-pass'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Thông tin đăng nhập không chính xác',
        ),
      ),
    );
  });

  test('Google login sends the ID token as credential', () async {
    adapter.onPost(
      '/auth/google/',
      (server) => server.reply(200, {
        'success': true,
        'token': 'backend-token',
        'user': {
          'id': 'google-user',
          'email': 'google@example.com',
          'fullName': 'Google User',
          'coinBalance': 300,
          'isPremium': false,
          'role': 'member',
          'authProvider': 'google',
        },
      }),
      data: {'credential': 'google-id-token'},
    );

    final session = await repository.loginWithGoogle('google-id-token');

    expect(session.token, 'backend-token');
    expect(session.user.authProvider, 'google');
  });

  test('user parses Django date_joined as memberSince', () async {
    adapter.onPost(
      '/auth/login/',
      (server) => server.reply(200, {
        'success': true,
        'token': 'member-token',
        'user': {
          'id': 'member-user',
          'email': 'member@example.com',
          'fullName': 'Member',
          'coinBalance': 0,
          'isPremium': false,
          'role': 'member',
          'authProvider': 'credentials',
          'date_joined': '2026-09-14T14:54:00Z',
        },
      }),
      data: {'email': 'member@example.com', 'password': 'password'},
    );

    final session = await repository.login(
      email: 'member@example.com',
      password: 'password',
    );

    expect(session.user.memberSince, '2026-09-14T14:54:00Z');
  });

  test('me parses the extended account benefits and profile fields', () async {
    adapter.onGet(
      '/auth/me/',
      (server) => server.reply(200, {
        'success': true,
        'authenticated': true,
        'user': {
          'id': 'premium-user',
          'email': 'premium@example.com',
          'fullName': 'Nguyễn Văn A',
          'displayName': 'Văn A',
          'solarTime': '06:30',
          'coinBalance': 1500,
          'unlimitedCoins': true,
          'isPremium': true,
          'role': 'premium',
          'authProvider': 'credentials',
          'hasPassword': true,
          'packageBadge': 'PREMIUM',
          'premiumExpiryDate': '2026-11-19T00:00:00.000Z',
          'aiDailyLimit': 999999,
          'hasUnlimitedSavedCharts': true,
          'hasDeepInterpretation': true,
          'hasPdfExport': true,
          'hasPriorityServer': true,
        },
      }),
    );

    final user = await repository.me();

    expect(user.displayName, 'Văn A');
    expect(user.birthTime, '06:30');
    expect(user.hasPassword, isTrue);
    expect(user.unlimitedCoins, isTrue);
    expect(user.packageBadge, 'PREMIUM');
    expect(user.aiDailyLimit, 999999);
    expect(user.hasUnlimitedSavedCharts, isTrue);
    expect(user.hasDeepInterpretation, isTrue);
    expect(user.hasPdfExport, isTrue);
    expect(user.hasPriorityServer, isTrue);
  });
}

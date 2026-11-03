import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/app/router/auth_route_policy.dart';

void main() {
  test('protects account-backed feature routes', () {
    expect(AuthRoutePolicy.requiresAuthentication('/ai-chat'), isTrue);
    expect(AuthRoutePolicy.requiresAuthentication('/wallet/orders'), isTrue);
    expect(AuthRoutePolicy.requiresAuthentication('/profile/charts'), isTrue);
  });

  test('keeps discovery routes public', () {
    expect(AuthRoutePolicy.requiresAuthentication('/'), isFalse);
    expect(AuthRoutePolicy.requiresAuthentication('/horoscope'), isFalse);
    expect(AuthRoutePolicy.requiresAuthentication('/daily-fortune'), isFalse);
    expect(
      AuthRoutePolicy.requiresAuthentication('/articles/example'),
      isFalse,
    );
  });

  test('only accepts local non-auth redirect targets', () {
    expect(
      AuthRoutePolicy.safeRedirect('/horoscope/result'),
      '/horoscope/result',
    );
    expect(AuthRoutePolicy.safeRedirect('https://example.com'), isNull);
    expect(AuthRoutePolicy.safeRedirect('//example.com/path'), isNull);
    expect(AuthRoutePolicy.safeRedirect('/login'), isNull);
  });
}

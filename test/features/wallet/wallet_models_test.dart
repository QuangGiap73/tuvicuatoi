import 'package:flutter_test/flutter_test.dart';
import 'package:tuvicuatoi/features/wallet/domain/wallet_models.dart';

void main() {
  test('parses backend earn-coins payload without inventing values', () {
    final info = EarnCoinsInfo.fromJson({
      'balance': 7400,
      'hasCheckedInToday': true,
      'streakDays': 3,
      'checkInDays': [
        {'day': 1, 'reward_coins': 30, 'bonus_item': ''},
      ],
      'missions': [
        {
          'code': 'READ_ARTICLE',
          'title': 'Đọc bài viết',
          'description': 'Đọc trong 60 giây',
          'rewardCoins': 30,
          'actionType': 'READ_NEWS',
          'executionDurationSeconds': 60,
          'executionRemainingSeconds': 15,
          'isVerifying': true,
          'canVerify': false,
          'isCompleted': false,
          'remainingSeconds': 0,
          'completionCount': 0,
          'targetUrl': 'https://example.com',
        },
      ],
    });

    expect(info.balance, 7400);
    expect(info.hasCheckedInToday, isTrue);
    expect(info.checkInDays.single.rewardCoins, 30);
    expect(info.missions.single.code, 'READ_ARTICLE');
    expect(info.missions.single.executionRemainingSeconds, 15);
  });

  test('parses transaction amount and package values from backend', () {
    final transaction = CoinTransaction.fromJson({
      'id': 'tx-1',
      'amount': -100,
      'description': 'Mở khóa luận giải',
      'transactionTypeDisplay': 'Mở khóa mục Luận giải',
      'createdAt': '2026-10-28T10:00:00+07:00',
    });
    final package = CoinPackage.fromJson({
      'id': 'pack-1',
      'name': 'Túi Khởi Đầu',
      'totalCoins': 500,
      'bonusCoins': 0,
      'price': 9999,
    });

    expect(transaction.amount, -100);
    expect(transaction.createdAt, isNotNull);
    expect(package.totalCoins, 500);
    expect(package.price, 9999);
  });

  test('parses transaction summary and pagination from backend', () {
    final page = CoinTransactionPage.fromJson({
      'transactions': [
        {
          'id': 'tx-1',
          'amount': 30,
          'description': 'Điểm danh nhận Xu',
          'balanceAfter': 730,
          'dateLabel': 'HÔM NAY · 28-10',
          'time': '14:53',
        },
      ],
      'total': 31,
      'hasMore': true,
      'balance': 730,
      'summary': {'totalEarned': 10400, 'totalSpent': 3280},
    });

    expect(page.total, 31);
    expect(page.hasMore, isTrue);
    expect(page.totalEarned, 10400);
    expect(page.totalSpent, 3280);
    expect(page.items.single.balanceAfter, 730);
    expect(page.items.single.time, '14:53');
  });

  test('parses membership package from backend fields', () {
    final package = MembershipPackage.fromJson({
      'id': 'vip-1',
      'code': 'PREMIUM_MONTHLY',
      'name': 'Gói PREMIUM VIP',
      'tagline': 'Trải nghiệm cao cấp',
      'price': 99000,
      'originalPrice': 129000,
      'periodLabel': 'tháng',
      'badgeLabel': 'ĐƯỢC KHUYÊN DÙNG',
      'isRecommended': true,
      'maxSavedCharts': 20,
      'aiDailyLimit': 10,
      'coinsGranted': 3500,
      'hasAiChatHistory': true,
      'hasPriorityServer': true,
      'hasPdfExport': true,
    });

    expect(package.isRecommended, isTrue);
    expect(package.isFree, isFalse);
    expect(package.maxSavedCharts, 20);
    expect(package.coinsGranted, 3500);
  });
}

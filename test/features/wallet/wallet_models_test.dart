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

  test('keeps a skipped check-in day normal and advances current day', () {
    final info = EarnCoinsInfo.fromJson({
      'balance': 100,
      'hasCheckedInToday': false,
      'streakDays': 1,
      'currentCheckInDay': 4,
      'completedCheckInDays': [1, 3],
      'missedCheckInDays': [2],
      'checkInDays': [
        for (var day = 1; day <= 7; day++)
          {'day': day, 'rewardCoins': day * 10},
      ],
      'missions': [],
    });

    expect(info.statusFor(info.checkInDays[0]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[1]), CheckInDayStatus.missed);
    expect(info.statusFor(info.checkInDays[2]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[3]), CheckInDayStatus.current);
    expect(info.statusFor(info.checkInDays[4]), CheckInDayStatus.upcoming);
  });

  test('parses per-day check-in status aliases', () {
    final info = EarnCoinsInfo.fromJson({
      'hasCheckedInToday': false,
      'streakDays': 0,
      'checkInDays': [
        {'day': 1, 'rewardCoins': 10, 'status': 'completed'},
        {'day': 2, 'rewardCoins': 20, 'skipped': true},
        {'day': 3, 'rewardCoins': 30, 'isCurrent': true},
        {'day': 4, 'rewardCoins': 40, 'status': 'upcoming'},
      ],
      'missions': [],
    });

    expect(info.statusFor(info.checkInDays[0]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[1]), CheckInDayStatus.missed);
    expect(info.statusFor(info.checkInDays[2]), CheckInDayStatus.current);
    expect(info.statusFor(info.checkInDays[3]), CheckInDayStatus.upcoming);
  });

  test('legacy check-in payload keeps the previous streak behavior', () {
    final info = EarnCoinsInfo.fromJson({
      'hasCheckedInToday': false,
      'streakDays': 2,
      'checkInDays': [
        for (var day = 1; day <= 7; day++) {'day': day, 'rewardCoins': 10},
      ],
      'missions': [],
    });

    expect(info.statusFor(info.checkInDays[0]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[1]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[2]), CheckInDayStatus.current);
  });

  test('does not expose the next day after checking in today', () {
    final info = EarnCoinsInfo.fromJson({
      'hasCheckedInToday': true,
      'streakDays': 1,
      'currentCheckInDay': 2,
      'completedCheckInDays': [1],
      'checkInDays': [
        {'day': 1, 'rewardCoins': 30, 'status': 'completed'},
        {'day': 2, 'rewardCoins': 40, 'status': 'current'},
        {'day': 3, 'rewardCoins': 50, 'status': 'upcoming'},
      ],
      'missions': [],
    });

    expect(info.statusFor(info.checkInDays[0]), CheckInDayStatus.completed);
    expect(info.statusFor(info.checkInDays[1]), CheckInDayStatus.upcoming);
    expect(info.statusFor(info.checkInDays[2]), CheckInDayStatus.upcoming);
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

  test('parses payment order status and localized history date', () {
    final completed = PaymentOrder.fromJson({
      'id': 'PAY123',
      'orderCode': 123456,
      'productType': 'COIN',
      'productName': 'Gói Khởi Đầu',
      'amount': 9999,
      'status': 'SUCCESS',
      'coinsGranted': 500,
      'coinBalance': 1200,
      'paidAt': '2026-10-29T09:30:00+07:00',
    });
    final history = PaymentOrder.fromJson({
      'id': 'PAY124',
      'planName': 'Nạp Gói Khởi Đầu',
      'amount': 9999,
      'statusRaw': 'PENDING',
      'createdAt': '29/10/2026 09:20',
    });

    expect(completed.isSuccess, isTrue);
    expect(completed.isTerminal, isTrue);
    expect(completed.coinBalance, 1200);
    expect(history.isPending, isTrue);
    expect(history.createdAt, DateTime(2026, 10, 29, 9, 20));
  });
}

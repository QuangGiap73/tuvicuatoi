enum CheckInDayStatus { completed, current, missed, upcoming }

class CheckInDay {
  const CheckInDay({
    required this.day,
    required this.rewardCoins,
    this.bonusItem = '',
    this.status,
  });
  final int day;
  final int rewardCoins;
  final String bonusItem;
  final CheckInDayStatus? status;

  factory CheckInDay.fromJson(Map<String, dynamic> json) => CheckInDay(
    day: (json['day'] as num?)?.toInt() ?? 0,
    rewardCoins:
        (json['reward_coins'] as num?)?.toInt() ??
        (json['rewardCoins'] as num?)?.toInt() ??
        0,
    bonusItem: json['bonus_item']?.toString() ?? '',
    status: _checkInStatus(json),
  );
}

class CoinMission {
  const CoinMission({
    required this.code,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.actionType,
    required this.executionDurationSeconds,
    required this.executionRemainingSeconds,
    required this.isVerifying,
    required this.canVerify,
    required this.isCompleted,
    required this.remainingSeconds,
    required this.completionCount,
    required this.targetUrl,
  });
  final String code;
  final String title;
  final String description;
  final int rewardCoins;
  final String actionType;
  final int executionDurationSeconds;
  final int executionRemainingSeconds;
  final bool isVerifying;
  final bool canVerify;
  final bool isCompleted;
  final int remainingSeconds;
  final int completionCount;
  final String targetUrl;

  factory CoinMission.fromJson(Map<String, dynamic> json) => CoinMission(
    code: json['code']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    rewardCoins: (json['rewardCoins'] as num?)?.toInt() ?? 0,
    actionType: json['actionType']?.toString() ?? '',
    executionDurationSeconds:
        (json['executionDurationSeconds'] as num?)?.toInt() ?? 0,
    executionRemainingSeconds:
        (json['executionRemainingSeconds'] as num?)?.toInt() ?? 0,
    isVerifying: json['isVerifying'] == true,
    canVerify: json['canVerify'] == true,
    isCompleted: json['isCompleted'] == true,
    remainingSeconds: (json['remainingSeconds'] as num?)?.toInt() ?? 0,
    completionCount: (json['completionCount'] as num?)?.toInt() ?? 0,
    targetUrl: json['targetUrl']?.toString() ?? '',
  );
}

class EarnCoinsInfo {
  const EarnCoinsInfo({
    required this.balance,
    required this.hasCheckedInToday,
    required this.streakDays,
    required this.checkInDays,
    required this.missions,
    this.currentCheckInDay,
    this.completedCheckInDays = const {},
    this.missedCheckInDays = const {},
    this.hasExplicitCheckInSchedule = false,
  });
  final int balance;
  final bool hasCheckedInToday;
  final int streakDays;
  final List<CheckInDay> checkInDays;
  final List<CoinMission> missions;
  final int? currentCheckInDay;
  final Set<int> completedCheckInDays;
  final Set<int> missedCheckInDays;
  final bool hasExplicitCheckInSchedule;

  factory EarnCoinsInfo.fromJson(Map<String, dynamic> json) {
    final days = _maps(json['checkInDays']).map(CheckInDay.fromJson).toList();
    final completed = _dayNumbers(
      json['completedCheckInDays'] ??
          json['checkedInDays'] ??
          json['completedDays'],
    );
    final missed = _dayNumbers(
      json['missedCheckInDays'] ?? json['skippedDays'] ?? json['missedDays'],
    );
    final current = _integerOrNull(
      json['currentCheckInDay'] ??
          json['currentDay'] ??
          json['todayCheckInDay'] ??
          json['cycleDay'],
    );
    final itemHasStatus = days.any((day) => day.status != null);
    return EarnCoinsInfo(
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      hasCheckedInToday: json['hasCheckedInToday'] == true,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      checkInDays: days,
      missions: _maps(json['missions'])
          .map(CoinMission.fromJson)
          .where((mission) => mission.code.isNotEmpty)
          .toList(),
      currentCheckInDay: current ?? _currentDayFromItems(days),
      completedCheckInDays: Set.unmodifiable(completed),
      missedCheckInDays: Set.unmodifiable(missed),
      hasExplicitCheckInSchedule:
          itemHasStatus ||
          current != null ||
          completed.isNotEmpty ||
          missed.isNotEmpty,
    );
  }

  CheckInDayStatus statusFor(CheckInDay day) {
    final explicitStatus = day.status;
    if (explicitStatus == CheckInDayStatus.completed ||
        explicitStatus == CheckInDayStatus.missed) {
      return explicitStatus!;
    }
    if (completedCheckInDays.contains(day.day)) {
      return CheckInDayStatus.completed;
    }
    if (missedCheckInDays.contains(day.day)) return CheckInDayStatus.missed;

    // Some backends advance `currentDay` (or mark the next item as current)
    // immediately after a successful check-in. It is still an upcoming day
    // until the user's local calendar reaches the next day.
    if (hasCheckedInToday) {
      if (!hasExplicitCheckInSchedule && day.day <= streakDays) {
        return CheckInDayStatus.completed;
      }
      return CheckInDayStatus.upcoming;
    }

    if (explicitStatus == CheckInDayStatus.current) {
      return CheckInDayStatus.current;
    }
    if (day.day == currentCheckInDay) {
      return CheckInDayStatus.current;
    }
    if (hasExplicitCheckInSchedule) return CheckInDayStatus.upcoming;
    if (day.day <= streakDays) return CheckInDayStatus.completed;
    final legacyCurrent = checkInDays.isEmpty
        ? 0
        : (streakDays + 1).clamp(1, checkInDays.length);
    return day.day == legacyCurrent
        ? CheckInDayStatus.current
        : CheckInDayStatus.upcoming;
  }
}

class CoinTransaction {
  const CoinTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.typeDisplay,
    required this.createdAt,
    this.balanceAfter,
    this.dateLabel = '',
    this.time = '',
  });
  final String id;
  final int amount;
  final String description;
  final String typeDisplay;
  final DateTime? createdAt;
  final int? balanceAfter;
  final String dateLabel;
  final String time;

  factory CoinTransaction.fromJson(Map<String, dynamic> json) =>
      CoinTransaction(
        id: json['id']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        description: json['description']?.toString() ?? '',
        typeDisplay:
            json['transactionTypeDisplay']?.toString() ??
            json['transactionType']?.toString() ??
            '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
        balanceAfter: (json['balanceAfter'] as num?)?.toInt(),
        dateLabel: json['dateLabel']?.toString() ?? '',
        time: json['time']?.toString() ?? '',
      );
}

class CoinTransactionPage {
  const CoinTransactionPage({
    required this.items,
    required this.total,
    required this.hasMore,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
  });
  final List<CoinTransaction> items;
  final int total;
  final bool hasMore;
  final int balance;
  final int totalEarned;
  final int totalSpent;

  factory CoinTransactionPage.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] is Map
        ? Map<String, dynamic>.from(json['summary'] as Map)
        : const <String, dynamic>{};
    return CoinTransactionPage(
      items: _maps(json['transactions']).map(CoinTransaction.fromJson).toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      hasMore: json['hasMore'] == true,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      totalEarned: (summary['totalEarned'] as num?)?.toInt() ?? 0,
      totalSpent: (summary['totalSpent'] as num?)?.toInt() ?? 0,
    );
  }
}

class CoinPackage {
  const CoinPackage({
    required this.id,
    required this.name,
    required this.totalCoins,
    required this.bonusCoins,
    required this.price,
    required this.description,
    required this.badgeLabel,
    this.originalPrice = 0,
    this.iconName = '',
    this.order = 0,
  });
  final String id;
  final String name;
  final int totalCoins;
  final int bonusCoins;
  final double price;
  final String description;
  final String badgeLabel;
  final double originalPrice;
  final String iconName;
  final int order;

  factory CoinPackage.fromJson(Map<String, dynamic> json) => CoinPackage(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    totalCoins: (json['totalCoins'] as num?)?.toInt() ?? 0,
    bonusCoins: (json['bonusCoins'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    description: json['description']?.toString() ?? '',
    badgeLabel: json['badgeLabel']?.toString() ?? '',
    originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
    iconName: json['iconName']?.toString() ?? '',
    order: (json['order'] as num?)?.toInt() ?? 0,
  );
}

class MembershipPackage {
  const MembershipPackage({
    required this.id,
    required this.code,
    required this.name,
    required this.tagline,
    required this.price,
    required this.originalPrice,
    required this.periodLabel,
    required this.badgeLabel,
    required this.isRecommended,
    required this.maxSavedCharts,
    required this.aiDailyLimit,
    required this.coinsGranted,
    required this.hasAiChatHistory,
    required this.hasPriorityServer,
    required this.hasPdfExport,
  });
  final String id;
  final String code;
  final String name;
  final String tagline;
  final double price;
  final double originalPrice;
  final String periodLabel;
  final String badgeLabel;
  final bool isRecommended;
  final int maxSavedCharts;
  final int aiDailyLimit;
  final int coinsGranted;
  final bool hasAiChatHistory;
  final bool hasPriorityServer;
  final bool hasPdfExport;

  bool get isFree => price <= 0;

  factory MembershipPackage.fromJson(Map<String, dynamic> json) =>
      MembershipPackage(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        tagline: json['tagline']?.toString() ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
        periodLabel: json['periodLabel']?.toString() ?? '',
        badgeLabel: json['badgeLabel']?.toString() ?? '',
        isRecommended: json['isRecommended'] == true,
        maxSavedCharts: (json['maxSavedCharts'] as num?)?.toInt() ?? 0,
        aiDailyLimit: (json['aiDailyLimit'] as num?)?.toInt() ?? 0,
        coinsGranted: (json['coinsGranted'] as num?)?.toInt() ?? 0,
        hasAiChatHistory: json['hasAiChatHistory'] == true,
        hasPriorityServer: json['hasPriorityServer'] == true,
        hasPdfExport: json['hasPdfExport'] == true,
      );
}

class PaymentOrderResult {
  const PaymentOrderResult({
    required this.checkoutUrl,
    required this.orderId,
    required this.order,
    this.qrCode = '',
  });
  final String checkoutUrl;
  final String orderId;
  final PaymentOrder order;
  final String qrCode;
}

class PaymentOrder {
  const PaymentOrder({
    required this.id,
    required this.orderCode,
    required this.productType,
    required this.productName,
    required this.amount,
    required this.status,
    this.coinsGranted = 0,
    this.coinBalance,
    this.method = '',
    this.createdAt,
    this.paidAt,
    this.expiresAt,
  });

  final String id;
  final String orderCode;
  final String productType;
  final String productName;
  final double amount;
  final String status;
  final int coinsGranted;
  final int? coinBalance;
  final String method;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? expiresAt;

  String get normalizedStatus => status.trim().toUpperCase();
  bool get isSuccess =>
      const {'SUCCESS', 'COMPLETED', 'PAID'}.contains(normalizedStatus);
  bool get isPending =>
      const {'PENDING', 'PROCESSING', 'WAITING'}.contains(normalizedStatus);
  bool get isTerminal =>
      isSuccess ||
      const {
        'FAILED',
        'CANCELLED',
        'CANCELED',
        'EXPIRED',
      }.contains(normalizedStatus);

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => PaymentOrder(
    id: json['id']?.toString() ?? '',
    orderCode:
        json['orderCode']?.toString() ??
        json['providerOrderCode']?.toString() ??
        '',
    productType: json['productType']?.toString() ?? '',
    productName:
        json['productName']?.toString() ?? json['planName']?.toString() ?? '',
    amount: _double(json['amount']),
    status: json['statusRaw']?.toString() ?? json['status']?.toString() ?? '',
    coinsGranted: (json['coinsGranted'] as num?)?.toInt() ?? 0,
    coinBalance: (json['coinBalance'] as num?)?.toInt(),
    method: json['method']?.toString() ?? '',
    createdAt: _date(json['createdAt']),
    paidAt: _date(json['paidAt']),
    expiresAt: _date(json['expiresAt']),
  );
}

class VoucherValidationResult {
  const VoucherValidationResult({
    required this.id,
    required this.code,
    required this.name,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.finalCost,
    required this.message,
  });

  final String id;
  final String code;
  final String name;
  final String discountType;
  final double discountValue;
  final double discountAmount;
  final double finalCost;
  final String message;

  factory VoucherValidationResult.fromJson(Map<String, dynamic> json) =>
      VoucherValidationResult(
        id: json['id']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        discountType: json['discountType']?.toString() ?? '',
        discountValue: _double(json['discountValue']),
        discountAmount: _double(
          json['discountAmount'] ??
              json['discountCoins'] ??
              json['discountValueApplied'],
        ),
        finalCost: _double(json['finalCost']),
        message: json['message']?.toString() ?? '',
      );
}

List<Map<String, dynamic>> _maps(Object? value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

CheckInDayStatus? _checkInStatus(Map<String, dynamic> json) {
  if (json['isCompleted'] == true ||
      json['completed'] == true ||
      json['isChecked'] == true ||
      json['checked'] == true ||
      json['claimed'] == true) {
    return CheckInDayStatus.completed;
  }
  if (json['isCurrent'] == true ||
      json['current'] == true ||
      json['isToday'] == true) {
    return CheckInDayStatus.current;
  }
  if (json['isMissed'] == true ||
      json['missed'] == true ||
      json['skipped'] == true) {
    return CheckInDayStatus.missed;
  }
  final status = (json['status'] ?? json['checkInStatus'])
      ?.toString()
      .trim()
      .toLowerCase();
  return switch (status) {
    'completed' ||
    'checked' ||
    'claimed' ||
    'done' => CheckInDayStatus.completed,
    'current' || 'today' || 'available' => CheckInDayStatus.current,
    'missed' || 'skipped' || 'expired' => CheckInDayStatus.missed,
    'upcoming' || 'future' || 'locked' => CheckInDayStatus.upcoming,
    _ => null,
  };
}

int? _integerOrNull(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString().trim() ?? '');

Set<int> _dayNumbers(Object? value) {
  if (value is! List) return const {};
  return value
      .map((item) {
        if (item is Map) {
          return _integerOrNull(item['day'] ?? item['dayNumber']);
        }
        return _integerOrNull(item);
      })
      .whereType<int>()
      .where((day) => day > 0)
      .toSet();
}

int? _currentDayFromItems(List<CheckInDay> days) {
  for (final day in days) {
    if (day.status == CheckInDayStatus.current) return day.day;
  }
  return null;
}

double _double(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

DateTime? _date(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) return null;
  final iso = DateTime.tryParse(text);
  if (iso != null) return iso;
  final match = RegExp(
    r'^(\d{1,2})/(\d{1,2})/(\d{4})(?:\s+(\d{1,2}):(\d{2}))?$',
  ).firstMatch(text);
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(3)!),
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
    int.tryParse(match.group(4) ?? '') ?? 0,
    int.tryParse(match.group(5) ?? '') ?? 0,
  );
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.coinBalance,
    required this.isPremium,
    required this.role,
    required this.authProvider,
    this.displayName,
    this.phone,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.memberSince,
    this.avatarUrl,
    this.packageName,
    this.packageCode,
    this.packageBadge,
    this.premiumExpiryDate,
    this.hasPassword = false,
    this.unlimitedCoins = false,
    this.dailyAiQuestionsLeft,
    this.dailyQuestionsUsed,
    this.aiDailyLimit,
    this.maxAiQuestions,
    this.hasUnlimitedAi = false,
    this.hasAiChatHistory = false,
    this.savedChartsCount,
    this.maxSavedCharts,
    this.hasUnlimitedSavedCharts = false,
    this.hasDeepInterpretation = false,
    this.hasPdfExport = false,
    this.hasPriorityServer = false,
    this.referralCode,
  });

  final String id;
  final String email;
  final String fullName;
  final String? displayName;
  final String? phone;
  final String? birthDate;
  final String? birthTime;
  final String? gender;
  final String? memberSince;
  final int coinBalance;
  final bool isPremium;
  final String role;
  final String authProvider;
  final String? avatarUrl;
  final String? packageName;
  final String? packageCode;
  final String? packageBadge;
  final String? premiumExpiryDate;
  final bool hasPassword;
  final bool unlimitedCoins;
  final int? dailyAiQuestionsLeft;
  final int? dailyQuestionsUsed;
  final int? aiDailyLimit;
  final int? maxAiQuestions;
  final bool hasUnlimitedAi;
  final bool hasAiChatHistory;
  final int? savedChartsCount;
  final int? maxSavedCharts;
  final bool hasUnlimitedSavedCharts;
  final bool hasDeepInterpretation;
  final bool hasPdfExport;
  final bool hasPriorityServer;
  final String? referralCode;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    fullName: (json['fullName'] ?? json['displayName'] ?? '').toString(),
    displayName: json['displayName']?.toString(),
    phone: json['phone']?.toString(),
    birthDate: (json['birthDate'] ?? json['dateOfBirth'])?.toString(),
    birthTime: (json['birthTime'] ?? json['timeOfBirth'] ?? json['solarTime'])
        ?.toString(),
    gender: json['gender']?.toString(),
    memberSince:
        (json['createdAt'] ??
                json['created_at'] ??
                json['dateJoined'] ??
                json['date_joined'] ??
                json['joinedAt'] ??
                json['joined_at'] ??
                json['memberSince'])
            ?.toString(),
    coinBalance: (json['coinBalance'] as num?)?.toInt() ?? 0,
    isPremium: json['isPremium'] == true || json['is_premium'] == true,
    role: json['role']?.toString() ?? 'member',
    authProvider: json['authProvider']?.toString() ?? 'credentials',
    avatarUrl: json['avatarUrl']?.toString(),
    packageName: json['packageName']?.toString(),
    packageCode: json['packageCode']?.toString(),
    packageBadge: json['packageBadge']?.toString(),
    premiumExpiryDate:
        (json['premiumExpiryDate'] ?? json['premium_expiry_date'])?.toString(),
    hasPassword: json['hasPassword'] == true || json['has_password'] == true,
    unlimitedCoins:
        json['unlimitedCoins'] == true || json['unlimited_coins'] == true,
    dailyAiQuestionsLeft: (json['dailyAiQuestionsLeft'] as num?)?.toInt(),
    dailyQuestionsUsed: (json['dailyQuestionsUsed'] as num?)?.toInt(),
    aiDailyLimit: (json['aiDailyLimit'] as num?)?.toInt(),
    maxAiQuestions:
        (json['maxAiQuestions'] as num?)?.toInt() ??
        (json['aiDailyLimit'] as num?)?.toInt(),
    hasUnlimitedAi:
        json['hasUnlimitedAi'] == true || json['has_unlimited_ai'] == true,
    hasAiChatHistory:
        json['hasAiChatHistory'] == true || json['has_ai_chat_history'] == true,
    savedChartsCount: (json['savedChartsCount'] as num?)?.toInt(),
    maxSavedCharts: (json['maxSavedCharts'] as num?)?.toInt(),
    hasUnlimitedSavedCharts:
        json['hasUnlimitedSavedCharts'] == true ||
        json['has_unlimited_saved_charts'] == true,
    hasDeepInterpretation:
        json['hasDeepInterpretation'] == true ||
        json['has_deep_interpretation'] == true,
    hasPdfExport:
        json['hasPdfExport'] == true || json['has_pdf_export'] == true,
    hasPriorityServer:
        json['hasPriorityServer'] == true ||
        json['has_priority_server'] == true,
    referralCode: json['referralCode']?.toString(),
  );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AuthUser user;
}

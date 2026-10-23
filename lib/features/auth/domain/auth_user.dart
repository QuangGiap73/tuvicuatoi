class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.coinBalance,
    required this.isPremium,
    required this.role,
    required this.authProvider,
    this.phone,
    this.birthDate,
    this.birthTime,
    this.gender,
    this.memberSince,
    this.avatarUrl,
    this.packageName,
    this.packageCode,
    this.dailyAiQuestionsLeft,
    this.dailyQuestionsUsed,
    this.maxAiQuestions,
    this.hasUnlimitedAi = false,
    this.hasAiChatHistory = false,
    this.savedChartsCount,
    this.maxSavedCharts,
    this.referralCode,
  });

  final String id;
  final String email;
  final String fullName;
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
  final int? dailyAiQuestionsLeft;
  final int? dailyQuestionsUsed;
  final int? maxAiQuestions;
  final bool hasUnlimitedAi;
  final bool hasAiChatHistory;
  final int? savedChartsCount;
  final int? maxSavedCharts;
  final String? referralCode;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    fullName: (json['fullName'] ?? json['displayName'] ?? '').toString(),
    phone: json['phone']?.toString(),
    birthDate: (json['birthDate'] ?? json['dateOfBirth'])?.toString(),
    birthTime: (json['birthTime'] ?? json['timeOfBirth'])?.toString(),
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
    dailyAiQuestionsLeft: (json['dailyAiQuestionsLeft'] as num?)?.toInt(),
    dailyQuestionsUsed: (json['dailyQuestionsUsed'] as num?)?.toInt(),
    maxAiQuestions:
        (json['maxAiQuestions'] as num?)?.toInt() ??
        (json['aiDailyLimit'] as num?)?.toInt(),
    hasUnlimitedAi:
        json['hasUnlimitedAi'] == true || json['has_unlimited_ai'] == true,
    hasAiChatHistory:
        json['hasAiChatHistory'] == true || json['has_ai_chat_history'] == true,
    savedChartsCount: (json['savedChartsCount'] as num?)?.toInt(),
    maxSavedCharts: (json['maxSavedCharts'] as num?)?.toInt(),
    referralCode: json['referralCode']?.toString(),
  );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AuthUser user;
}

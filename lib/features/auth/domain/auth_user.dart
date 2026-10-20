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
    this.avatarUrl,
    this.packageName,
    this.packageCode,
    this.dailyAiQuestionsLeft,
    this.maxSavedCharts,
    this.referralCode,
  });

  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final int coinBalance;
  final bool isPremium;
  final String role;
  final String authProvider;
  final String? avatarUrl;
  final String? packageName;
  final String? packageCode;
  final int? dailyAiQuestionsLeft;
  final int? maxSavedCharts;
  final String? referralCode;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    fullName: (json['fullName'] ?? json['displayName'] ?? '').toString(),
    phone: json['phone']?.toString(),
    coinBalance: (json['coinBalance'] as num?)?.toInt() ?? 0,
    isPremium: json['isPremium'] == true,
    role: json['role']?.toString() ?? 'member',
    authProvider: json['authProvider']?.toString() ?? 'credentials',
    avatarUrl: json['avatarUrl']?.toString(),
    packageName: json['packageName']?.toString(),
    packageCode: json['packageCode']?.toString(),
    dailyAiQuestionsLeft: (json['dailyAiQuestionsLeft'] as num?)?.toInt(),
    maxSavedCharts: (json['maxSavedCharts'] as num?)?.toInt(),
    referralCode: json['referralCode']?.toString(),
  );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});
  final String token;
  final AuthUser user;
}

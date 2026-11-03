class FortuneHour {
  const FortuneHour({
    required this.branch,
    required this.time,
    required this.isAuspicious,
    required this.starName,
    this.affinityType,
    this.affinityLabel,
    this.affinityBadge,
  });
  final String branch;
  final String time;
  final bool isAuspicious;
  final String starName;
  final String? affinityType;
  final String? affinityLabel;
  final String? affinityBadge;
}

import 'fortune_hour.dart';

class PersonalFortune {
  const PersonalFortune({
    required this.chartName,
    required this.birthYearCanChi,
    required this.birthBranch,
    required this.destinyNayin,
    required this.destinyElement,
    required this.palaceName,
    required this.palaceBranch,
    required this.majorStars,
    required this.dailyStars,
    required this.branchRelationType,
    required this.branchRelationDescription,
    required this.elementRelationType,
    required this.elementRelationDescription,
    required this.mutagenStars,
    required this.overallScore,
    required this.overallRating,
    required this.careerAdvice,
    required this.wealthAdvice,
    required this.loveAdvice,
    required this.healthAdvice,
    required this.luckyColor,
    required this.luckyColorReason,
    required this.luckyDirection,
    required this.personalizedHours,
  });
  final String chartName;
  final String birthYearCanChi;
  final String birthBranch;
  final String destinyNayin;
  final String destinyElement;
  final String palaceName;
  final String palaceBranch;
  final List<String> majorStars;
  final List<String> dailyStars;
  final String branchRelationType;
  final String branchRelationDescription;
  final String elementRelationType;
  final String elementRelationDescription;
  final Map<String, MutagenStar> mutagenStars;
  final int overallScore;
  final String overallRating;
  final String careerAdvice;
  final String wealthAdvice;
  final String loveAdvice;
  final String healthAdvice;
  final String luckyColor;
  final String luckyColorReason;
  final String luckyDirection;
  final List<FortuneHour> personalizedHours;
}

class MutagenStar {
  const MutagenStar({required this.star, required this.palace});
  final String star;
  final String palace;
}

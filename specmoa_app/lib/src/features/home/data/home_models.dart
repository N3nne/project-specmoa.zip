class HomeSummary {
  const HomeSummary({
    required this.myQualificationCount,
    required this.completedQualificationCount,
    required this.todayStudyMinutes,
  });

  final int myQualificationCount;
  final int completedQualificationCount;
  final int todayStudyMinutes;

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      myQualificationCount: json['myQualificationCount'] as int? ?? 0,
      completedQualificationCount:
          json['completedQualificationCount'] as int? ?? 0,
      todayStudyMinutes: json['todayStudyMinutes'] as int? ?? 0,
    );
  }
}

class HomeMyQualification {
  const HomeMyQualification({
    required this.id,
    required this.qualificationName,
    required this.status,
    required this.totalStudyMinutes,
    required this.dDay,
  });

  final String id;
  final String qualificationName;
  final String status;
  final int totalStudyMinutes;
  final int? dDay;

  factory HomeMyQualification.fromJson(Map<String, dynamic> json) {
    return HomeMyQualification(
      id: json['id'] as String? ?? '',
      qualificationName: json['qualificationName'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      dDay: json['dDay'] as int?,
    );
  }
}

class HomeQuestion {
  const HomeQuestion({
    required this.id,
    required this.title,
    required this.qualificationName,
    required this.likeCount,
    required this.commentCount,
  });

  final String id;
  final String title;
  final String qualificationName;
  final int likeCount;
  final int commentCount;

  factory HomeQuestion.fromJson(Map<String, dynamic> json) {
    return HomeQuestion(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      qualificationName: json['qualificationName'] as String? ?? '',
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
    );
  }
}

class HomeReview {
  const HomeReview({
    required this.id,
    required this.title,
    required this.qualificationName,
    required this.studyPeriodText,
    required this.tipSummary,
  });

  final String id;
  final String title;
  final String qualificationName;
  final String? studyPeriodText;
  final String? tipSummary;

  factory HomeReview.fromJson(Map<String, dynamic> json) {
    return HomeReview(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      qualificationName: json['qualificationName'] as String? ?? '',
      studyPeriodText: json['studyPeriodText'] as String?,
      tipSummary: json['tipSummary'] as String?,
    );
  }
}

class HomeResponse {
  const HomeResponse({
    required this.displayName,
    required this.level,
    required this.streakDays,
    required this.summary,
    required this.myQualifications,
    required this.popularQuestions,
    required this.passReviews,
  });

  final String displayName;
  final int level;
  final int streakDays;
  final HomeSummary summary;
  final List<HomeMyQualification> myQualifications;
  final List<HomeQuestion> popularQuestions;
  final List<HomeReview> passReviews;

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};

    return HomeResponse(
      displayName: user['displayName'] as String? ?? '',
      level: user['level'] as int? ?? 0,
      streakDays: user['streakDays'] as int? ?? 0,
      summary: HomeSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      myQualifications: (json['myQualifications'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                HomeMyQualification.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      popularQuestions: (json['popularQuestions'] as List<dynamic>? ?? [])
          .map((item) => HomeQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      passReviews: (json['passReviews'] as List<dynamic>? ?? [])
          .map((item) => HomeReview.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

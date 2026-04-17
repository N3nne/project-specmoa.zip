class StudySessionSummary {
  const StudySessionSummary({
    required this.sessionCount,
    required this.totalDurationSeconds,
    required this.totalDurationMinutes,
  });

  final int sessionCount;
  final int totalDurationSeconds;
  final int totalDurationMinutes;

  factory StudySessionSummary.fromJson(Map<String, dynamic> json) {
    return StudySessionSummary(
      sessionCount: json['sessionCount'] as int? ?? 0,
      totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 0,
      totalDurationMinutes: json['totalDurationMinutes'] as int? ?? 0,
    );
  }
}

class ActiveStudySession {
  const ActiveStudySession({
    required this.id,
    required this.userId,
    required this.userQualificationId,
    required this.startedAt,
  });

  final String id;
  final String userId;
  final String userQualificationId;
  final DateTime startedAt;

  factory ActiveStudySession.fromJson(Map<String, dynamic> json) {
    return ActiveStudySession(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userQualificationId: json['userQualificationId'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

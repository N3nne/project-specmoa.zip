class MyProfile {
  const MyProfile({
    required this.id,
    required this.displayName,
    required this.email,
    required this.level,
    required this.streakDays,
    this.profileImageUrl,
  });

  final String id;
  final String displayName;
  final String email;
  final int level;
  final int streakDays;
  final String? profileImageUrl;

  factory MyProfile.fromJson(Map<String, dynamic> json) {
    return MyProfile(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      level: json['level'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}

class MyStats {
  const MyStats({
    required this.totalStudyMinutes,
    required this.earnedCertificatesCount,
    required this.progressRate,
    required this.qualificationCount,
  });

  final int totalStudyMinutes;
  final int earnedCertificatesCount;
  final double progressRate;
  final int qualificationCount;

  factory MyStats.fromJson(Map<String, dynamic> json) {
    return MyStats(
      totalStudyMinutes: json['totalStudyMinutes'] as int? ?? 0,
      earnedCertificatesCount: json['earnedCertificatesCount'] as int? ?? 0,
      progressRate: (json['progressRate'] as num?)?.toDouble() ?? 0,
      qualificationCount: json['qualificationCount'] as int? ?? 0,
    );
  }
}

class WeeklyGoalData {
  const WeeklyGoalData({
    required this.targetHours,
    required this.achievedMinutes,
    required this.progressRate,
    required this.notificationEnabled,
  });

  final int targetHours;
  final int achievedMinutes;
  final int progressRate;
  final bool notificationEnabled;

  factory WeeklyGoalData.fromJson(Map<String, dynamic> json) {
    return WeeklyGoalData(
      targetHours: json['targetHours'] as int? ?? 0,
      achievedMinutes: json['achievedMinutes'] as int? ?? 0,
      progressRate: json['progressRate'] as int? ?? 0,
      notificationEnabled: json['notificationEnabled'] as bool? ?? false,
    );
  }
}

class RecentActivity {
  const RecentActivity({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
  });

  final String id;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      endedAt: DateTime.tryParse(json['endedAt'] as String? ?? ''),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }
}

class AchievementItem {
  const AchievementItem({
    required this.key,
    required this.title,
    required this.value,
  });

  final String key;
  final String title;
  final String value;

  factory AchievementItem.fromJson(Map<String, dynamic> json) {
    return AchievementItem(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }
}

class UserSettingItem {
  const UserSettingItem({
    required this.key,
    required this.value,
  });

  final String key;
  final Map<String, dynamic> value;

  factory UserSettingItem.fromJson(Map<String, dynamic> json) {
    return UserSettingItem(
      key: json['key'] as String? ?? '',
      value: (json['value'] as Map<String, dynamic>? ?? const {}),
    );
  }
}

class MyResponse {
  const MyResponse({
    required this.profile,
    required this.stats,
    required this.weeklyGoal,
    required this.recentActivity,
    required this.achievements,
    required this.settings,
  });

  final MyProfile profile;
  final MyStats stats;
  final WeeklyGoalData weeklyGoal;
  final List<RecentActivity> recentActivity;
  final List<AchievementItem> achievements;
  final List<UserSettingItem> settings;

  factory MyResponse.fromJson(Map<String, dynamic> json) {
    return MyResponse(
      profile: MyProfile.fromJson(
        json['profile'] as Map<String, dynamic>? ?? const {},
      ),
      stats: MyStats.fromJson(
        json['stats'] as Map<String, dynamic>? ?? const {},
      ),
      weeklyGoal: WeeklyGoalData.fromJson(
        json['weeklyGoal'] as Map<String, dynamic>? ?? const {},
      ),
      recentActivity: (json['recentActivity'] as List<dynamic>? ?? [])
          .map((item) => RecentActivity.fromJson(item as Map<String, dynamic>))
          .toList(),
      achievements: (json['achievements'] as List<dynamic>? ?? [])
          .map((item) => AchievementItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      settings: (json['settings'] as List<dynamic>? ?? [])
          .map((item) => UserSettingItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

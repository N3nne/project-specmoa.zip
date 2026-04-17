class QualificationTab {
  const QualificationTab({
    required this.code,
    required this.label,
    required this.count,
  });

  final String code;
  final String label;
  final int count;

  factory QualificationTab.fromJson(Map<String, dynamic> json) {
    return QualificationTab(
      code: json['code'] as String? ?? '',
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class QualificationCardModel {
  const QualificationCardModel({
    required this.code,
    required this.name,
    required this.qualificationTypeName,
    required this.seriesName,
    required this.primaryFieldName,
    required this.difficulty,
    required this.expectedStudyMinutes,
    required this.displayColor,
    required this.isFeatured,
  });

  final String code;
  final String name;
  final String qualificationTypeName;
  final String seriesName;
  final String primaryFieldName;
  final String? difficulty;
  final int? expectedStudyMinutes;
  final String? displayColor;
  final bool isFeatured;

  factory QualificationCardModel.fromJson(Map<String, dynamic> json) {
    return QualificationCardModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qualificationTypeName: json['qualificationTypeName'] as String? ?? '',
      seriesName: json['seriesName'] as String? ?? '',
      primaryFieldName: json['primaryFieldName'] as String? ?? '',
      difficulty: json['difficulty'] as String?,
      expectedStudyMinutes: json['expectedStudyMinutes'] as int?,
      displayColor: json['displayColor'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}

class QualificationDetailModel {
  const QualificationDetailModel({
    required this.id,
    required this.code,
    required this.name,
    required this.qualificationTypeName,
    required this.seriesName,
    required this.primaryFieldName,
    required this.secondaryFieldName,
    required this.difficulty,
    required this.expectedStudyMinutes,
    required this.displayColor,
    required this.isFeatured,
  });

  final String id;
  final String code;
  final String name;
  final String qualificationTypeName;
  final String seriesName;
  final String? primaryFieldName;
  final String? secondaryFieldName;
  final String? difficulty;
  final int? expectedStudyMinutes;
  final String? displayColor;
  final bool isFeatured;

  factory QualificationDetailModel.fromJson(Map<String, dynamic> json) {
    return QualificationDetailModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qualificationTypeName: json['qualificationTypeName'] as String? ?? '',
      seriesName: json['seriesName'] as String? ?? '',
      primaryFieldName: json['primaryFieldName'] as String?,
      secondaryFieldName: json['secondaryFieldName'] as String?,
      difficulty: json['difficulty'] as String?,
      expectedStudyMinutes: json['expectedStudyMinutes'] as int?,
      displayColor: json['displayColor'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }
}

class CommunityCommentModel {
  const CommunityCommentModel({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String? author;
  final String content;
  final DateTime? createdAt;

  factory CommunityCommentModel.fromJson(Map<String, dynamic> json) {
    return CommunityCommentModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      author: json['author'] as String?,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class QuestionPreviewModel {
  const QuestionPreviewModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.author,
    required this.commentCount,
    required this.likeCount,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String? author;
  final int commentCount;
  final int likeCount;
  final DateTime? createdAt;

  factory QuestionPreviewModel.fromJson(Map<String, dynamic> json) {
    return QuestionPreviewModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String?,
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class QuestionDetailPostModel {
  const QuestionDetailPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.author,
    required this.qualificationCode,
    required this.qualificationName,
    required this.commentCount,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    required this.comments,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String? author;
  final String qualificationCode;
  final String? qualificationName;
  final int commentCount;
  final int likeCount;
  final int viewCount;
  final DateTime? createdAt;
  final List<CommunityCommentModel> comments;

  factory QuestionDetailPostModel.fromJson(Map<String, dynamic> json) {
    return QuestionDetailPostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String?,
      qualificationCode: json['qualificationCode'] as String? ?? '',
      qualificationName: json['qualificationName'] as String?,
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                CommunityCommentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ReviewPreviewModel {
  const ReviewPreviewModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.author,
    required this.studyPeriodText,
    required this.tipSummary,
    required this.likeCount,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String? author;
  final String? studyPeriodText;
  final String? tipSummary;
  final int likeCount;
  final DateTime? createdAt;

  factory ReviewPreviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewPreviewModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String?,
      studyPeriodText: json['studyPeriodText'] as String?,
      tipSummary: json['tipSummary'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }
}

class ReviewDetailPostModel {
  const ReviewDetailPostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.author,
    required this.qualificationCode,
    required this.qualificationName,
    required this.studyPeriodText,
    required this.tipSummary,
    required this.commentCount,
    required this.likeCount,
    required this.viewCount,
    required this.createdAt,
    required this.comments,
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final String? author;
  final String qualificationCode;
  final String? qualificationName;
  final String? studyPeriodText;
  final String? tipSummary;
  final int commentCount;
  final int likeCount;
  final int viewCount;
  final DateTime? createdAt;
  final List<CommunityCommentModel> comments;

  factory ReviewDetailPostModel.fromJson(Map<String, dynamic> json) {
    return ReviewDetailPostModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      author: json['author'] as String?,
      qualificationCode: json['qualificationCode'] as String? ?? '',
      qualificationName: json['qualificationName'] as String?,
      studyPeriodText: json['studyPeriodText'] as String?,
      tipSummary: json['tipSummary'] as String?,
      commentCount: json['commentCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      comments: (json['comments'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                CommunityCommentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

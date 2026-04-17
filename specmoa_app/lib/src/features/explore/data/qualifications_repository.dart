import 'package:specmoa_app/src/core/api/api_client.dart';
import 'package:specmoa_app/src/features/explore/data/qualification_models.dart';

class QualificationsRepository {
  QualificationsRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<QualificationTab>> fetchTabs() async {
    final json = await _apiClient.getJson('/qualifications/categories/tabs');
    final tabs = (json['tabs'] as List<dynamic>? ?? [])
        .map((item) => QualificationTab.fromJson(item as Map<String, dynamic>))
        .toList();
    return tabs;
  }

  Future<List<QualificationCardModel>> fetchQualifications({
    String? query,
    String? qualgbcd,
  }) async {
    final json = await _apiClient.getJson(
      '/qualifications',
      queryParameters: {
        'sortBy': 'recommended',
        if (query != null && query.isNotEmpty) 'q': query,
        if (qualgbcd != null && qualgbcd != 'ALL') 'qualgbcd': qualgbcd,
      },
    );

    final items = (json['items'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              QualificationCardModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    return items;
  }

  Future<QualificationDetailModel> fetchQualificationDetail(String code) async {
    final json = await _apiClient.getJson('/qualifications/$code');
    return QualificationDetailModel.fromJson(json);
  }

  Future<List<QuestionPreviewModel>> fetchQuestions(
    String qualificationCode,
  ) async {
    final json = await _apiClient.getJson(
      '/questions',
      queryParameters: {'qualificationCode': qualificationCode},
    );

    return (json['items'] as List<dynamic>? ?? [])
        .map(
          (item) =>
              QuestionPreviewModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<QuestionDetailPostModel> fetchQuestionDetail(String id) async {
    final json = await _apiClient.getJson('/questions/$id');
    return QuestionDetailPostModel.fromJson(json);
  }

  Future<void> createQuestion({
    required String userId,
    required String qualificationCode,
    required String title,
    required String content,
  }) async {
    await _apiClient.postJson(
      '/questions',
      body: {
        'userId': userId,
        'qualificationCode': qualificationCode,
        'title': title,
        'content': content,
      },
    );
  }

  Future<void> addQuestionComment({
    required String questionId,
    required String userId,
    required String content,
  }) async {
    await _apiClient.postJson(
      '/questions/$questionId/comments',
      body: {
        'userId': userId,
        'content': content,
      },
    );
  }

  Future<void> updateQuestion({
    required String id,
    required String title,
    required String content,
  }) async {
    await _apiClient.patchJson(
      '/questions/$id',
      body: {
        'title': title,
        'content': content,
      },
    );
  }

  Future<void> deleteQuestion(String id) async {
    await _apiClient.deleteJson('/questions/$id');
  }

  Future<List<ReviewPreviewModel>> fetchReviews(
    String qualificationCode,
  ) async {
    final json = await _apiClient.getJson(
      '/reviews',
      queryParameters: {'qualificationCode': qualificationCode},
    );

    return (json['items'] as List<dynamic>? ?? [])
        .map(
          (item) => ReviewPreviewModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<ReviewDetailPostModel> fetchReviewDetail(String id) async {
    final json = await _apiClient.getJson('/reviews/$id');
    return ReviewDetailPostModel.fromJson(json);
  }

  Future<void> createReview({
    required String userId,
    required String qualificationCode,
    required String title,
    required String content,
    String? studyPeriodText,
    String? tipSummary,
  }) async {
    await _apiClient.postJson(
      '/reviews',
      body: {
        'userId': userId,
        'qualificationCode': qualificationCode,
        'title': title,
        'content': content,
        if (studyPeriodText != null && studyPeriodText.isNotEmpty)
          'studyPeriodText': studyPeriodText,
        if (tipSummary != null && tipSummary.isNotEmpty)
          'tipSummary': tipSummary,
      },
    );
  }

  Future<void> addReviewComment({
    required String reviewId,
    required String userId,
    required String content,
  }) async {
    await _apiClient.postJson(
      '/reviews/$reviewId/comments',
      body: {
        'userId': userId,
        'content': content,
      },
    );
  }

  Future<void> updateReview({
    required String id,
    required String title,
    required String content,
    String? studyPeriodText,
    String? tipSummary,
  }) async {
    await _apiClient.patchJson(
      '/reviews/$id',
      body: {
        'title': title,
        'content': content,
        'studyPeriodText': studyPeriodText,
        'tipSummary': tipSummary,
      },
    );
  }

  Future<void> deleteReview(String id) async {
    await _apiClient.deleteJson('/reviews/$id');
  }
}

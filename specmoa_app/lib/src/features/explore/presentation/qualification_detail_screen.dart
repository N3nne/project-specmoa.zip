import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/auth/presentation/login_screen.dart';
import 'package:specmoa_app/src/features/explore/data/qualification_models.dart';
import 'package:specmoa_app/src/features/explore/data/qualifications_repository.dart';
import 'package:specmoa_app/src/features/explore/presentation/question_detail_screen.dart';
import 'package:specmoa_app/src/features/explore/presentation/review_detail_screen.dart';

class QualificationDetailScreen extends StatefulWidget {
  const QualificationDetailScreen({
    required this.qualificationCode,
    super.key,
  });

  final String qualificationCode;

  @override
  State<QualificationDetailScreen> createState() =>
      _QualificationDetailScreenState();
}

class _QualificationDetailScreenState extends State<QualificationDetailScreen> {
  final QualificationsRepository _repository = QualificationsRepository();
  final SessionRepository _sessionRepository = SessionRepository();

  AppUser? _user;
  QualificationDetailModel? _detail;
  List<QuestionPreviewModel> _questions = const [];
  List<ReviewPreviewModel> _reviews = const [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = _sessionRepository.currentUser;
      final detail = await _repository.fetchQualificationDetail(
        widget.qualificationCode,
      );
      final questions = await _repository.fetchQuestions(widget.qualificationCode);
      final reviews = await _repository.fetchReviews(widget.qualificationCode);

      if (!mounted) return;
      setState(() {
        _user = user;
        _detail = detail;
        _questions = questions;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '자격증 상세 정보를 불러오지 못했습니다.';
      });
    }
  }

  Future<bool> _ensureLoggedIn() async {
    if (_sessionRepository.isAuthenticated) {
      _user = _sessionRepository.currentUser;
      return true;
    }

    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => const LoginScreen(
          redirectToAppShellOnSuccess: false,
          showSkipButton: true,
        ),
      ),
    );

    if (loggedIn == true) {
      await _load();
      return true;
    }

    if (!mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('작성 기능은 로그인 후 사용할 수 있어요.')),
    );
    return false;
  }

  Future<void> _createQuestion() async {
    final canContinue = await _ensureLoggedIn();
    if (!canContinue || !mounted) return;

    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('질문 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '질문 내용',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('등록'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true || _user == null) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      _showSnackBar('제목과 내용을 모두 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.createQuestion(
        userId: _user!.id,
        qualificationCode: widget.qualificationCode,
        title: title,
        content: content,
      );
      await _load();
      _showSnackBar('질문이 등록되었습니다.');
    } catch (_) {
      _showSnackBar('질문 등록에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _createReview() async {
    final canContinue = await _ensureLoggedIn();
    if (!canContinue || !mounted) return;

    final titleController = TextEditingController();
    final periodController = TextEditingController();
    final tipController = TextEditingController();
    final contentController = TextEditingController();

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('후기 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: '제목'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodController,
                  decoration: const InputDecoration(
                    labelText: '준비 기간',
                    hintText: '예: 2개월',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tipController,
                  decoration: const InputDecoration(labelText: '한줄 팁'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: '후기 내용',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('등록'),
            ),
          ],
        );
      },
    );

    if (shouldSubmit != true || _user == null) return;

    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      _showSnackBar('제목과 내용을 모두 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _repository.createReview(
        userId: _user!.id,
        qualificationCode: widget.qualificationCode,
        title: title,
        content: content,
        studyPeriodText: periodController.text.trim(),
        tipSummary: tipController.text.trim(),
      );
      await _load();
      _showSnackBar('후기가 등록되었습니다.');
    } catch (_) {
      _showSnackBar('후기 등록에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openQuestionDetail(String questionId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => QuestionDetailScreen(questionId: questionId),
      ),
    );
    await _load();
  }

  Future<void> _openReviewDetail(String reviewId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => ReviewDetailScreen(reviewId: reviewId),
      ),
    );
    await _load();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _difficultyLabel(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return '미설정';
    }
  }

  String _studyLabel(int? expectedStudyMinutes) {
    if (expectedStudyMinutes == null || expectedStudyMinutes <= 0) {
      return '예상 학습 시간 정보 없음';
    }

    final hours = expectedStudyMinutes ~/ 60;
    final minutes = expectedStudyMinutes % 60;

    if (hours == 0) return '$minutes분 예상';
    if (minutes == 0) return '$hours시간 예상';
    return '$hours시간 $minutes분 예상';
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '날짜 정보 없음';
    return '${value.month}월 ${value.day}일';
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

    return Scaffold(
      appBar: AppBar(title: const Text('자격증 상세')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (detail != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _TagChip(label: detail.qualificationTypeName),
                          _TagChip(label: detail.seriesName),
                          _TagChip(label: _difficultyLabel(detail.difficulty)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('자격증 코드: ${detail.code}'),
                      const SizedBox(height: 6),
                      Text('분야: ${detail.primaryFieldName ?? '-'}'),
                      const SizedBox(height: 6),
                      Text('세부 분야: ${detail.secondaryFieldName ?? '-'}'),
                      const SizedBox(height: 6),
                      Text(_studyLabel(detail.expectedStudyMinutes)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('관련 질문', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _isSubmitting ? null : _createQuestion,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(_user == null ? '로그인 후 작성' : '질문 쓰기'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_questions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('아직 등록된 질문이 없습니다.'),
                  ),
                )
              else
                ..._questions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        onTap: () => _openQuestionDetail(item.id),
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(item.title),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('댓글 ${item.commentCount}'),
                            const SizedBox(height: 4),
                            Text(_formatDate(item.createdAt)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('합격 후기', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _isSubmitting ? null : _createReview,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: Text(_user == null ? '로그인 후 작성' : '후기 쓰기'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_reviews.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('아직 등록된 후기가 없습니다.'),
                  ),
                )
              else
                ..._reviews.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        onTap: () => _openReviewDetail(item.id),
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(item.title),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            item.tipSummary ?? item.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(item.studyPeriodText ?? '-'),
                            const SizedBox(height: 4),
                            Text(_formatDate(item.createdAt)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4B63FF),
        ),
      ),
    );
  }
}



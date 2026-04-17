import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/explore/data/qualification_models.dart';
import 'package:specmoa_app/src/features/explore/data/qualifications_repository.dart';

class ReviewDetailScreen extends StatefulWidget {
  const ReviewDetailScreen({required this.reviewId, super.key});

  final String reviewId;

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final QualificationsRepository _repository = QualificationsRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final TextEditingController _commentController = TextEditingController();

  AppUser? _user;
  ReviewDetailPostModel? _detail;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _sessionRepository.ensureDemoUser();
      final detail = await _repository.fetchReviewDetail(widget.reviewId);

      if (!mounted) return;
      setState(() {
        _user = user;
        _detail = detail;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '후기를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _submitComment() async {
    if (_user == null) return;

    final content = _commentController.text.trim();
    if (content.isEmpty) {
      _showSnackBar('댓글 내용을 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repository.addReviewComment(
        reviewId: widget.reviewId,
        userId: _user!.id,
        content: content,
      );
      _commentController.clear();
      await _load();
      _showSnackBar('댓글이 등록되었습니다.');
    } catch (_) {
      _showSnackBar('댓글 등록에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _editReview(ReviewDetailPostModel item) async {
    final titleController = TextEditingController(text: item.title);
    final periodController = TextEditingController(text: item.studyPeriodText ?? '');
    final tipController = TextEditingController(text: item.tipSummary ?? '');
    final contentController = TextEditingController(text: item.content);

    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('후기 수정'),
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
                decoration: const InputDecoration(labelText: '준비 기간'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tipController,
                decoration: const InputDecoration(labelText: '한줄 팁'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 6,
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
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (shouldSubmit != true) return;

    setState(() => _isSubmitting = true);
    try {
      await _repository.updateReview(
        id: item.id,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        studyPeriodText: periodController.text.trim(),
        tipSummary: tipController.text.trim(),
      );
      await _load();
      _showSnackBar('후기가 수정되었습니다.');
    } catch (_) {
      _showSnackBar('후기 수정에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteReview(ReviewDetailPostModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('후기 삭제'),
        content: const Text('이 후기를 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      await _repository.deleteReview(item.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      _showSnackBar('후기 삭제에 실패했습니다.');
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '날짜 정보 없음';
    return '${value.year}.${value.month.toString().padLeft(2, '0')}.${value.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final isMine = detail != null && _user?.id == detail.userId;

    return Scaffold(
      appBar: AppBar(title: const Text('후기 상세')),
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
                        detail.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(label: detail.qualificationName ?? '자격증'),
                          _InfoChip(label: '좋아요 ${detail.likeCount}'),
                          _InfoChip(label: '댓글 ${detail.commentCount}'),
                          _InfoChip(label: '조회 ${detail.viewCount}'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${detail.author ?? '익명'} · ${_formatDate(detail.createdAt)}',
                        style: const TextStyle(color: Color(0xFF6F7896)),
                      ),
                      const SizedBox(height: 18),
                      if ((detail.studyPeriodText ?? '').isNotEmpty) ...[
                        Text(
                          '준비 기간: ${detail.studyPeriodText}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                      ],
                      if ((detail.tipSummary ?? '').isNotEmpty) ...[
                        const Text(
                          '한줄 팁',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(detail.tipSummary!),
                        const SizedBox(height: 14),
                      ],
                      Text(
                        detail.content,
                        style: const TextStyle(height: 1.6),
                      ),
                      if (isMine) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _editReview(detail),
                                child: const Text('수정'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () => _deleteReview(detail),
                                child: const Text('삭제'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('댓글', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (detail.comments.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('아직 댓글이 없습니다. 첫 댓글을 남겨보세요.'),
                  ),
                )
              else
                ...detail.comments.map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.author ?? '익명',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(comment.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6F7896),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              comment.content,
                              style: const TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '댓글 작성',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: '후기에 대한 의견이나 질문을 남겨보세요.',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submitComment,
                          child: const Text('댓글 등록'),
                        ),
                      ),
                    ],
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF55607A),
        ),
      ),
    );
  }
}

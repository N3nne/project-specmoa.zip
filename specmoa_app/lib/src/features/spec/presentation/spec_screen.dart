import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/explore/data/qualification_models.dart';
import 'package:specmoa_app/src/features/explore/data/qualifications_repository.dart';
import 'package:specmoa_app/src/features/spec/data/spec_models.dart';
import 'package:specmoa_app/src/features/spec/data/spec_repository.dart';
import 'package:specmoa_app/src/shared/widgets/gradient_header.dart';

class SpecScreen extends StatefulWidget {
  const SpecScreen({super.key});

  @override
  State<SpecScreen> createState() => _SpecScreenState();
}

class _SpecScreenState extends State<SpecScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final SpecRepository _specRepository = SpecRepository();
  final QualificationsRepository _qualificationsRepository =
      QualificationsRepository();

  AppUser? _user;
  List<MySpecItem> _items = const [];
  bool _isLoading = true;
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
      final user = await _sessionRepository.ensureDemoUser();
      final items = await _specRepository.fetchMySpecs(user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '내 자격증 목록을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _showAddQualificationDialog() async {
    try {
      final qualifications = await _qualificationsRepository.fetchQualifications();
      if (!mounted) return;

      final previewItems = qualifications.take(20).toList();
      final selected = await showModalBottomSheet<QualificationCardModel>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) {
          return SafeArea(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemBuilder: (context, index) {
                final item = previewItems[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.name),
                  subtitle: Text(
                    item.seriesName.isEmpty
                        ? item.qualificationTypeName
                        : item.seriesName,
                  ),
                  trailing: const Icon(Icons.add_circle_outline),
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemCount: previewItems.length,
            ),
          );
        },
      );

      if (selected == null || _user == null) {
        return;
      }

      await _specRepository.addMySpec(
        userId: _user!.id,
        qualificationCode: selected.code,
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '자격증을 추가하지 못했습니다.',
          ),
        ),
      );
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'not_started':
        return '시작 전';
      case 'in_progress':
        return '학습 중';
      case 'completed':
        return '완료';
      case 'preparing':
      default:
        return '준비 중';
    }
  }

  String _studyLabel(int totalStudyMinutes) {
    if (totalStudyMinutes >= 60) {
      final hours = totalStudyMinutes ~/ 60;
      return '$hours시간 학습';
    }
    return '$totalStudyMinutes분 학습';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientHeader(
          title: _user == null
              ? '내 스펙'
              : '${_user!.displayName}님의 스펙',
          subtitle:
              '등록한 자격증과 학습 현황을 한눈에 확인해요',
        ),
        Expanded(
          child: RefreshIndicator(
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
                else ...[
                  if (_items.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '아직 등록된 자격증이 없어요.',
                        ),
                      ),
                    )
                  else
                    ..._items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE9EDFF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        item.dDay == null
                                            ? '시험일 미정'
                                            : 'D-${item.dDay}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF4B63FF),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      _statusLabel(item.status),
                                      style: const TextStyle(
                                        color: Color(0xFF7A7EA3),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  item.qualificationName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _studyLabel(item.totalStudyMinutes),
                                  style: const TextStyle(
                                    color: Color(0xFF6A7195),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _showAddQualificationDialog,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      '자격증 추가하기',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

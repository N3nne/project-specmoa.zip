import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/home/data/home_models.dart';
import 'package:specmoa_app/src/features/home/data/home_repository.dart';
import 'package:specmoa_app/src/shared/widgets/gradient_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final HomeRepository _homeRepository = HomeRepository();

  AppUser? _user;
  HomeResponse? _home;
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
      final home = await _homeRepository.fetchHome(user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _home = home;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '홈 화면 데이터를 불러오지 못했습니다.';
      });
    }
  }

  String _studyText(int totalStudyMinutes) {
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
          title: _user == null ? '안녕하세요!' : '${_user!.displayName}님, 안녕하세요!',
          subtitle: '오늘도 목표를 향해 차근차근 나아가보세요',
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
                else if (_home != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: '내 자격증',
                          value: _home!.summary.myQualificationCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: '완료',
                          value: _home!.summary.completedQualificationCount
                              .toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: '오늘',
                          value: '${_home!.summary.todayStudyMinutes}m',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('내 자격증', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_home!.myQualifications.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 등록된 자격증이 없어요.'),
                      ),
                    )
                  else
                    ..._home!.myQualifications.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(item.qualificationName),
                            subtitle: Text(_studyText(item.totalStudyMinutes)),
                            trailing: Text(
                              item.dDay == null ? '시험일 미정' : 'D-${item.dDay}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4B63FF),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('인기 질문', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_home!.popularQuestions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 인기 질문이 없어요.'),
                      ),
                    )
                  else
                    ..._home!.popularQuestions.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(item.title),
                            subtitle: Text(item.qualificationName),
                            trailing: Text('댓글 ${item.commentCount}'),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text('합격 후기', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (_home!.passReviews.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 합격 후기가 없어요.'),
                      ),
                    )
                  else
                    ..._home!.passReviews.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(item.title),
                            subtitle: Text(
                              item.tipSummary ?? item.qualificationName,
                            ),
                            trailing: Text(item.studyPeriodText ?? '-'),
                          ),
                        ),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Color(0xFF6F7896))),
          ],
        ),
      ),
    );
  }
}

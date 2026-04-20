import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/auth/presentation/login_screen.dart';
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
  bool _isGuest = false;
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
      final user = _sessionRepository.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _user = null;
          _home = null;
          _isGuest = true;
          _isLoading = false;
        });
        return;
      }

      final home = await _homeRepository.fetchHome(user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _home = home;
        _isGuest = false;
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

  Future<void> _openLogin() async {
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
    final home = _home;

    return Column(
      children: [
        GradientHeader(
          title: _user == null ? '안녕하세요' : '${_user!.displayName}님 안녕하세요',
          subtitle: '오늘도 목표를 향해 차근차근 나아가보세요.',
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
                else if (_isGuest) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '둘러보기 모드',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '탐색과 커뮤니티 열람은 계속 사용할 수 있어요. 내 스펙, 타이머, 마이페이지를 쓰려면 로그인해 주세요.',
                            style: TextStyle(
                              color: Color(0xFF66708D),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _openLogin,
                            icon: const Icon(Icons.login),
                            label: const Text('로그인하러 가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '게스트로 가능한 기능',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text('? 자격증 탐색과 상세 보기'),
                          SizedBox(height: 8),
                          Text('? 질문/후기 읽기와 댓글 열람'),
                          SizedBox(height: 8),
                          Text('? 서비스 구조와 화면 둘러보기'),
                        ],
                      ),
                    ),
                  ),
                ]
                else if (home != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: '내 자격증',
                          value: home.summary.myQualificationCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: '완료',
                          value: home.summary.completedQualificationCount.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: '오늘',
                          value: '${home.summary.todayStudyMinutes}m',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('내 자격증', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (home.myQualifications.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 등록된 자격증이 없어요.'),
                      ),
                    )
                  else
                    ...home.myQualifications.map(
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
                  if (home.popularQuestions.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 인기 질문이 없어요.'),
                      ),
                    )
                  else
                    ...home.popularQuestions.map(
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
                  if (home.passReviews.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('아직 합격 후기가 없어요.'),
                      ),
                    )
                  else
                    ...home.passReviews.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(item.title),
                            subtitle: Text(item.tipSummary ?? item.qualificationName),
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
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7A84A4),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF33405F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



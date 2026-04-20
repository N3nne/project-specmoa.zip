import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/auth/presentation/login_screen.dart';
import 'package:specmoa_app/src/features/my/data/my_models.dart';
import 'package:specmoa_app/src/features/my/data/my_repository.dart';
import 'package:specmoa_app/src/shared/widgets/gradient_header.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key, this.onLoggedOut});

  final VoidCallback? onLoggedOut;

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final MyRepository _myRepository = MyRepository();

  AppUser? _user;
  MyResponse? _data;
  bool _isLoading = true;
  bool _isSaving = false;
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
          _data = null;
          _isLoading = false;
        });
        return;
      }

      final data = await _myRepository.fetchMy(user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _data = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '마이 화면 데이터를 불러오지 못했습니다.';
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

  Future<void> _logout() async {
    await _sessionRepository.logout();
    if (!mounted) return;
    widget.onLoggedOut?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그아웃되었습니다.')),
    );
    await _load();
  }

  Future<void> _updateGoal(int nextTargetHours) async {
    if (_user == null || _data == null || nextTargetHours <= 0) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _myRepository.updateWeeklyGoal(
        userId: _user!.id,
        targetHours: nextTargetHours,
        notificationEnabled: _data!.weeklyGoal.notificationEnabled,
      );
      await _load();
    } catch (_) {
      _showError('주간 목표 수정에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updateGoalNotification(bool enabled) async {
    if (_user == null || _data == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _myRepository.updateWeeklyGoal(
        userId: _user!.id,
        targetHours: _data!.weeklyGoal.targetHours,
        notificationEnabled: enabled,
      );
      await _load();
    } catch (_) {
      _showError('주간 목표 알림 수정에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _updatePushNotification(bool enabled) async {
    if (_user == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _myRepository.updateNotificationsSetting(
        userId: _user!.id,
        pushEnabled: enabled,
      );
      await _load();
    } catch (_) {
      _showError('푸시 알림 설정 수정에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatStudyTime(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '$minutes분';
    }

    if (minutes == 0) {
      return '$hours시간';
    }

    return '$hours시간 $minutes분';
  }

  String _formatActivity(RecentActivity item) {
    final minutes = (item.durationSeconds / 60).ceil();
    final startedAt = item.startedAt;
    final dateText = startedAt == null
        ? '기록 시간 없음'
        : '${startedAt.month}월 ${startedAt.day}일';
    return '$dateText · $minutes분 학습';
  }

  bool _pushEnabled(MyResponse data) {
    for (final setting in data.settings) {
      if (setting.key == 'notifications') {
        return setting.value['pushEnabled'] as bool? ?? false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Column(
      children: [
        const GradientHeader(
          title: '마이페이지',
          subtitle: '프로필, 주간 목표, 설정을 한곳에서 확인해요',
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
                else if (_user == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '로그인 후 사용할 수 있어요',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '마이페이지에서는 내 학습 통계, 주간 목표, 알림 설정을 관리할 수 있습니다.',
                            style: TextStyle(
                              color: Color(0xFF6F7896),
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
                  )
                else if (data != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE9EDFF),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              data.profile.displayName.isEmpty
                                  ? '?'
                                  : data.profile.displayName.characters.first,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4B63FF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.profile.displayName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level ${data.profile.level} · ${data.profile.streakDays}일 연속',
                                  style: const TextStyle(
                                    color: Color(0xFF6F7896),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  data.profile.email,
                                  style: const TextStyle(
                                    color: Color(0xFF8A90AE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: '총 학습 시간',
                          value: _formatStudyTime(data.stats.totalStudyMinutes),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: '획득 자격증',
                          value: '${data.stats.earnedCertificatesCount}개',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: '진행률',
                          value: '${data.stats.progressRate.toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '주간 목표',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _updateGoal(
                                          data.weeklyGoal.targetHours - 1,
                                        ),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '${data.weeklyGoal.targetHours}시간',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => _updateGoal(
                                          data.weeklyGoal.targetHours + 1,
                                        ),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (data.weeklyGoal.progressRate / 100)
                                .clamp(0.0, 1.0),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${data.weeklyGoal.achievedMinutes}분 달성 · ${data.weeklyGoal.progressRate}% 진행',
                            style: const TextStyle(color: Color(0xFF6F7896)),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            value: data.weeklyGoal.notificationEnabled,
                            onChanged: _isSaving ? null : _updateGoalNotification,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('주간 목표 알림'),
                            subtitle: const Text('목표 달성 페이스를 알려드려요'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '설정',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            value: _pushEnabled(data),
                            onChanged: _isSaving ? null : _updatePushNotification,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('푸시 알림'),
                            subtitle: const Text('학습 알림과 업데이트 소식을 받아보세요'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '최근 활동',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          if (data.recentActivity.isEmpty)
                            const Text('아직 기록된 활동이 없어요')
                          else
                            ...data.recentActivity.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.history,
                                      size: 18,
                                      color: Color(0xFF6F7896),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(_formatActivity(item))),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '업적',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          if (data.achievements.isEmpty)
                            const Text('아직 업적이 없어요')
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: data.achievements
                                  .map(
                                    (item) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F5FF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.value,
                                            style: const TextStyle(
                                              color: Color(0xFF6F7896),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: _isSaving ? null : _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('로그아웃'),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B84A4),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF33405F),
            ),
          ),
        ],
      ),
    );
  }
}



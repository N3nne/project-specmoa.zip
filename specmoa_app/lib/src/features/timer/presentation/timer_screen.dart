import 'dart:async';

import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/app_user.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/spec/data/spec_models.dart';
import 'package:specmoa_app/src/features/spec/data/spec_repository.dart';
import 'package:specmoa_app/src/features/timer/data/timer_models.dart';
import 'package:specmoa_app/src/features/timer/data/timer_repository.dart';
import 'package:specmoa_app/src/shared/widgets/gradient_header.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final SpecRepository _specRepository = SpecRepository();
  final TimerRepository _timerRepository = TimerRepository();

  AppUser? _user;
  List<MySpecItem> _specs = const [];
  StudySessionSummary _summary = const StudySessionSummary(
    sessionCount: 0,
    totalDurationSeconds: 0,
    totalDurationMinutes: 0,
  );
  MySpecItem? _selectedSpec;
  ActiveStudySession? _activeSession;
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _elapsedSeconds = 0;
  Timer? _ticker;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _sessionRepository.requireAuthenticatedUser();
      final specs = await _specRepository.fetchMySpecs(user.id);
      final summary = await _timerRepository.fetchTodaySummary(user.id);

      if (!mounted) return;
      setState(() {
        _user = user;
        _specs = specs;
        _summary = summary;
        _selectedSpec = specs.isNotEmpty
            ? specs.firstWhere(
                (item) => item.id == _selectedSpec?.id,
                orElse: () => specs.first,
              )
            : null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = '타이머 데이터를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _toggleTimer() async {
    if (_user == null || _selectedSpec == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      if (_activeSession == null) {
        final session = await _timerRepository.startSession(
          userId: _user!.id,
          userQualificationId: _selectedSpec!.id,
        );
        _ticker?.cancel();
        _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!mounted) return;
          setState(() {
            _elapsedSeconds += 1;
          });
        });

        if (!mounted) return;
        setState(() {
          _activeSession = session;
          _elapsedSeconds = 0;
        });
      } else {
        final sessionId = _activeSession!.id;
        await _timerRepository.stopSession(sessionId);
        _ticker?.cancel();
        _ticker = null;
        final summary = await _timerRepository.fetchTodaySummary(_user!.id);
        final specs = await _specRepository.fetchMySpecs(_user!.id);

        if (!mounted) return;
        setState(() {
          _activeSession = null;
          _elapsedSeconds = 0;
          _summary = summary;
          _specs = specs;
          _selectedSpec = specs.firstWhere(
            (item) => item.id == _selectedSpec?.id,
            orElse: () => specs.isNotEmpty ? specs.first : _selectedSpec!,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '타이머 세션을 처리하지 못했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const GradientHeader(
          title: '학습 타이머',
          subtitle: '자격증별 학습 시간을 기록하고 집중해보세요',
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
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpec?.id,
                    decoration: InputDecoration(
                      labelText: '자격증 선택',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _specs
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.qualificationName),
                          ),
                        )
                        .toList(),
                    onChanged: _activeSession != null
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedSpec = _specs.firstWhere(
                                (item) => item.id == value,
                              );
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF1F4FB),
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatDuration(_elapsedSeconds),
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF33405F),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _selectedSpec?.qualificationName ??
                                      '자격증을 선택해주세요',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF66708D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _isSubmitting || _selectedSpec == null
                                ? null
                                : _toggleTimer,
                            icon: Icon(
                              _activeSession == null
                                  ? Icons.play_arrow_rounded
                                  : Icons.stop_rounded,
                            ),
                            label: Text(
                              _activeSession == null ? '학습 시작' : '학습 종료',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 학습 시간',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          Text('세션 수: ${_summary.sessionCount}'),
                          const SizedBox(height: 8),
                          Text('총 학습 분: ${_summary.totalDurationMinutes}분'),
                          const SizedBox(height: 8),
                          Text(
                            '총 시간: ${_formatDuration(_summary.totalDurationSeconds)}',
                          ),
                        ],
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

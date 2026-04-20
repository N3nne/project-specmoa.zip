import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/features/auth/presentation/login_screen.dart';
import 'package:specmoa_app/src/features/explore/presentation/explore_screen.dart';
import 'package:specmoa_app/src/features/home/presentation/home_screen.dart';
import 'package:specmoa_app/src/features/my/presentation/my_screen.dart';
import 'package:specmoa_app/src/features/spec/presentation/spec_screen.dart';
import 'package:specmoa_app/src/features/timer/presentation/timer_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final SessionRepository _sessionRepository = SessionRepository();

  int _currentIndex = 0;
  int _refreshSeed = 0;

  bool _requiresAuthTab(int index) => index == 1 || index == 2 || index == 4;

  List<Widget> _buildScreens() {
    return [
      KeyedSubtree(
        key: ValueKey('home-$_refreshSeed'),
        child: const HomeScreen(),
      ),
      KeyedSubtree(
        key: ValueKey('spec-$_refreshSeed'),
        child: const SpecScreen(),
      ),
      KeyedSubtree(
        key: ValueKey('timer-$_refreshSeed'),
        child: const TimerScreen(),
      ),
      KeyedSubtree(
        key: ValueKey('explore-$_refreshSeed'),
        child: const ExploreScreen(),
      ),
      KeyedSubtree(
        key: ValueKey('my-$_refreshSeed'),
        child: MyScreen(onLoggedOut: _handleLoggedOut),
      ),
    ];
  }

  Future<void> _onDestinationSelected(int index) async {
    if (_requiresAuthTab(index) && !_sessionRepository.isAuthenticated) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => const LoginScreen(
            redirectToAppShellOnSuccess: false,
            showSkipButton: true,
          ),
        ),
      );

      if (!mounted) return;
      if (loggedIn == true) {
        setState(() {
          _refreshSeed += 1;
          _currentIndex = index;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 기능은 로그인 후 사용할 수 있어요.')),
        );
      }
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _handleLoggedOut() {
    if (!mounted) return;
    setState(() {
      _refreshSeed += 1;
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE9EDFF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: '내 스펙',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '타이머',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: '탐색',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }
}



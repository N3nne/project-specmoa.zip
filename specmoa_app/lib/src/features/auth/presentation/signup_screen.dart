import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/api/api_exception.dart';
import 'package:specmoa_app/src/core/session/session_repository.dart';
import 'package:specmoa_app/src/navigation/app_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    this.redirectToAppShellOnSuccess = true,
  });

  final bool redirectToAppShellOnSuccess;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _completeSignup() async {
    final displayName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error = '이름, 이메일, 비밀번호를 모두 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await _sessionRepository.signUp(
        displayName: displayName,
        email: email,
        password: password,
      );
      if (!mounted) return;
      if (widget.redirectToAppShellOnSuccess) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AppShell()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = '회원가입에 실패했습니다. 서버 연결 상태를 확인해주세요.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Container(
        color: const Color(0xFFF7F8FD),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '간단 회원가입',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '가입이 완료되면 바로 내 계정으로 앱을 사용할 수 있어요.',
                          style: TextStyle(
                            color: Color(0xFF6D7694),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _SignupField(
                          controller: _nameController,
                          label: '이름',
                          hintText: '이름을 입력하세요',
                        ),
                        const SizedBox(height: 16),
                        _SignupField(
                          controller: _emailController,
                          label: '이메일',
                          hintText: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _SignupField(
                          controller: _passwordController,
                          label: '비밀번호',
                          hintText: '6자 이상 입력하세요',
                          obscureText: true,
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _error!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _completeSignup,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(_isSubmitting ? '가입 중...' : '가입하기'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B4563),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF8F9FE),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:specmoa_app/src/core/theme/app_theme.dart';
import 'package:specmoa_app/src/navigation/app_shell.dart';

class SpecmoaApp extends StatelessWidget {
  const SpecmoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '스펙모아',
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}

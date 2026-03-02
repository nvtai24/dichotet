import 'package:flutter/material.dart';
import 'core/constants/app_theme.dart';
import 'views/splash/splash_screen.dart';

void main() {
  runApp(const DichotetApp());
}

class DichotetApp extends StatelessWidget {
  const DichotetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đi chợ Tết',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/theme.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LottoLEE',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.dancingScriptTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/', // 초기 라우트를 스플래시 스크린으로 설정
      routes: {
        '/': (context) => const SplashScreen(), // 스플래시 스크린
        '/main': (context) => const MainScreen(), // 메인 스크린
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

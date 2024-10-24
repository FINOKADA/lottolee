import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color.fromRGBO(109, 56, 233, 1); // 메인
  static const Color secondary = Color(0xFFFFB6C1); // 보조 핑크

  // Background Colors
  static const Color background = Colors.white; // 배경색
  static const Color surface = Colors.white; // 표면색

  // Text Colors
  static const Color textPrimary = Color.fromRGBO(109, 56, 233, 1); // 주요 텍스트
  static const Color textSecondary = Colors.grey; // 보조 텍스트

  // Icon Colors
  static const Color iconPrimary = Color.fromRGBO(109, 56, 233, 1); // 주요 아이콘
  static const Color iconSecondary = Colors.grey; // 보조 아이콘

  // Navigation Bar Colors
  static const Color navSelected =
      Color.fromRGBO(109, 56, 233, 1); // 선택된 네비게이션 아이템
  static const Color navUnselected = Colors.grey; // 선택되지 않은 네비게이션 아이템

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color.fromRGBO(109, 56, 233, 1),
    Color(0xFFFFB6C1),
  ];
}

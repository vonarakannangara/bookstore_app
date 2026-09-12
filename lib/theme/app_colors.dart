import 'package:flutter/material.dart';

class AppColors {
  static const Color darkBlue = Color(0xFF01579B);
  static const Color aqua = Color(0xFF00ACC1);
  static const Color lightBlue = Color(0xFFE0F7FA);
  static const Color pink = Color(0xFFEC407A);

  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, pink],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBlue, aqua, lightBlue],
  );
}
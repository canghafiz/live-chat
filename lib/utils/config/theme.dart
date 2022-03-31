import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

class ThemeConfig {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      fontFamily: FontConfig.family,
      colorScheme: const ColorScheme.light().copyWith(
        primary: ColorConfig.colorPrimary,
        secondary: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      fontFamily: FontConfig.family,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: ColorConfig.colorPrimary,
        secondary: Colors.white,
      ),
    );
  }
}

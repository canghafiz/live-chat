import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FontConfig {
  static const family = 'Poppins';

  static bold({
    required double size,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size.sp,
      color: color,
      fontWeight: FontWeight.bold,
    );
  }

  static semibold({
    required double size,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size.sp,
      color: color,
      fontWeight: FontWeight.w600,
    );
  }

  static medium({
    required double size,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size.sp,
      color: color,
      fontWeight: FontWeight.w500,
    );
  }

  static light({
    required double size,
    required Color color,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size.sp,
      color: color,
      fontWeight: FontWeight.w300,
    );
  }
}

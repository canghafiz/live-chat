import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

void showCustomSnackbar({
  required BuildContext context,
  required String text,
  required Color color,
  int? duration,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: FontConfig.medium(size: 14, color: Colors.white),
      ),
      backgroundColor: color,
      duration: Duration(seconds: duration ?? 3),
    ),
  );
}

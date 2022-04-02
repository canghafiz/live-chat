import 'package:flutter/material.dart';

Widget callButtonWidget({
  required Function onTap,
  required IconData icon,
  Color? color,
}) {
  return IconButton(
    onPressed: () => onTap(),
    icon: Icon(icon, color: color ?? Colors.white, size: 36),
  );
}

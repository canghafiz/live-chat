import 'package:flutter/material.dart';

Widget callButtonWidget({
  required Function onTap,
  required IconData icon,
}) {
  return IconButton(
    onPressed: () => onTap(),
    icon: Icon(icon, color: Colors.white, size: 36),
  );
}

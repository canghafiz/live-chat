import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

Widget messageDialog({
  required String message,
  required Color textColor,
  required Icon? icon,
}) {
  return Dialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? const SizedBox(),
          SizedBox(height: (icon == null) ? 0 : 4),
          Text(
            message,
            style: FontConfig.medium(size: 14, color: textColor),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    ),
  );
}

Widget justDialog(Widget content) {
  return Dialog(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: content,
    ),
  );
}

Widget deleteDialog(Function onDelete) {
  return Dialog(
    backgroundColor: Colors.transparent,
    child: ElevatedButton(
      onPressed: () => onDelete(),
      child: const Text("Delete"),
      style: ElevatedButton.styleFrom(
        onPrimary: Colors.white,
        primary: ColorConfig.colorPrimary,
      ),
    ),
  );
}

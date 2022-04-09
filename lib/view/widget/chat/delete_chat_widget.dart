import 'package:flutter/material.dart';

Widget deleteChatWidget(Function onTap) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.all(16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
    ),
    child: ElevatedButton(
      onPressed: () => onTap(),
      child: const Text("Delete Chat"),
    ),
  );
}

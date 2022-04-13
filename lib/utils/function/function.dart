import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:live_chat/utils/const/variable.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FunctionUtils {
  static bool emailValidator(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static String timeCalculate(
    String time,
  ) {
    var convert = DateTime.parse(time);
    var now =
        DateTime.parse(DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()));

    if (now.difference(convert).inDays < 7) {
      return Jiffy(time, "yyyy-MM-dd HH:mm").fromNow();
    }

    return Jiffy(time).yMMMEd;
  }

  static String chatTimeCalculate(String time) {
    var convert = DateTime.parse(time);
    var now =
        DateTime.parse(DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now()));

    if (now.difference(convert).inDays == 0) {
      return "Today";
    }

    if (now.difference(convert).inDays == 1) {
      return "Yesterday";
    }

    return Jiffy(time).yMMMMd;
  }

  static void showCustomBottomSheet({
    required BuildContext context,
    required Widget content,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) => content,
    );
  }

  static Future<String> recorderFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    return storageDirectory.path + "/record.mp3";
  }

  static String callProcess(CallProcess value) {
    switch (value) {
      case CallProcess.undoing:
        return "Undoing";
      case CallProcess.calling:
        return "Calling";
      case CallProcess.accept:
        return "Accept";
      case CallProcess.reject:
        return "Reject";
      default:
        return "Done";
    }
  }
}

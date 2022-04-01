import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

Widget flatButton({
  required double marginLeft,
  required double marginTop,
  required double marginRight,
  required double marginBottom,
  required Function onPress,
  required String text,
  required Color fontColor,
  required Color btnColor,
  required double width,
  required double height,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(
      marginLeft,
      marginTop,
      marginRight,
      marginBottom,
    ),
    child: ElevatedButton(
      onPressed: () => onPress(),
      child: Text(
        text,
        style: FontConfig.medium(size: 16, color: fontColor),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(width, height),
        maximumSize: Size(width, height),
        primary: btnColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
      ),
    ),
  );
}

Widget circularButton({
  required double size,
  required IconData icon,
  required Function onTap,
}) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ColorConfig.colorPrimary,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

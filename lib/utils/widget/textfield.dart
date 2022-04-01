import 'package:flutter/material.dart';
import 'package:live_chat/utils/config/color.dart';

Widget textformfield({
  required double left,
  required double top,
  required double right,
  required double bottom,
  required TextEditingController controller,
  required TextInputType type,
  bool? autoFocus,
  required bool obscure,
  TextStyle? style,
  required Function(String?)? validator,
  required Function(String?)? onChanged,
  Widget? prefix,
  Widget? suffix,
  required String? hintText,
  TextStyle? hintStyle,
  required bool? filled,
}) {
  return Padding(
    padding: EdgeInsets.fromLTRB(left, top, right, bottom),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      autofocus: autoFocus ?? false,
      obscureText: obscure,
      style: style,
      validator: (validator == null) ? null : (value) => validator(value),
      onChanged: (onChanged == null) ? null : (value) => onChanged(value),
      decoration: InputDecoration(
        prefixIcon: prefix,
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: hintStyle,
        fillColor: Colors.white,
        filled: filled,
        contentPadding: const EdgeInsets.all(12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: ColorConfig.colorPrimary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: ColorConfig.colorPrimary),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          borderSide: BorderSide(color: ColorConfig.colorPrimary, width: 2),
        ),
      ),
    ),
  );
}

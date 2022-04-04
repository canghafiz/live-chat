import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';

class EditFormWidget extends StatefulWidget {
  const EditFormWidget({
    Key? key,
    required this.inputType,
    required this.title,
    required this.intialValue,
    required this.onSubmit,
    required this.inputFormater,
  }) : super(key: key);
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormater;
  final String title, intialValue;
  final Function(String) onSubmit;

  @override
  State<EditFormWidget> createState() => _EditFormWidgetState();
}

class _EditFormWidgetState extends State<EditFormWidget> {
  final formKey = GlobalKey<FormState>();

  // Controller
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  VariableConst.margin,
                  24,
                  VariableConst.margin,
                  0,
                ),
                child: TextFormField(
                  keyboardType: widget.inputType,
                  inputFormatters: widget.inputFormater,
                  maxLength: 75,
                  controller: controller..text = widget.intialValue,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "${widget.title} cannot be empty";
                    }
                    return null;
                  },
                  style: FontConfig.medium(
                    size: 14,
                    color: (isDark) ? Colors.white : ColorConfig.colorDark,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    labelText: widget.title,
                    labelStyle: FontConfig.medium(
                      size: 12,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: (isDark) ? Colors.white : ColorConfig.colorDark,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: (isDark) ? Colors.white : ColorConfig.colorDark,
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: (isDark) ? Colors.white : ColorConfig.colorDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                0,
                VariableConst.margin,
                VariableConst.margin,
                MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        widget.onSubmit.call(controller.text);
                      }
                    },
                    child: Text(
                      "Save",
                      style: FontConfig.medium(
                        size: 14,
                        color: ColorConfig.colorPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Cancel",
                      style: FontConfig.medium(
                        size: 14,
                        color: ColorConfig.colorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

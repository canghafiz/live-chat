import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({
    Key? key,
    required this.yourId,
  }) : super(key: key);
  final String yourId;

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final formKey = GlobalKey<FormState>();

  // Controller
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.arrow_forward, color: Colors.white),
          backgroundColor: ColorConfig.colorPrimary,
        ),
        appBar: AppBar(
          title: Text(
            'Create Group',
            style: FontConfig.medium(size: 20, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: (isDark) ? ColorConfig.colorDark : Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Photo
                SizedBox(
                  width: 124,
                  height: 124,
                  child: Stack(
                    children: [
                      // Photo
                      GestureDetector(
                        onTap: () {},
                        child: const BasicPhotoProfile(
                          size: 124,
                          url: null,
                        ),
                      ),
                      // Btn Take
                      GestureDetector(
                        onTap: () {},
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorConfig.colorPrimary,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Form
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VariableConst.margin,
                      vertical: 24,
                    ),
                    child: TextFormField(
                      maxLength: 75,
                      controller: controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name cannot be empty";
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
                        labelText: "Name",
                        labelStyle: FontConfig.medium(
                          size: 12,
                          color: Colors.grey,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Members
                GroupMembers(
                  userId: widget.yourId,
                  showTotalMembers: true,
                  isDark: isDark,
                  groupId: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

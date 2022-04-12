import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/auth/auth_service.dart';
import 'package:live_chat/utils/export_utils.dart';

import '../../../cubit/export_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Form
  final formKey = GlobalKey<FormState>();

  // Controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          "Looks like you don’t have an account.Let’s create account for you",
          style: FontConfig.medium(size: 14, color: ColorConfig.colorDark),
        ),
        // Form
        Form(
          key: formKey,
          child: Column(
            children: [
              // Name
              textformfield(
                left: 0,
                top: 18,
                right: 0,
                bottom: 18,
                controller: nameController,
                type: TextInputType.name,
                obscure: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Name cannot be empty';
                  }
                },
                onChanged: null,
                hintText: 'Name',
                filled: true,
                style: FontConfig.light(
                  size: 12,
                  color: ColorConfig.colorDark,
                ),
                hintStyle: FontConfig.light(
                  size: 12,
                  color: ColorConfig.colorDark,
                ),
              ),
              // Email
              textformfield(
                left: 0,
                top: 0,
                right: 0,
                bottom: 18,
                controller: emailController,
                type: TextInputType.emailAddress,
                obscure: false,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  bool emailValid = FunctionUtils.emailValidator(value);

                  if (!emailValid) {
                    return 'Email is invalid';
                  }
                },
                onChanged: null,
                hintText: 'Email',
                filled: true,
                style: FontConfig.light(
                  size: 12,
                  color: ColorConfig.colorDark,
                ),
                hintStyle: FontConfig.light(
                  size: 12,
                  color: ColorConfig.colorDark,
                ),
              ),
              // Password
              BlocSelector<PasswordCubit, PasswordState, bool>(
                selector: (state) => state.isShow,
                builder: (context, state) => textformfield(
                  left: 0,
                  top: 0,
                  right: 0,
                  bottom: 36,
                  controller: pwController,
                  type: TextInputType.visiblePassword,
                  obscure: !state,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Pasword cannot be empty';
                    }
                  },
                  onChanged: null,
                  hintText: 'Password',
                  filled: true,
                  suffix: SizedBox(
                    width: 24,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          PasswordCubitHandle.read(context).update();
                        },
                        child: Text(
                          (!state) ? 'View' : 'Hide',
                          style: FontConfig.bold(
                            size: 12,
                            color: ColorConfig.colorPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  style: FontConfig.light(
                    size: 12,
                    color: ColorConfig.colorDark,
                  ),
                  hintStyle: FontConfig.light(
                    size: 12,
                    color: ColorConfig.colorDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Btn Create
        BlocSelector<BackendCubit, BackendState, BackEndStatus>(
          selector: (state) => state.status,
          builder: (context, state) => flatButton(
            marginLeft: 0,
            marginTop: 0,
            marginRight: 0,
            marginBottom: 24,
            onPress: () {
              if (formKey.currentState!.validate()) {
                AuthService.signUp(
                        context: context,
                        email: emailController.text,
                        password: pwController.text)
                    .then(
                  (response) {
                    if (response.user != null) {
                      // Update User Db
                      User.dbService.createUser(
                        userId: response.user!.user!.uid,
                        email: emailController.text,
                        name: nameController.text,
                      );

                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) => messageDialog(
                          message: "Success create account",
                          textColor: Colors.green,
                          icon: const Icon(
                            Icons.check,
                            size: 36,
                            color: Colors.green,
                          ),
                        ),
                      );
                    } else {
                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) => messageDialog(
                          message: response.message!,
                          textColor: Colors.red,
                          icon: const Icon(
                            Icons.clear,
                            size: 36,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                  },
                );
              }
            },
            text: (state == BackEndStatus.doing) ? 'Loading...' : 'Create',
            fontColor: Colors.white,
            btnColor: ColorConfig.colorPrimary,
            width: double.infinity,
            height: 48,
          ),
        ),
        RichText(
          text: TextSpan(
            text: "Have an account? ",
            children: [
              TextSpan(
                  text: "Sign In",
                  style: FontConfig.bold(
                    size: 12,
                    color: ColorConfig.colorPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      AuthCubitHandle.read(context).setSignIn(
                        email: '',
                        pw: '',
                      );
                    }),
            ],
            style: FontConfig.medium(
              size: 12,
              color: ColorConfig.colorDark,
            ),
          ),
        ),
      ],
    );
  }
}

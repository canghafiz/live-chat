import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Form
  final formKey = GlobalKey<FormState>();

  // Controller
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    pwController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Form
        Form(
          key: formKey,
          child: Column(
            children: [
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
        // Btn Continue
        BlocSelector<BackendCubit, BackendState, BackEndStatus>(
          selector: (state) => state.status,
          builder: (context, state) => flatButton(
            marginLeft: 0,
            marginTop: 0,
            marginRight: 0,
            marginBottom: 24,
            onPress: () {
              if (formKey.currentState!.validate()) {
                AuthService.signIn(
                  email: emailController.text,
                  password: pwController.text,
                  context: context,
                ).then(
                  (message) {
                    if (message != null) {
                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) => messageDialog(
                          message: message,
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
            text: (state == BackEndStatus.doing) ? 'Loading...' : 'Continue',
            fontColor: Colors.white,
            btnColor: ColorConfig.colorPrimary,
            width: double.infinity,
            height: 48,
          ),
        ),
        RichText(
          text: TextSpan(
            text: "Dont't have an account? ",
            children: [
              TextSpan(
                  text: "Sign Up",
                  style: FontConfig.bold(
                    size: 12,
                    color: ColorConfig.colorPrimary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      AuthCubitHandle.read(context).setSignUp(
                        name: '',
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
        const SizedBox(height: 8),
        // Btn Forgot Password
        GestureDetector(
          onTap: () {
            // Navigate
            RouteHandle.toPasswordChange(context);
          },
          child: Text(
            'Forgot your password?',
            style: FontConfig.medium(
              size: 12,
              color: ColorConfig.colorPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

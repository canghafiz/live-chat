import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  // Form
  final formKey = GlobalKey<FormState>();

  // Controller
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: ColorConfig.colorDark,
            )),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Image
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top),
            child: Image.asset(
              ImagesConst.image,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fitHeight,
            ),
          ),

          // Gradient
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(
                VariableConst.margin,
                VariableConst.margin,
                VariableConst.margin,
                36,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25)),
                color: Colors.white.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 16,
                    color: const Color(0xff8a8a8a).withOpacity(0.1),
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Title
                    Text(
                      "Enter your email to reset your password!",
                      style: FontConfig.medium(
                          size: 14, color: ColorConfig.colorDark),
                    ),
                    // Form
                    Form(
                      key: formKey,
                      child: textformfield(
                        left: 0,
                        top: 16,
                        right: 0,
                        bottom: 36,
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
                    ),
                    // Btn Send
                    flatButton(
                      marginLeft: 0,
                      marginTop: 0,
                      marginRight: 0,
                      marginBottom: 0,
                      onPress: () {
                        if (formKey.currentState!.validate()) {}
                      },
                      text: 'Send',
                      fontColor: Colors.white,
                      btnColor: ColorConfig.colorPrimary,
                      width: double.infinity,
                      height: 48,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

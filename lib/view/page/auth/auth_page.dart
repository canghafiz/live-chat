import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Update State
    PasswordCubitHandle.read(context).clear();
    AuthCubitHandle.read(context).setSignIn(
      email: '',
      pw: '',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Image
            Image.asset(
              ImagesConst.image,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.fitHeight,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(
                  VariableConst.margin,
                  VariableConst.margin,
                  VariableConst.margin,
                  36,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                  child: BlocSelector<AuthCubitCubit, AuthCubitState, bool>(
                    selector: (state) => (state is AuthSignUp) ? false : true,
                    builder: (context, signIn) =>
                        (signIn) ? const SignInPage() : const SignUpPage(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

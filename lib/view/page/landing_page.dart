import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseUtils.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AuthPage();
        }
        return MainPage(userId: snapshot.data!.uid);
      },
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/utils/export_utils.dart';

class SignUpResponse {
  SignUpResponse({required this.message, required this.user});

  final String? message;
  final UserCredential? user;
}

class AuthService {
  static Future<String?> signIn({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Update State
      BackEndCubitHandle.read(context).setDoing();

      // Call Firebase
      await FirebaseUtils.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update State
      BackEndCubitHandle.read(context).setSucces();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return "User not found";
      }
      if (e.code == 'wrong-password') {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return "Wrong password";
      } else {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return "Invalid email";
      }
    }
  }

  static Future<SignUpResponse> signUp({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Update State
      BackEndCubitHandle.read(context).setDoing();

      UserCredential user =
          await FirebaseUtils.auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update State
      BackEndCubitHandle.read(context).setSucces();

      return SignUpResponse(message: null, user: user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return SignUpResponse(
          message: "Weak password,user minimal 6 character",
          user: null,
        );
      }
      if (e.code == 'email-already-in-use') {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return SignUpResponse(message: "Email already in use", user: null);
      } else {
        // Update State
        BackEndCubitHandle.read(context).setError();

        return SignUpResponse(message: "Invalid email", user: null);
      }
    }
  }

  static Future<bool> changePassword(String email) async {
    try {
      return await FirebaseUtils.auth
          .sendPasswordResetEmail(email: email)
          .then((_) => true);
    } catch (e) {
      return false;
    }
  }

  static Future<void> signOut() async {
    await FirebaseUtils.auth.signOut();
  }
}

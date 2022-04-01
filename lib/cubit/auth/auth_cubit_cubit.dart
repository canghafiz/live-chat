import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_cubit_state.dart';

class AuthCubitHandle {
  static AuthCubitCubit read(BuildContext context) {
    return context.read<AuthCubitCubit>();
  }

  static AuthCubitCubit watch(BuildContext context) {
    return context.read<AuthCubitCubit>();
  }
}

class AuthCubitCubit extends Cubit<AuthCubitState> {
  AuthCubitCubit() : super(AuthCubitInitial());

  void setSignIn({required String email, required String pw}) {
    emit(AuthSignIn(email: email, pw: pw));
  }

  void setSignUp({
    required String name,
    required String email,
    required String pw,
  }) {
    emit(AuthSignUp(name: name, email: email, pw: pw));
  }
}

part of 'auth_cubit_cubit.dart';

@immutable
abstract class AuthCubitState {}

class AuthCubitInitial extends AuthCubitState {}

class AuthSignIn extends AuthCubitState {
  final String email, pw;

  AuthSignIn({required this.email, required this.pw});
}

class AuthSignUp extends AuthCubitState {
  final String name, email, pw;

  AuthSignUp({required this.name, required this.email, required this.pw});
}

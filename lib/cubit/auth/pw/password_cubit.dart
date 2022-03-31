import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'password_state.dart';

class PasswordCubitHandle {
  static PasswordCubit read(BuildContext context) {
    return context.read<PasswordCubit>();
  }

  static PasswordCubit watch(BuildContext context) {
    return context.watch<PasswordCubit>();
  }
}

class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit() : super(PasswordState(false));

  void update() {
    emit((state.isShow) ? PasswordState(false) : PasswordState(true));
  }

  void clear() {
    emit(PasswordState(false));
  }
}

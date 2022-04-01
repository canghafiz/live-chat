import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'theme_state.dart';

class ThemeCubitHandle {
  static ThemeCubit read(BuildContext context) {
    return context.read<ThemeCubit>();
  }

  static ThemeCubit watch(BuildContext context) {
    return context.watch<ThemeCubit>();
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(false));

  void setTheme(bool value) {
    emit(ThemeState(value));
  }
}

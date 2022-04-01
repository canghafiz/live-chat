import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'navigation_state.dart';

class NavigationCubitHandle {
  static NavigationCubit read(BuildContext context) {
    return context.read<NavigationCubit>();
  }

  static NavigationCubit watch(BuildContext context) {
    return context.watch<NavigationCubit>();
  }
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(NavigationState(0));

  void setNavigation(int value) {
    emit(NavigationState(value));
  }
}

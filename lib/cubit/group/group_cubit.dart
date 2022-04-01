import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'group_state.dart';

class GroupCubitHandle {
  static GroupCubit read(BuildContext context) {
    return context.read<GroupCubit>();
  }

  static GroupCubit watch(BuildContext context) {
    return context.watch<GroupCubit>();
  }
}

class GroupCubit extends Cubit<GroupState> {
  GroupCubit() : super(GroupState([]));

  void add(String userId) {
    state.usersId.add(userId);
    emit(GroupState(state.usersId));
  }

  void delete(int index) {
    state.usersId.removeAt(index);
    emit(GroupState(state.usersId));
  }

  void clear() {
    state.usersId.clear();
    emit(GroupState(state.usersId));
  }
}

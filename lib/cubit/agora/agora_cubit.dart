import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'agora_state.dart';

class AgoraCubitHandle {
  static AgoraCubit read(BuildContext context) {
    return context.read<AgoraCubit>();
  }

  static AgoraCubit watch(BuildContext context) {
    return context.watch<AgoraCubit>();
  }
}

class AgoraCubit extends Cubit<AgoraState> {
  AgoraCubit() : super(AgoraState(0));

  void updateUid(int value) {
    emit(AgoraState(value));
  }
}

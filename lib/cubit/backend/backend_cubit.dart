import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/utils/const/variable.dart';
part 'backend_state.dart';

class BackEndCubitHandle {
  static BackendCubit read(BuildContext context) {
    return context.read<BackendCubit>();
  }

  static BackendCubit watch(BuildContext context) {
    return context.watch<BackendCubit>();
  }
}

class BackendCubit extends Cubit<BackendState> {
  BackendCubit() : super(BackendState(BackEndStatus.undoing));

  void setUndoing() {
    emit(BackendState(BackEndStatus.undoing));
  }

  void setDoing() {
    emit(BackendState(BackEndStatus.doing));
  }

  void setSucces() {
    emit(BackendState(BackEndStatus.success));
  }

  void setError() {
    emit(BackendState(BackEndStatus.error));
  }
}

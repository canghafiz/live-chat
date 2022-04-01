import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'call_state.dart';

class CallCubitHandle {
  static CallCubit read(BuildContext context) {
    return context.read<CallCubit>();
  }

  static CallCubit watch(BuildContext context) {
    return context.watch<CallCubit>();
  }
}

class CallCubit extends Cubit<CallState> {
  CallCubit()
      : super(CallState(
          micOn: true,
          speaker: true,
        ));

  void update(CallState value) {
    emit(value);
  }

  void updateJoined(bool value) {
    emit(
      CallState(
        micOn: state.micOn,
        speaker: state.speaker,
      ),
    );
  }

  void updateMic(bool value) {
    emit(
      CallState(
        micOn: value,
        speaker: state.speaker,
      ),
    );
  }

  void updateSpeaker(bool value) {
    emit(
      CallState(
        micOn: state.micOn,
        speaker: value,
      ),
    );
  }
}

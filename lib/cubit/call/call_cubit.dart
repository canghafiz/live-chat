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
          cameraOn: true,
        ));

  void updateVoice({required bool mic, required bool speaker}) {
    emit(CallState(
      micOn: mic,
      speaker: speaker,
      cameraOn: state.cameraOn,
    ));
  }

  void updateVideo(bool cameraOn) {
    emit(CallState(
      micOn: state.micOn,
      speaker: state.speaker,
      cameraOn: cameraOn,
    ));
  }

  void updateMic(bool value) {
    emit(
      CallState(
        micOn: value,
        speaker: state.speaker,
        cameraOn: state.cameraOn,
      ),
    );
  }

  void updateSpeaker(bool value) {
    emit(
      CallState(
        micOn: state.micOn,
        speaker: value,
        cameraOn: state.cameraOn,
      ),
    );
  }

  void updateCamera(bool value) {
    emit(
      CallState(
        micOn: state.micOn,
        speaker: state.speaker,
        cameraOn: value,
      ),
    );
  }
}

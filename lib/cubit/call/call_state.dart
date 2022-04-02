part of 'call_cubit.dart';

enum CameraType { front, back }

class CallState {
  final bool micOn, speaker, cameraOn;

  CallState({
    required this.micOn,
    required this.speaker,
    required this.cameraOn,
  });
}

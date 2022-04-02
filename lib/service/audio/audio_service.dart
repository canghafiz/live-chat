import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class RecordService {
  static final RecordMp3 _instance = RecordMp3.instance;

  static record(BuildContext context, Function? timer) async {
    PermissionService.microphone().then(
      (allow) {
        if (allow) {
          if (allow) {
            // Call Timer
            timer?.call();
            FunctionUtils.recorderFilePath().then(
              (path) {
                // Start Record
                _instance.start(
                  path,
                  (type) => debugPrint("Record error--->$type"),
                );
              },
            );

            // Update State
            ChatCubitHandle.read(context).setAudio(AudioChatStatus.record);
          }
        }
      },
    );
  }

  static stop(BuildContext context) async {
    bool stop = _instance.stop();
    if (stop) {
      // Update State
      ChatCubitHandle.read(context).setAudio(AudioChatStatus.done);
    }
  }
}

class AudioPlayerService {
  final _player = AudioPlayer();

  AudioPlayer get audioPlayer => _player;

  Stream<PositionData> get playerDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _player.positionStream,
        _player.bufferedPositionStream,
        _player.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  void dispose() {
    _player.dispose();
  }

  Future<void> initAudioPlayerFromInternet(String url) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  Future<void> initAudioPlayerFromMemory(String url) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      debugPrint('A stream error occurred: $e');
    });
    // Try to load audio from a source and catch any errors.
    try {
      await _player.setFilePath(url);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }
  }

  void stop() {
    _player.stop();
  }

  void seek(Duration? value) {
    _player.seek(value);
  }
}

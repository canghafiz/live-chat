import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

abstract class RtcEnvi {
  static String channelNameTesting = "voice";
  static String appid = "18d720c5d67a4a2f8fb12d7cbef82537";
  static String token =
      "00618d720c5d67a4a2f8fb12d7cbef82537IABzsQILSbyVAXphEEMnQVVh84FFyfx9ztT2UfuMMAxcGDtY++cAAAAAEAAg4mLWqoBGYgEAAQCqgEZi";
}

class RtcApiService {
  static const _adminUrl = "https://console.agora.io/token/U0JnbBOL0";

  static Future<String?> getChannelToken(String channel) async {
    try {
      final Dio dio = Dio();
      final Response response = await dio.post(
          "$_adminUrl/generate_access_token",
          data: {"channel": RtcEnvi.channelNameTesting, "role": "subscriber"});
      return response.data['token'] as String;
    } catch (e) {
      debugPrint("getAgoraChannelToken: $e");
    }
    return null;
  }
}

class RtcVoiceService implements RtcEnvi {
  static RtcEngine? _engine;

  // Getter
  static RtcEngine? get engine => _engine;

  // Setter
  static void _addListener() {
    _engine?.setEventHandler(
      RtcEngineEventHandler(
        warning: (warningCode) {
          log('warning $warningCode');
        },
        error: (errorCode) {
          log('error $errorCode');
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          log('joinChannelSuccess $channel $uid $elapsed');
        },
        leaveChannel: (stats) async {
          log('leaveChannel ${stats.toJson()}');
        },
      ),
    );
  }

  static Future<void> initEngine() async {
    _engine = await RtcEngine.create(RtcEnvi.appid);
    _addListener();

    await _engine?.enableAudio();
  }

  static void destroy() {
    _engine?.destroy();
    _engine = null;
  }

  static void joinChannel({
    required String channel,
    required String token,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.microphone.request();
    }

    await _engine
        ?.joinChannel(RtcEnvi.token, RtcEnvi.channelNameTesting, null, 0)
        .catchError((onError) {
      log('error ${onError.toString()}');
    });
  }

  static Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  static void switchMicrophone({
    required BuildContext context,
    required bool mic,
  }) async {
    await _engine?.enableLocalAudio(!mic).then((value) {
      // Update State
      CallCubitHandle.read(context).updateMic(!mic);
      return;
    }).catchError((err) {
      log('enableLocalAudio $err');
    });
  }

  static void switchSpeakerphone({
    required BuildContext context,
    required bool speaker,
  }) {
    _engine?.setEnableSpeakerphone(!speaker).then((value) {
      // Update State
      CallCubitHandle.read(context).updateSpeaker(!speaker);
    }).catchError((err) {
      log('setEnableSpeakerphone $err');
    });
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class RtcApiService {
  static final _url =
      dotenv.get('RTC_API_URL', fallback: 'RTC_API_URL not found');

  static Future<String?> getChannelToken({
    required String channel,
    required String role,
    required int uid,
  }) async {
    try {
      var response =
          await http.get(Uri.parse("$_url/rtc/$channel/$role/uid/$uid"));
      var data = jsonDecode(response.body);

      return data['rtcToken'];
    } catch (e) {
      debugPrint("getAgoraChannelToken: $e");
    }
    return null;
  }
}

class RtcService {
  static RtcEngine? _engine;

  // Getter
  static RtcEngine? get engine => _engine;

  // Setter
  static void _addListener(Function(int) updateUid) {
    _engine?.setEventHandler(
      RtcEngineEventHandler(warning: (warningCode) {
        log('warning $warningCode');
      }, error: (errorCode) {
        log('error $errorCode');
      }, joinChannelSuccess: (channel, uid, elapsed) {
        log('joinChannelSuccess $channel $uid $elapsed');
        updateUid.call(uid);
      }, leaveChannel: (stats) async {
        log('leaveChannel ${stats.toJson()}');
      }, userOffline: (uid, reason) {
        log("remote user $uid left channel");
        // Update
        updateUid.call(0);
      }),
    );
  }

  // Voice
  static Future<void> initVoiceEngine(Function(int) updateUid) async {
    // Retrieve Permissions
    await [Permission.microphone].request();

    _engine = await RtcEngine.create(
      dotenv.get('RTC_APP_ID', fallback: 'RTC_APP_ID not found'),
    );
    _addListener((value) {
      updateUid.call(value);
    });

    await _engine?.enableAudio();
  }

  // Video
  static Future<void> initVideoEngine(
      {required BuildContext context,
      required Function(int)? updateUid}) async {
    // Retrieve Premissions
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.create(
      dotenv.get('RTC_APP_ID', fallback: 'RTC_APP_ID not found'),
    );
    _addListener((value) {
      updateUid?.call(value);
    });

    await _engine?.enableVideo();
  }

  static void destroy() {
    _engine?.destroy();
    _engine = null;
  }

  static void joinChannel({
    required String channel,
    required String token,
    required int uid,
  }) async {
    await _engine?.joinChannel(token, channel, null, uid).catchError((onError) {
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

  static void turnOnOfCamera({
    required BuildContext context,
    required bool cameraOn,
  }) {
    if (cameraOn) {
      // Turn Off
      _engine?.disableVideo();
      // Update State
      CallCubitHandle.read(context).updateCamera(false);
      return;
    }
    // Turn On
    _engine?.enableVideo();
    // Update State
    CallCubitHandle.read(context).updateCamera(true);
    return;
  }

  static void switchCamera() {
    _engine?.switchCamera();
  }
}

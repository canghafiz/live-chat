import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({
    Key? key,
    required this.callType,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final CallType callType;
  final String userId, yourId;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage>
    with WidgetsBindingObserver {
  int remoteId = 0, totalLeave = 0;
  bool isAccept = false;

  void udpateRemoteId(int value) {
    if (mounted) {
      setState(() {
        remoteId = value;
      });
    }
  }

  void updateTotalLeave() {
    if (mounted) {
      setState(() {
        totalLeave++;
      });
    }
  }

  void updateIsAccept(bool value) {
    if (mounted) {
      setState(() {
        isAccept = value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Life Cycle
    WidgetsBinding.instance!.addObserver(this);
    if (mounted) {
      // Rtc
      RtcService.initVideoEngine(
          context: context,
          updateUid: (value) {
            udpateRemoteId(value);
          }).then(
        (_) {
          // Get Token
          RtcApiService.getChannelToken(
            channel: (widget.callType == CallType.caller)
                ? widget.yourId
                : widget.userId,
            role:
                (widget.callType == CallType.caller) ? "publisher" : "audience",
            uid: (widget.callType == CallType.caller) ? 0 : 1,
          ).then(
            (token) {
              if (token != null) {
                // Join
                RtcService.joinChannel(
                  channel: (widget.callType == CallType.caller)
                      ? widget.yourId
                      : widget.userId,
                  token: token,
                  uid: remoteId,
                );

                if (widget.callType == CallType.caller) {
                  // Send Notification
                  FirebaseUtils.dbUser(widget.yourId).get().then(
                    (doc) {
                      // Object
                      final User user =
                          User.fromMap(doc.data() as Map<String, dynamic>);

                      NotificationService.sendNotification(
                        title: user.name!,
                        subject: "START VIDEO CALL",
                        topics: "from${widget.yourId}to${widget.userId}",
                        type: "Video Call",
                        id: widget.yourId,
                      );
                    },
                  );
                }
              }
            },
          );
        },
      );
      // Db
      Channel.checkChannelProcess(
        userId: (widget.callType == CallType.caller)
            ? widget.yourId
            : widget.userId,
        onFalse: () {
          leaveChannel().then(
            (_) {
              Navigator.pop(context);
              // Update Db
              Channel.dbService.updateCallingProcess(
                userId: (widget.callType == CallType.caller)
                    ? widget.yourId
                    : widget.userId,
                value: "Undoing",
              );
            },
          );
        },
        onAccept: () {
          updateIsAccept(true);
        },
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // Leave Channel
      leaveChannel();
    }
  }

  Future<void> leaveChannel() async {
    RtcService.leaveChannel().then((_) {
      RtcService.destroy();
    });

    // Update Db
    Channel.dbService.updateCallingProcess(
      userId:
          (widget.callType == CallType.caller) ? widget.yourId : widget.userId,
      value: "Left",
    );
    // For You
    Channel.dbService.updateOnOtherCall(
      userId: widget.yourId,
      value: false,
    );
    // For User
    Channel.dbService.updateOnOtherCall(
      userId: widget.userId,
      value: false,
    );

    updateTotalLeave();

    if (totalLeave <= 1) {
      // Update Call Db
      Call.dbService.add(
        userId: widget.yourId,
        type: "Video",
        answer: isAccept,
        callerId: widget.userId,
      );
    }
  }

  void joinChannel(String token) {
    RtcService.joinChannel(
      channel:
          (widget.callType == CallType.caller) ? widget.yourId : widget.userId,
      token: token,
      uid: remoteId,
    );
    // Update Db
    Channel.dbService.updateCallingProcess(
      userId:
          (widget.callType == CallType.caller) ? widget.yourId : widget.userId,
      value: (widget.callType == CallType.caller) ? "Calling" : "Accept",
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCaller = widget.callType == CallType.caller;
    // Update Mic
    RtcService.switchMicrophone(
      context: context,
      mic: false,
    );
    // Update Speaker
    RtcService.switchSpeakerphone(
      context: context,
      speaker: false,
    );
    // Update State
    CallCubitHandle.read(context).updateVideo(true);

    // Widget
    Widget _localView() {
      return const rtc_local_view.SurfaceView();
    }

    Widget _remoteView() {
      return rtc_remote_view.SurfaceView(
        uid: remoteId,
        channelId: (isCaller) ? widget.yourId : widget.userId,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        leaveChannel();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbUser(widget.userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              // Object
              final User user =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
              final Channel? userChannel =
                  (isCaller) ? null : Channel.fromMap(user.channel!);

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseUtils.dbUser(widget.yourId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  // Object
                  final User you = User.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);
                  final Channel yourChannel = Channel.fromMap(you.channel!);
                  return Stack(
                    children: [
                      // Preview
                      (remoteId == 0)
                          ? _localView()
                          : SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: Stack(
                                children: [
                                  // Preview
                                  SizedBox(
                                    width: double.infinity,
                                    child: BlocSelector<ThemeCubit, ThemeState,
                                        bool>(
                                      selector: (state) => state.isDark,
                                      builder: (context, isDark) =>
                                          (userChannel != null)
                                              ? (userChannel.proceess! ==
                                                      "Calling")
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal:
                                                            VariableConst
                                                                .margin,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Name
                                                          Text(
                                                            user.name!,
                                                            style: FontConfig
                                                                .medium(
                                                              size: 20,
                                                              color: (isDark)
                                                                  ? Colors.white
                                                                  : ColorConfig
                                                                      .colorDark,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            yourChannel
                                                                .proceess!,
                                                            style: FontConfig
                                                                .light(
                                                              size: 12,
                                                              color: (isDark)
                                                                  ? Colors.white
                                                                  : ColorConfig
                                                                      .colorDark,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : _remoteView()
                                              : (yourChannel.proceess! ==
                                                      "Calling")
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal:
                                                            VariableConst
                                                                .margin,
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Name
                                                          Text(
                                                            user.name!,
                                                            style: FontConfig
                                                                .medium(
                                                              size: 20,
                                                              color: (isDark)
                                                                  ? Colors.white
                                                                  : ColorConfig
                                                                      .colorDark,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            yourChannel
                                                                .proceess!,
                                                            style: FontConfig
                                                                .light(
                                                              size: 12,
                                                              color: (isDark)
                                                                  ? Colors.white
                                                                  : ColorConfig
                                                                      .colorDark,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : _remoteView(),
                                    ),
                                  ),
                                  // Button
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          1 /
                                          3,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1 /
                                              5,
                                      child: AspectRatio(
                                        aspectRatio: 1.0,
                                        child: _localView(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      // Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: VariableConst.margin,
                          vertical: 24,
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Microphone
                              BlocSelector<CallCubit, CallState, bool>(
                                selector: (state) => state.micOn,
                                builder: (context, isOn) => callButtonWidget(
                                  onTap: () {
                                    RtcService.switchMicrophone(
                                      context: context,
                                      mic: isOn,
                                    );
                                  },
                                  icon: (isOn) ? Icons.mic : Icons.mic_off,
                                  color: ColorConfig.colorPrimary,
                                ),
                              ),
                              // Speaker
                              BlocSelector<CallCubit, CallState, bool>(
                                selector: (state) => state.speaker,
                                builder: (context, isOn) => callButtonWidget(
                                  onTap: () {
                                    RtcService.switchSpeakerphone(
                                      context: context,
                                      speaker: isOn,
                                    );
                                  },
                                  icon: (isOn)
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  color: ColorConfig.colorPrimary,
                                ),
                              ),
                              // Call
                              GestureDetector(
                                onTap: () async {
                                  leaveChannel();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: (userChannel != null)
                                        ? (userChannel.proceess! == "Calling")
                                            ? Colors.red
                                            : Colors.green
                                        : (yourChannel.proceess! == "Calling")
                                            ? Colors.red
                                            : Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.call,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Camera On / Off
                              BlocSelector<CallCubit, CallState, bool>(
                                selector: (state) => state.cameraOn,
                                builder: (context, isOn) => callButtonWidget(
                                  onTap: () {
                                    RtcService.turnOnOfCamera(
                                      context: context,
                                      cameraOn: isOn,
                                    );
                                  },
                                  icon: (isOn)
                                      ? Icons.videocam
                                      : Icons.videocam_off,
                                  color: ColorConfig.colorPrimary,
                                ),
                              ),
                              // Camera Switch
                              callButtonWidget(
                                onTap: () {
                                  RtcService.switchCamera();
                                },
                                icon: Icons.cameraswitch,
                                color: ColorConfig.colorPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

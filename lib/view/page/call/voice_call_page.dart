import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({
    Key? key,
    required this.callType,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final CallType callType;
  final String yourId, userId;

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage>
    with WidgetsBindingObserver {
  int remoteId = 0;
  bool isAccept = false;

  void udpateRemoteId(int value) {
    setState(() {
      remoteId = value;
    });
  }

  void updateIsAccept(bool value) {
    setState(() {
      isAccept = value;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
    // Rtc
    RtcService.initVoiceEngine((value) {
      udpateRemoteId(value);
    }).then(
      (_) {
        // Get Token
        RtcApiService.getChannelToken(
          channel: (widget.callType == CallType.caller)
              ? widget.yourId
              : widget.userId,
          role: (widget.callType == CallType.caller) ? "publisher" : "audience",
          uid: (widget.callType == CallType.caller) ? 0 : 1,
        ).then(
          (token) {
            if (token != null) {
              // Join
              joinChannel(token);
            }
          },
        );
      },
    );
    // Db
    Channel.checkChannelProcess(
      userId:
          (widget.callType == CallType.caller) ? widget.yourId : widget.userId,
      onFalse: () {
        leaveChannel();
        Navigator.pop(context);
      },
      onAccept: () {
        updateIsAccept(true);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Destroy
    RtcService.destroy();
  }

  void leaveChannel() {
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

    // Update Call Db
    Call.dbService.add(
      userId: widget.yourId,
      type: "Voice",
      answer: isAccept,
      callerId: widget.userId,
    );
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

    if (widget.callType == CallType.caller) {
      // Send Notification
      NotificationService.sendNotification(
        title: widget.yourId,
        subject: "START VOICE CALL",
        topics: "from${widget.yourId}to${widget.userId}",
        type: "Voice Call",
      );
    }
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
    CallCubitHandle.read(context).updateVoice(mic: true, speaker: true);
    return WillPopScope(
      onWillPop: () async {
        leaveChannel();
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseUtils.dbUser(widget.userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                ),
              );
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
                  return Text(
                    "Loading...",
                    style: FontConfig.light(
                      size: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                // Object
                final User you =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
                final Channel yourChannel = Channel.fromMap(you.channel!);

                return SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(VariableConst.margin),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Name
                              Text(
                                user.name!,
                                style: FontConfig.medium(
                                  size: 20,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              (userChannel != null)
                                  ? Text(
                                      userChannel.proceess!,
                                      style: FontConfig.light(
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      yourChannel.proceess!,
                                      style: FontConfig.light(
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              const SizedBox(height: 36),
                              Flexible(
                                child: BasicPhotoProfile(
                                  size: MediaQuery.of(context).size.width -
                                      MediaQuery.of(context).size.width * 1 / 2,
                                  url: user.profile,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                        Row(
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
                              ),
                            ),
                            // Call
                            GestureDetector(
                              onTap: () {
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
                                icon:
                                    (isOn) ? Icons.volume_up : Icons.volume_off,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

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
  @override
  void initState() {
    super.initState();
    setState(() {});
    RtcVoiceService.initEngine().then((_) {
      // Get Token
      RtcApiService.getChannelToken(
        channel: "voice",
        role: "audience",
      ).then((token) {
        if (token != null) {
          // Join
          RtcVoiceService.joinChannel(
            channel: "voice",
            token: token,
            uid: 0,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    // Destroy
    RtcVoiceService.destroy();
  }

  void leaveChannel() {
    RtcVoiceService.leaveChannel().then((_) {
      RtcVoiceService.destroy();
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCaller = widget.callType == CallType.caller;
    // Update State
    CallCubitHandle.read(context).update(CallState(micOn: true, speaker: true));
    return WillPopScope(
      onWillPop: () async {
        leaveChannel();
        return true;
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
                                  RtcVoiceService.switchMicrophone(
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
                                  RtcVoiceService.switchSpeakerphone(
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

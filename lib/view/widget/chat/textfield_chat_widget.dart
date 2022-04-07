import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';

class TextfieldChatWidget extends StatefulWidget {
  const TextfieldChatWidget({
    Key? key,
    required this.groupId,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final String? userId, groupId;
  final String yourId;

  @override
  State<TextfieldChatWidget> createState() => _TextfieldChatWidgetState();
}

class _TextfieldChatWidgetState extends State<TextfieldChatWidget>
    with WidgetsBindingObserver {
  // Audio
  final AudioPlayerService _player = AudioPlayerService();
  // Controller
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    // Controller
    controller.addListener(() {
      if (controller.text.isNotEmpty) {
        ChatCubitHandle.read(this.context).setTextfield(false);
        return;
      }
      ChatCubitHandle.read(this.context).setTextfield(true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    // Controller
    controller.dispose();
    // Player
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update State
    ChatCubitHandle.read(context).setTextfield(true);
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 1 / 4,
            minHeight: 64,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: (isDark) ? ColorConfig.colorDark : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -4),
                  color: (isDark)
                      ? Colors.white.withOpacity(0.1)
                      : ColorConfig.colorDark.withOpacity(0.1),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              width: double.infinity,
              decoration: BoxDecoration(
                color: (isDark)
                    ? Colors.white
                    : ColorConfig.colorPrimary.withOpacity(0.2),
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: BlocSelector<ChatCubit, ChatState, ChatState>(
                selector: (state) => state,
                builder: (context, state) {
                  final TextFieldChat? textfieldState =
                      (state is TextFieldChat) ? state : null;
                  final AudioChat? audioState =
                      (state is AudioChat) ? state : null;

                  return (textfieldState != null)
                      // When Not Recording
                      ? Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Show Modal Bottom
                                FunctionUtils.showCustomBottomSheet(
                                  context: context,
                                  content: PhotoBottomWidget(
                                    dbUpdate: (value) {
                                      // For Personal
                                      if (widget.userId != null) {
                                        //  Update Storage
                                        FirebaseStorageService.uploadImage(
                                          folderName:
                                              VariableConst.imageChatStorage,
                                          fileName: basename(value.path),
                                          pickedFile: XFile(value.path),
                                        ).then(
                                          (url) {
                                            // Update Chat Db
                                            VariableConst.personalDbService
                                                .sendChat(
                                              sendChat: () {
                                                // For You
                                                VariableConst.personalDbService
                                                    .sendImage(
                                                  yourId: widget.yourId,
                                                  userId: widget.userId!,
                                                  date: VariableConst
                                                      .timeYearMonthDay,
                                                  url: url,
                                                  from: widget.yourId,
                                                );

                                                // For User
                                                VariableConst.personalDbService
                                                    .sendImage(
                                                  yourId: widget.userId!,
                                                  userId: widget.yourId,
                                                  date: VariableConst
                                                      .timeYearMonthDay,
                                                  url: url,
                                                  from: widget.yourId,
                                                );

                                                Navigator.pop(context);
                                              },
                                              yourId: widget.yourId,
                                              userId: widget.userId!,
                                            );
                                          },
                                        );
                                      }
                                    },
                                    imageNotNull: false,
                                    delete: () {},
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.photo,
                                color: ColorConfig.colorDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: TextField(
                                keyboardType: TextInputType.text,
                                maxLines: null,
                                controller: controller,
                                style: FontConfig.medium(
                                  size: 12,
                                  color: ColorConfig.colorDark,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(0),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Write a message...",
                                  hintStyle: FontConfig.medium(
                                    size: 12,
                                    color: ColorConfig.colorDark,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            (textfieldState.audioChatOn)
                                ? circularButton(
                                    size: 40,
                                    icon: Icons.mic,
                                    onTap: () async {
                                      RecordService.record(
                                        context,
                                        () {
                                          // Update State
                                          timerService.startTime();
                                        },
                                      );
                                    },
                                  )
                                : circularButton(
                                    size: 40,
                                    icon: Icons.send,
                                    onTap: () {
                                      if (controller.text.isNotEmpty) {
                                        // For Personal
                                        if (widget.userId != null) {
                                          VariableConst.personalDbService
                                              .sendChat(
                                            sendChat: () {
                                              // For You
                                              VariableConst.personalDbService
                                                  .sendText(
                                                yourId: widget.yourId,
                                                userId: widget.userId!,
                                                from: widget.yourId,
                                                date: VariableConst
                                                    .timeYearMonthDay,
                                                message: controller.text,
                                              );

                                              // For User
                                              VariableConst.personalDbService
                                                  .sendText(
                                                yourId: widget.userId!,
                                                userId: widget.yourId,
                                                from: widget.yourId,
                                                date: VariableConst
                                                    .timeYearMonthDay,
                                                message: controller.text,
                                              );
                                            },
                                            yourId: widget.yourId,
                                            userId: widget.userId!,
                                          );
                                          controller.clear();
                                          return;
                                        }
                                      }
                                    },
                                  ),
                          ],
                        )
                      // When Start Recording
                      : Row(
                          children: [
                            Flexible(
                              child: (audioState!.status ==
                                      AudioChatStatus.done)
                                  ? SizedBox(
                                      height: 64,
                                      child: Row(
                                        children: [
                                          ControlButton(
                                            player: _player.audioPlayer,
                                            fromYou: false,
                                          ),
                                          Flexible(
                                            child: StreamBuilder<PositionData>(
                                              stream: _player.playerDataStream,
                                              builder: (context, snapshot) {
                                                final positionData =
                                                    snapshot.data;
                                                return SeekBar(
                                                  fromYou: false,
                                                  duration:
                                                      positionData?.duration ??
                                                          Duration.zero,
                                                  position:
                                                      positionData?.position ??
                                                          Duration.zero,
                                                  bufferedPosition: positionData
                                                          ?.bufferedPosition ??
                                                      Duration.zero,
                                                  onChangeEnd: _player.seek,
                                                );
                                              },
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              // Update State
                                              ChatCubitHandle.read(context)
                                                  .setTextfield(true);
                                            },
                                            child: const Icon(
                                              Icons.delete,
                                              color: ColorConfig.colorDark,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 64,
                                      child: Center(
                                        child: Consumer<TimerService>(
                                            builder: (_, state, __) {
                                          String time() {
                                            String twoDigits(int n) =>
                                                n.toString().padLeft(2, '0');
                                            final hours = twoDigits(
                                                state.duration.inHours);
                                            final minutes = twoDigits(state
                                                .duration.inMinutes
                                                .remainder(60));
                                            final seconds = twoDigits(state
                                                .duration.inSeconds
                                                .remainder(60));

                                            return (hours == "00")
                                                ? "$minutes:$seconds"
                                                : "$hours:$minutes:$seconds";
                                          }

                                          return Text(
                                            time(),
                                            style: FontConfig.medium(
                                              size: 12,
                                              color: ColorConfig.colorDark,
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                            ),
                            (audioState.status == AudioChatStatus.record)
                                ? circularButton(
                                    size: 40,
                                    icon: Icons.stop,
                                    onTap: () async {
                                      RecordService.stop(context);

                                      // Player
                                      FunctionUtils.recorderFilePath().then(
                                        (path) {
                                          if (File(path).existsSync()) {
                                            _player.initAudioPlayerFromMemory(
                                              path,
                                            );
                                          }
                                        },
                                      );

                                      // Update State
                                      timerService.reset();
                                    },
                                  )
                                : circularButton(
                                    size: 40,
                                    icon: Icons.send,
                                    onTap: () {
                                      FunctionUtils.recorderFilePath().then(
                                        (path) {
                                          if (File(path).existsSync()) {
                                            // For Personal
                                            if (widget.userId != null) {
                                              //  Update Storage
                                              FirebaseStorageService
                                                  .uploadAudio(
                                                folderName: VariableConst
                                                    .imageChatStorage,
                                                fileName: basename(path),
                                                file: File(path),
                                              ).then(
                                                (url) {
                                                  // Update Chat Db
                                                  VariableConst
                                                      .personalDbService
                                                      .sendChat(
                                                    sendChat: () {
                                                      // For You
                                                      VariableConst
                                                          .personalDbService
                                                          .sendAudio(
                                                        yourId: widget.yourId,
                                                        userId: widget.userId!,
                                                        date: VariableConst
                                                            .timeYearMonthDay,
                                                        url: url,
                                                        from: widget.yourId,
                                                      );

                                                      // For User
                                                      VariableConst
                                                          .personalDbService
                                                          .sendAudio(
                                                        yourId: widget.userId!,
                                                        userId: widget.yourId,
                                                        date: VariableConst
                                                            .timeYearMonthDay,
                                                        url: url,
                                                        from: widget.yourId,
                                                      );

                                                      // Update State
                                                      ChatCubitHandle.read(
                                                              context)
                                                          .setTextfield(true);
                                                    },
                                                    yourId: widget.yourId,
                                                    userId: widget.userId!,
                                                  );
                                                },
                                              );
                                            }
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

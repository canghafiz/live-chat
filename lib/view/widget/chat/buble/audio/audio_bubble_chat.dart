import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class AudioBubbleChat extends StatefulWidget {
  const AudioBubbleChat({
    Key? key,
    required this.yourId,
    required this.group,
    required this.personal,
    required this.chatId,
    required this.userId,
    required this.index,
  }) : super(key: key);
  final String yourId, chatId;
  final String? userId;
  final PersonalChatAudio? personal;
  final GroupChatAudio? group;
  final int index;

  @override
  State<AudioBubbleChat> createState() => _AudioBubbleChatState();
}

class _AudioBubbleChatState extends State<AudioBubbleChat>
    with WidgetsBindingObserver {
  final AudioPlayerService _player = AudioPlayerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _player.initAudioPlayerFromInternet(
      (widget.personal != null) ? widget.personal!.url! : widget.group!.url!,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
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
    final bool fromYou = (widget.personal != null)
        ? widget.personal!.from == widget.yourId
        : widget.group!.from == widget.yourId;
    return GestureDetector(
      onTap: () {
        if (fromYou) {
          showDialog(
            context: context,
            builder: (context) => deleteChatWidget(
              () {
                if (widget.personal != null && widget.userId != null) {
                  // For Personal
                  VariableConst.personalChatDbService.deleteChatFile(
                    userId: widget.userId!,
                    yourId: widget.yourId,
                    chatId: widget.chatId,
                    url: widget.personal!.url!,
                    index: widget.index,
                  );
                }
                Navigator.pop(context);
              },
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: BlocSelector<ThemeCubit, ThemeState, bool>(
          selector: (state) => state.isDark,
          builder: (context, isDark) => (widget.personal != null)
              ? Row(
                  mainAxisAlignment: (fromYou)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    (fromYou)
                        ? (widget.personal!.read!)
                            ? Icon(
                                Icons.done_all,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              )
                            : Icon(
                                Icons.check,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              )
                        : const SizedBox(),
                    (fromYou)
                        ? const SizedBox(width: 8)
                        : const SizedBox(width: 0),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: (fromYou)
                              ? ColorConfig.colorPrimary
                              : (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(25),
                            topRight: const Radius.circular(25),
                            bottomRight: Radius.circular((fromYou) ? 0 : 25),
                            bottomLeft: Radius.circular((fromYou) ? 25 : 0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ControlButton(
                              player: _player.audioPlayer,
                              fromYou: fromYou,
                            ),
                            Flexible(
                              child: StreamBuilder<PositionData>(
                                stream: _player.playerDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return SeekBar(
                                    fromYou: fromYou,
                                    duration:
                                        positionData?.duration ?? Duration.zero,
                                    position:
                                        positionData?.position ?? Duration.zero,
                                    bufferedPosition:
                                        positionData?.bufferedPosition ??
                                            Duration.zero,
                                    onChangeEnd: _player.seek,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.personal!.time!,
                              style: FontConfig.light(
                                  size: 10,
                                  color: (fromYou)
                                      ? Colors.white
                                      : ColorConfig.colorDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                    (!fromYou)
                        ? const SizedBox(width: 8)
                        : const SizedBox(width: 0),
                    (!widget.personal!.read! && !fromYou)
                        ? Text(
                            "New",
                            style: FontConfig.light(
                              size: 12,
                              color: (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorDark,
                            ),
                          )
                        : const SizedBox(),
                  ],
                )
              : Row(
                  mainAxisAlignment: (fromYou)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    (fromYou)
                        ? (widget.group!.read!
                                .where((id) => id != widget.yourId)
                                .isNotEmpty)
                            ? Icon(
                                Icons.done_all,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              )
                            : Icon(
                                Icons.check,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              )
                        : const SizedBox(),
                    (fromYou)
                        ? const SizedBox(width: 8)
                        : const SizedBox(width: 0),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: (fromYou)
                              ? ColorConfig.colorPrimary
                              : (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(25),
                            topRight: const Radius.circular(25),
                            bottomRight: Radius.circular((fromYou) ? 0 : 25),
                            bottomLeft: Radius.circular((fromYou) ? 25 : 0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (fromYou)
                                ? Text(
                                    "You",
                                    style: FontConfig.bold(
                                        size: 12,
                                        color: (fromYou)
                                            ? Colors.white
                                            : ColorConfig.colorDark),
                                  )
                                : StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseUtils.dbUser(
                                            widget.group!.from!)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      }
                                      // Object
                                      final User user = User.fromMap(
                                          snapshot.data!.data()
                                              as Map<String, dynamic>);

                                      return Text(
                                        user.name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontConfig.bold(
                                            size: 12,
                                            color: (fromYou)
                                                ? Colors.white
                                                : ColorConfig.colorDark),
                                      );
                                    },
                                  ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ControlButton(
                                    player: _player.audioPlayer,
                                    fromYou: fromYou),
                                Flexible(
                                  child: StreamBuilder<PositionData>(
                                    stream: _player.playerDataStream,
                                    builder: (context, snapshot) {
                                      final positionData = snapshot.data;
                                      return SeekBar(
                                        fromYou: fromYou,
                                        duration: positionData?.duration ??
                                            Duration.zero,
                                        position: positionData?.position ??
                                            Duration.zero,
                                        bufferedPosition:
                                            positionData?.bufferedPosition ??
                                                Duration.zero,
                                        onChangeEnd: _player.seek,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.group!.time!,
                                  style: FontConfig.light(
                                      size: 10,
                                      color: (fromYou)
                                          ? Colors.white
                                          : ColorConfig.colorDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    (!fromYou)
                        ? const SizedBox(width: 8)
                        : const SizedBox(width: 0),
                    (widget.group!.read!
                                .where((id) => id == widget.yourId)
                                .isEmpty &&
                            !fromYou)
                        ? Text(
                            "New",
                            style: FontConfig.light(
                              size: 12,
                              color: (isDark)
                                  ? Colors.white
                                  : ColorConfig.colorDark,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
        ),
      ),
    );
  }
}

//  Display Button
class ControlButton extends StatelessWidget {
  const ControlButton({
    Key? key,
    required this.player,
    required this.fromYou,
  }) : super(key: key);
  final AudioPlayer player;
  final bool fromYou;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return SizedBox(
            width: 36.0,
            height: 36.0,
            child: CircularProgressIndicator(
              color: (fromYou) ? Colors.white : ColorConfig.colorDark,
            ),
          );
        } else if (playing != true) {
          return GestureDetector(
            child: Icon(
              Icons.play_arrow,
              color: (fromYou) ? Colors.white : ColorConfig.colorDark,
              size: 36,
            ),
            onTap: player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return GestureDetector(
            child: Icon(
              Icons.pause,
              color: (fromYou) ? Colors.white : ColorConfig.colorDark,
              size: 36,
            ),
            onTap: player.pause,
          );
        } else {
          return GestureDetector(
            child: Icon(
              Icons.play_arrow,
              color: (fromYou) ? Colors.white : ColorConfig.colorDark,
              size: 36,
            ),
            onTap: () => player.seek(Duration.zero),
          );
        }
      },
    );
  }
}

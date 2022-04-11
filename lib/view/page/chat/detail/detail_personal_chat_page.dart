import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class DetailPersonalChatPage extends StatelessWidget {
  const DetailPersonalChatPage({
    Key? key,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final String userId, yourId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
        stream: FirebaseUtils.dbUser(yourId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Object
          final User you =
              User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbUser(userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Object
              final User user =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);
              final isBlockedByYou = you.contacts!
                  .where((data) => data['user_id'] == userId && data['block'])
                  .isNotEmpty;
              final isBlockedByUser = user.contacts!
                  .where((data) => data['user_id'] == yourId && data['block'])
                  .isNotEmpty;

              return Scaffold(
                backgroundColor: ColorConfig.colorPrimary,
                extendBody: true,
                appBar: AppBar(
                  title: GestureDetector(
                    onTap: () {
                      // Navigate
                      RouteHandle.toPersonalDetailPage(
                        context: context,
                        userId: userId,
                        yourId: yourId,
                      );
                    },
                    child: Row(
                      children: [
                        // Photo
                        PhotoProfileWidget(userId: userId, size: 36),
                        const SizedBox(width: 12),
                        // Name
                        Flexible(
                          child: Text(
                            user.name!,
                            style: FontConfig.medium(
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Voice
                    IconButton(
                      onPressed: () {
                        // Navigate
                        RouteHandle.toVoiceCall(
                          context: context,
                          userId: userId,
                          yourId: yourId,
                          type: CallType.caller,
                        );
                      },
                      icon: const Icon(
                        Icons.call,
                        color: Colors.white,
                      ),
                    ),
                    // Video
                    IconButton(
                      onPressed: () {
                        // Navigate
                        RouteHandle.toVideoCall(
                          context: context,
                          userId: userId,
                          yourId: yourId,
                          type: CallType.caller,
                        );
                      },
                      icon: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
                body: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    color: (isDark) ? ColorConfig.colorDark : Colors.white,
                  ),
                  child: (isBlockedByYou || isBlockedByUser)
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(VariableConst.margin),
                            child: Text(
                              (isBlockedByYou)
                                  ? "This accounst is blocked by you"
                                  : "This accounst is blocked you",
                              style: FontConfig.medium(
                                size: 14,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            // Chats
                            Expanded(
                              child: StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseUtils.dbChat(yourId)
                                    .doc(userId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    if (snapshot.data!.exists) {
                                      // Object
                                      final UserChat chat = UserChat.fromMap(
                                          snapshot.data!.data()
                                              as Map<String, dynamic>);

                                      return (chat.chats == null)
                                          ? const SizedBox()
                                          : (chat.chats!.isEmpty)
                                              ? const SizedBox()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal:
                                                        VariableConst.margin,
                                                  ),
                                                  child: SingleChildScrollView(
                                                    reverse: true,
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 24),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: chat.chats!
                                                              .map(
                                                                (date) =>
                                                                    Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Center(
                                                                      child:
                                                                          Text(
                                                                        FunctionUtils
                                                                            .chatTimeCalculate(
                                                                          date,
                                                                        ),
                                                                        style: FontConfig
                                                                            .medium(
                                                                          size:
                                                                              12,
                                                                          color: (isDark)
                                                                              ? Colors.white
                                                                              : ColorConfig.colorDark,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          16,
                                                                    ),
                                                                    StreamBuilder<
                                                                        QuerySnapshot>(
                                                                      stream: FirebaseUtils.dbChat(
                                                                              yourId)
                                                                          .doc(
                                                                              userId)
                                                                          .collection(
                                                                              date)
                                                                          .orderBy(
                                                                              "time")
                                                                          .snapshots(),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (!snapshot
                                                                            .hasData) {
                                                                          return const SizedBox();
                                                                        }

                                                                        return (snapshot.data ==
                                                                                null)
                                                                            ? const SizedBox()
                                                                            : Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                children: snapshot.data!.docs.map((doc) {
                                                                                  // Object
                                                                                  final data = doc.data() as Map<String, dynamic>;
                                                                                  // Type Handle
                                                                                  final PersonalChatText? text = (data['type'] == VariableConst.chatTypeText) ? PersonalChatText.fromMap(data) : null;
                                                                                  final PersonalChatImage? image = (data['type'] == VariableConst.chatTypeImage) ? PersonalChatImage.fromMap(data) : null;
                                                                                  final PersonalChatAudio? audio = (data['type'] == VariableConst.chatTypeAudio) ? PersonalChatAudio.fromMap(data) : null;

                                                                                  SchedulerBinding.instance!.addPostFrameCallback(
                                                                                    (_) {
                                                                                      // Update Token
                                                                                      NotificationService.unSubscribeTopic(
                                                                                        "from${userId}to$yourId",
                                                                                      );
                                                                                      if (!data['read'] && data['from'] != yourId) {
                                                                                        // Update Chat Db
                                                                                        VariableConst.personalChatDbService.updateReadChat(
                                                                                          yourId: yourId,
                                                                                          date: date,
                                                                                          userId: userId,
                                                                                          chatId: doc.id,
                                                                                        );

                                                                                        VariableConst.personalChatDbService.updateTotalRead(
                                                                                          yourId: yourId,
                                                                                          userId: userId,
                                                                                          value: 0,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                  );

                                                                                  return (text != null)
                                                                                      ? TextBubbleChat(
                                                                                          yourId: yourId,
                                                                                          personal: text,
                                                                                          group: null,
                                                                                        )
                                                                                      : (image != null)
                                                                                          ? ImageBubbleChat(
                                                                                              yourId: yourId,
                                                                                              personal: image,
                                                                                              group: null,
                                                                                            )
                                                                                          : AudioBubbleChat(
                                                                                              yourId: yourId,
                                                                                              group: null,
                                                                                              personal: audio,
                                                                                            );
                                                                                }).toList(),
                                                                              );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                              .toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                    }
                                    return const SizedBox();
                                  }
                                },
                              ),
                            ),
                            // Textfield
                            TextfieldChatWidget(
                              userId: userId,
                              yourId: yourId,
                              groupId: null,
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

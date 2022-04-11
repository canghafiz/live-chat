import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class DetailGroupChatPage extends StatelessWidget {
  const DetailGroupChatPage({
    Key? key,
    required this.groupId,
    required this.yourId,
  }) : super(key: key);
  final String groupId, yourId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
        stream: FirebaseUtils.dbGroup(groupId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // Object
          final Group group =
              Group.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          final bool youAreMember = (group.members!.where((data) {
            // Object
            final Member member = Member.fromMap(data);

            return member.userId == yourId;
          })).isNotEmpty;

          return Scaffold(
            backgroundColor: ColorConfig.colorPrimary,
            extendBody: true,
            appBar: AppBar(
              title: GestureDetector(
                onTap: () {
                  // Navigate
                  RouteHandle.toGroupDetailPage(
                    context: context,
                    groupId: groupId,
                    yourId: yourId,
                  );
                },
                child: Row(
                  children: [
                    // Photo
                    BasicPhotoProfile(size: 36, url: group.profile),
                    const SizedBox(width: 12),
                    // Name
                    Flexible(
                      child: Text(
                        group.name!,
                        style: FontConfig.medium(
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
              child: (!youAreMember)
                  ? Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          "Join",
                          style: FontConfig.medium(
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Chats
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseUtils.dbGroup(groupId)
                                .collection('CHAT')
                                .orderBy("date")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const SizedBox();
                              }
                              return (snapshot.data!.docs.isEmpty)
                                  ? const SizedBox()
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        VariableConst.margin,
                                        VariableConst.margin,
                                        VariableConst.margin,
                                        0,
                                      ),
                                      child: SingleChildScrollView(
                                        reverse: true,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 24),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: snapshot.data!.docs
                                                  .map(
                                                    (data) => Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Center(
                                                          child: Text(
                                                            FunctionUtils
                                                                .chatTimeCalculate(
                                                              data['date'],
                                                            ),
                                                            style: FontConfig
                                                                .medium(
                                                              size: 12,
                                                              color: (isDark)
                                                                  ? Colors.white
                                                                  : ColorConfig
                                                                      .colorDark,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        StreamBuilder<
                                                            QuerySnapshot>(
                                                          stream: FirebaseUtils
                                                                  .dbGroup(
                                                                      groupId)
                                                              .collection(
                                                                  'CHAT')
                                                              .doc(data.id)
                                                              .collection(
                                                                  'DATA')
                                                              .orderBy(
                                                                'time',
                                                              )
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshot) {
                                                            if (!snapshot
                                                                .hasData) {
                                                              return const SizedBox();
                                                            }
                                                            return Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: snapshot
                                                                  .data!.docs
                                                                  .map((doc) {
                                                                // Object
                                                                final chatData = doc
                                                                        .data()
                                                                    as Map<
                                                                        String,
                                                                        dynamic>;

                                                                SchedulerBinding
                                                                    .instance!
                                                                    .addPostFrameCallback(
                                                                  (_) {
                                                                    List read =
                                                                        chatData[
                                                                            'read'];
                                                                    if (!read
                                                                        .contains(
                                                                            yourId)) {
                                                                      // Update Chat Db
                                                                      VariableConst
                                                                          .groupChatDbService
                                                                          .updateChatRead(
                                                                        groupId:
                                                                            groupId,
                                                                        chatId:
                                                                            data.id,
                                                                        chatsId:
                                                                            doc.id,
                                                                        userId:
                                                                            yourId,
                                                                      );
                                                                    }
                                                                  },
                                                                );

                                                                // Type Handle
                                                                final GroupChatText? text = (chatData[
                                                                            'type'] ==
                                                                        VariableConst
                                                                            .chatTypeText)
                                                                    ? GroupChatText
                                                                        .fromMap(
                                                                            chatData)
                                                                    : null;
                                                                final GroupChatImage? image = (chatData[
                                                                            'type'] ==
                                                                        VariableConst
                                                                            .chatTypeImage)
                                                                    ? GroupChatImage
                                                                        .fromMap(
                                                                            chatData)
                                                                    : null;
                                                                final GroupChatAudio? audio = (chatData[
                                                                            'type'] ==
                                                                        VariableConst
                                                                            .chatTypeAudio)
                                                                    ? GroupChatAudio
                                                                        .fromMap(
                                                                            chatData)
                                                                    : null;

                                                                return (text !=
                                                                        null)
                                                                    ? TextBubbleChat(
                                                                        yourId:
                                                                            yourId,
                                                                        personal:
                                                                            null,
                                                                        group:
                                                                            text,
                                                                      )
                                                                    : (image !=
                                                                            null)
                                                                        ? ImageBubbleChat(
                                                                            yourId:
                                                                                yourId,
                                                                            personal:
                                                                                null,
                                                                            group:
                                                                                image,
                                                                          )
                                                                        : AudioBubbleChat(
                                                                            yourId:
                                                                                yourId,
                                                                            group:
                                                                                audio,
                                                                            personal:
                                                                                null,
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
                            },
                          ),
                        ),
                        // Textfield
                        TextfieldChatWidget(
                          userId: null,
                          yourId: yourId,
                          groupId: groupId,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }
}

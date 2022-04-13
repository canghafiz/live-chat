import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class CardChatWidget extends StatelessWidget {
  const CardChatWidget({
    Key? key,
    required this.yourId,
    required this.chatId,
    required this.userId,
    required this.groupId,
  }) : super(key: key);
  final String yourId;
  final String? userId, groupId, chatId;

  @override
  Widget build(BuildContext context) {
    return (userId != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbUser(userId!).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              // Object
              final User user =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return BlocSelector<ThemeCubit, ThemeState, bool>(
                selector: (state) => state.isDark,
                builder: (context, isDark) => ListTile(
                  onLongPress: () {
                    if (userId != null) {
                      // Show Dialog
                      showDialog(
                        context: context,
                        builder: (context) => deleteDialog(
                          () {
                            // Update Chat Db
                            VariableConst.personalChatDbService.deleteChat(
                              yourId: yourId,
                              userId: userId!,
                            );

                            Navigator.pop(context);
                          },
                        ),
                      );
                    }
                  },
                  onTap: () {
                    // Navigate
                    RouteHandle.toDetailPersonalChat(
                      context: context,
                      userId: userId!,
                      yourId: yourId,
                    );
                  },
                  leading: SizedBox(
                    width: 36,
                    child: PhotoProfileWidget(userId: userId!, size: 36),
                  ),
                  title: Text(
                    user.name ?? "No Name",
                    style: FontConfig.medium(
                      size: 14,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: SlugMessageChatWidget(
                    groupId: null,
                    yourId: yourId,
                    chatId: chatId!,
                    userId: snapshot.data!.id,
                  ),
                  trailing: BadgeChatWidget(userId: userId!, yourId: yourId),
                ),
              );
            },
          )
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbGroup(groupId!).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              // Object
              final Group group =
                  Group.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return BlocSelector<ThemeCubit, ThemeState, bool>(
                selector: (state) => state.isDark,
                builder: (context, isDark) => ListTile(
                  onTap: () {
                    // Navigate
                    RouteHandle.toDetailGroupChat(
                      context: context,
                      groupId: groupId!,
                      yourId: yourId,
                    );
                  },
                  leading: SizedBox(
                    width: 36,
                    child: BasicPhotoProfile(size: 36, url: group.profile),
                  ),
                  title: Text(
                    group.name ?? "No Name",
                    style: FontConfig.medium(
                      size: 14,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: SlugMessageChatWidget(
                    groupId: groupId,
                    yourId: yourId,
                    chatId: group.chatDate!.substring(0, 10),
                    userId: null,
                  ),
                ),
              );
            },
          );
  }
}

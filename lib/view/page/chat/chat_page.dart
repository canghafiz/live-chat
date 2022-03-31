import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  Widget build(BuildContext context) {
    // Update State
    TagCubitHandle.read(context).clear();
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        appBar: AppBar(
          title: Text(
            'Chats',
            style: FontConfig.medium(size: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (TagCubitHandle.read(context).state.type ==
                    TagType.personal) {
                  // Navigate
                  RouteHandle.toPersonalChatSearch(
                    context: context,
                    yourId: userId,
                  );
                  return;
                }

                // Navigate
                RouteHandle.toGroupChatSearch(
                  context: context,
                  yourId: userId,
                );
              },
              icon: const Icon(Icons.search, color: Colors.white),
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
          child: Column(
            children: [
              const PersonalOrGroupTagWidget(marginHor: 16, marginVer: 16),
              const Divider(color: ColorConfig.colorPrimary),
              BlocSelector<TagCubit, TagState, TagType>(
                selector: (state) => state.type,
                builder: (context, type) => (type == TagType.personal)
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseUtils.dbChat(userId)
                            .orderBy(
                              'date',
                              descending: true,
                            )
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          // Data
                          final List<QueryDocumentSnapshot<Object?>> chats =
                              snapshot.data!.docs;

                          return (chats.isEmpty)
                              ? const SizedBox()
                              : Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: chats.map(
                                        (doc) {
                                          // Object
                                          final chat = doc.data()
                                              as Map<String, dynamic>;

                                          return CardChatWidget(
                                            groupId: null,
                                            yourId: userId,
                                            userId: doc.id,
                                            chatId: chat['date']
                                                .toString()
                                                .substring(0, 10),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ),
                                );
                        },
                      )
                    : Flexible(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseUtils.dbGroups()
                              .orderBy(
                                'chat_date',
                                descending: true,
                              )
                              .snapshots(),
                          builder: (context, snapshotGroups) {
                            if (!snapshotGroups.hasData) {
                              return const CircularProgressIndicator();
                            }
                            // Data
                            final List<QueryDocumentSnapshot<Object?>> groups =
                                snapshotGroups.data!.docs;

                            return (groups.isEmpty)
                                ? const SizedBox()
                                : StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseUtils.dbUser(userId)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox();
                                      }
                                      // Object
                                      final User user = User.fromMap(
                                          snapshot.data!.data()
                                              as Map<String, dynamic>);

                                      return (user.groups!.isEmpty)
                                          ? const SizedBox()
                                          : SingleChildScrollView(
                                              child: Column(
                                                children: groups.map(
                                                  (doc) {
                                                    // Object
                                                    final Group group =
                                                        Group.fromMap(doc.data()
                                                            as Map<String,
                                                                dynamic>);

                                                    var filter = user.groups!
                                                        .where((data) {
                                                      return data == doc.id;
                                                    });

                                                    return (filter.isEmpty)
                                                        ? const SizedBox()
                                                        : Column(
                                                            children: filter
                                                                .map((id) {
                                                              return (group
                                                                          .chatDate !=
                                                                      null)
                                                                  ? CardChatWidget(
                                                                      groupId:
                                                                          id,
                                                                      yourId:
                                                                          userId,
                                                                      userId:
                                                                          null,
                                                                      chatId:
                                                                          null,
                                                                    )
                                                                  : const SizedBox();
                                                            }).toList(),
                                                          );
                                                  },
                                                ).toList(),
                                              ),
                                            );
                                    },
                                  );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/widget/chat/delete_chat_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class TextBubbleChat extends StatelessWidget {
  const TextBubbleChat({
    Key? key,
    required this.chatId,
    required this.yourId,
    required this.userId,
    required this.personal,
    required this.group,
  }) : super(key: key);
  final String yourId, chatId;
  final String? userId;
  final PersonalChatText? personal;
  final GroupChatText? group;

  @override
  Widget build(BuildContext context) {
    final bool fromYou =
        (personal != null) ? personal!.from == yourId : group!.from == yourId;
    return GestureDetector(
      onTap: () {
        if (fromYou) {
          showDialog(
            context: context,
            builder: (context) => deleteChatWidget(
              () {
                if (personal != null && userId != null) {
                  // For Personal
                  VariableConst.personalChatDbService.deleteChatText(
                    userId: userId!,
                    yourId: yourId,
                    chatId: chatId,
                    message: personal!.message!,
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
          builder: (context, isDark) => (personal != null)
              ? Row(
                  mainAxisAlignment: (fromYou)
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    (fromYou)
                        ? (personal!.read!)
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
                            Flexible(
                              child: Linkify(
                                onOpen: (link) async {
                                  if (await canLaunch(link.url)) {
                                    await launch(link.url);
                                  } else {
                                    throw 'Could not launch $link';
                                  }
                                },
                                text: personal!.message!,
                                style: FontConfig.light(
                                  size: 12,
                                  color: (fromYou)
                                      ? Colors.white
                                      : ColorConfig.colorDark,
                                ),
                                linkStyle: FontConfig.semibold(
                                  size: 12,
                                  color: (fromYou)
                                      ? Colors.white
                                      : ColorConfig.colorDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              personal!.time!,
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
                    (!personal!.read! && !fromYou)
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
                        ? (group!.read!.where((id) => id != yourId).isNotEmpty)
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
                                    stream: FirebaseUtils.dbUser(group!.from!)
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
                                Flexible(
                                  child: Linkify(
                                    text: group!.message!,
                                    style: FontConfig.light(
                                        size: 12,
                                        color: (fromYou)
                                            ? Colors.white
                                            : ColorConfig.colorDark),
                                    linkStyle: FontConfig.semibold(
                                        size: 12,
                                        color: (fromYou)
                                            ? Colors.white
                                            : ColorConfig.colorDark),
                                    onOpen: (link) async {
                                      if (await canLaunch(link.url)) {
                                        await launch(link.url);
                                      } else {
                                        throw 'Could not launch $link';
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  group!.time!,
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
                    ((group!.read!.where((id) => id == yourId).isEmpty) &&
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

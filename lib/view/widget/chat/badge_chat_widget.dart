import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class BadgeChatWidget extends StatelessWidget {
  const BadgeChatWidget({
    Key? key,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final String yourId, userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseUtils.dbChat(yourId).doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        // Object
        final UserChat chat =
            UserChat.fromMap(snapshot.data!.data() as Map<String, dynamic>);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Time
            BlocSelector<ThemeCubit, ThemeState, bool>(
              selector: (state) => state.isDark,
              builder: (context, isDark) => Text(
                chat.date!.substring(11, chat.date!.length),
                style: FontConfig.light(
                  size: 10,
                  color: (isDark) ? Colors.white : ColorConfig.colorDark,
                ),
              ),
            ),
            // Total Unread
            (chat.totalUnread! > 0)
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: ColorConfig.colorPrimary,
                    ),
                    child: Text(
                      "${chat.totalUnread}",
                      style: FontConfig.light(size: 8, color: Colors.white),
                    ),
                  )
                : const SizedBox(),
          ],
        );
      },
    );
  }
}

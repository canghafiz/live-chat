import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class ImageBubbleChat extends StatelessWidget {
  const ImageBubbleChat({
    Key? key,
    required this.yourId,
    required this.personal,
    required this.group,
  }) : super(key: key);
  final String yourId;
  final PersonalChatImage? personal;
  final GroupChatImage? group;

  @override
  Widget build(BuildContext context) {
    final bool fromYou =
        (personal != null) ? personal!.from == yourId : group!.from == yourId;
    return GestureDetector(
      onTap: () {
        // Navigate
        RouteHandle.toDetailImage(
          context: context,
          url: (personal != null) ? personal!.url! : group!.url!,
        );
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
                      child: CachedNetworkImage(
                        imageUrl: personal!.url!,
                        fit: BoxFit.cover,
                        imageBuilder: (context, image) => Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (personal!.from! == yourId)
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
                            crossAxisAlignment: (fromYou)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width * 1 / 3,
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(25),
                                        topRight: const Radius.circular(25),
                                        bottomRight:
                                            Radius.circular((fromYou) ? 0 : 25),
                                        bottomLeft:
                                            Radius.circular((fromYou) ? 25 : 0),
                                      ),
                                      image: DecorationImage(
                                        image: image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
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
                      child: CachedNetworkImage(
                        imageUrl: group!.url!,
                        fit: BoxFit.cover,
                        imageBuilder: (context, image) => Container(
                          padding: const EdgeInsets.all(10),
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
                            crossAxisAlignment: (fromYou)
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
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
                              SizedBox(
                                width: MediaQuery.of(context).size.width -
                                    MediaQuery.of(context).size.width * 1 / 3,
                                child: AspectRatio(
                                  aspectRatio: 1.1,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(25),
                                        topRight: const Radius.circular(25),
                                        bottomRight:
                                            Radius.circular((fromYou) ? 0 : 25),
                                        bottomLeft:
                                            Radius.circular((fromYou) ? 25 : 0),
                                      ),
                                      image: DecorationImage(
                                        image: image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
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
                        ),
                      ),
                    ),
                    (!fromYou)
                        ? const SizedBox(width: 8)
                        : const SizedBox(width: 0),
                    (group!.read!.where((id) => id == yourId).isEmpty &&
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class CardContactWidget extends StatelessWidget {
  const CardContactWidget({
    Key? key,
    required this.yourId,
    required this.groupId,
    required this.userId,
  }) : super(key: key);
  final String yourId;
  final String? userId, groupId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => (userId != null)
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbUser(userId!).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Object
                final User user =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                return ListTile(
                  onTap: () {
                    // Navigate
                    RouteHandle.toPersonalDetailPage(
                      context: context,
                      userId: userId!,
                      yourId: yourId,
                    );
                  },
                  leading: SizedBox(
                    width: 36,
                    child: PhotoProfileWidget(
                      userId: snapshot.data!.id,
                      size: 36,
                    ),
                  ),
                  title: Text(
                    user.name!,
                    style: FontConfig.medium(
                      size: 14,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: ColorConfig.colorPrimary,
                  ),
                );
              },
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbGroup(groupId!).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                } else {
                  if (snapshot.data != null) {
                    // Object
                    final Group group = Group.fromMap(
                        snapshot.data!.data() as Map<String, dynamic>);

                    return ListTile(
                      onTap: () {
                        // Navigate
                        RouteHandle.toGroupDetailPage(
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
                        group.name!,
                        style: FontConfig.medium(
                          size: 14,
                          color:
                              (isDark) ? Colors.white : ColorConfig.colorDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_sharp,
                        color: ColorConfig.colorPrimary,
                      ),
                    );
                  } else {
                    // Update User Db
                    User.dbService.outGroup(yourId: yourId, groupId: groupId!);
                    return const SizedBox();
                  }
                }
              },
            ),
    );
  }
}

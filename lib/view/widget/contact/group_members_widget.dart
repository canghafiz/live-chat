import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class GroupMembers extends StatelessWidget {
  const GroupMembers({
    Key? key,
    required this.groupId,
    required this.userId,
    required this.showTotalMembers,
    required this.isDark,
  }) : super(key: key);
  final String? groupId;
  final String userId;
  final bool showTotalMembers, isDark;

  @override
  Widget build(BuildContext context) {
    // Update State
    GroupCubitHandle.read(context).clear();
    return SizedBox(
      width: double.infinity,
      child: BlocSelector<GroupCubit, GroupState, GroupState>(
        selector: (state) => state,
        builder: (context, members) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            (showTotalMembers)
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VariableConst.margin),
                    child: Text(
                      "Members : ${members.usersId.length}",
                      style: FontConfig.medium(
                        size: 16,
                        color: (isDark) ? Colors.white : ColorConfig.colorDark,
                      ),
                    ),
                  )
                : const SizedBox(),
            // Selected Members
            (members.usersId.isEmpty)
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: members.usersId.length,
                        itemBuilder: (context, index) {
                          final String userId = members.usersId[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              left: VariableConst.margin,
                              right: (index == members.usersId.length - 1)
                                  ? VariableConst.margin
                                  : 0,
                            ),
                            child: profileGroupMember(
                              size: 48,
                              icon: Icons.clear,
                              userId: userId,
                              onTap: () {
                                // Update State
                                GroupCubitHandle.read(context).delete(index);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
            (members.usersId.isEmpty && !showTotalMembers)
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VariableConst.margin),
                    child: Divider(
                      thickness: 1,
                      height: 5,
                      color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                  ),
            // Members
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseUtils.dbUsers().orderBy("name").snapshots(),
              builder: (context, snapshotUsers) {
                if (!snapshotUsers.hasData) {
                  return const SizedBox();
                }
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseUtils.dbUser(userId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }
                    // Object
                    final User you = User.fromMap(
                        snapshot.data!.data() as Map<String, dynamic>);

                    return (you.contacts!.isEmpty)
                        ? Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              left: VariableConst.margin,
                              right: VariableConst.margin,
                            ),
                            child: Text(
                              "Empty Contacts",
                              style: FontConfig.medium(
                                size: 14,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : (groupId != null)
                            ? StreamBuilder<DocumentSnapshot>(
                                stream:
                                    FirebaseUtils.dbGroup(groupId!).snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }
                                  // Object
                                  final Group group = Group.fromMap(
                                      snapshot.data!.data()
                                          as Map<String, dynamic>);

                                  return Column(
                                    children: snapshotUsers.data!.docs.map(
                                      (doc) {
                                        var filter = you.contacts!.where(
                                            (data) =>
                                                data["user_id"] == doc.id);

                                        return Column(
                                          children: filter.map((data) {
                                            // Object
                                            final ContactUser contact =
                                                ContactUser.fromMap(data);

                                            final bool isMember = (group
                                                .members!
                                                .where((data) =>
                                                    data['user_id'] ==
                                                    contact.userId)
                                                .isNotEmpty);

                                            return StreamBuilder<
                                                DocumentSnapshot>(
                                              stream: FirebaseUtils.dbUser(
                                                      contact.userId!)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const SizedBox();
                                                }
                                                // Object
                                                final User user = User.fromMap(
                                                    snapshot.data!.data()
                                                        as Map<String,
                                                            dynamic>);

                                                return Container(
                                                  color: (!isMember)
                                                      ? Colors.transparent
                                                      : Colors.grey,
                                                  child: ListTile(
                                                    enabled: !isMember,
                                                    onTap: () {
                                                      if (!members.usersId
                                                          .contains(contact
                                                              .userId!)) {
                                                        // Update State
                                                        GroupCubitHandle.read(
                                                                context)
                                                            .add(contact
                                                                .userId!);
                                                        return;
                                                      }
                                                      // Update State
                                                      GroupCubitHandle.read(
                                                              context)
                                                          .delete(
                                                        members.usersId
                                                            .indexWhere((id) =>
                                                                id ==
                                                                contact.userId),
                                                      );
                                                    },
                                                    leading: profileGroupMember(
                                                      icon: (members.usersId
                                                              .contains(contact
                                                                  .userId!))
                                                          ? Icons.check
                                                          : null,
                                                      size: 36,
                                                      userId: contact.userId!,
                                                      onTap: null,
                                                    ),
                                                    title: Text(
                                                      user.name!,
                                                      style: FontConfig.medium(
                                                        size: 14,
                                                        color: (isDark)
                                                            ? Colors.white
                                                            : ColorConfig
                                                                .colorDark,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ).toList(),
                                  );
                                },
                              )
                            : Column(
                                children: snapshotUsers.data!.docs.map(
                                  (doc) {
                                    var filter = you.contacts!.where(
                                        (data) => data["user_id"] == doc.id);

                                    return Column(
                                      children: filter.map((data) {
                                        // Object
                                        final ContactUser contact =
                                            ContactUser.fromMap(data);

                                        return StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseUtils.dbUser(
                                                  contact.userId!)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const SizedBox();
                                            }
                                            // Object
                                            final User user = User.fromMap(
                                                snapshot.data!.data()
                                                    as Map<String, dynamic>);

                                            return ListTile(
                                              onTap: () {
                                                if (!members.usersId.contains(
                                                    contact.userId!)) {
                                                  // Update State
                                                  GroupCubitHandle.read(context)
                                                      .add(contact.userId!);
                                                  return;
                                                }
                                                // Update State
                                                GroupCubitHandle.read(context)
                                                    .delete(
                                                  members.usersId.indexWhere(
                                                      (id) =>
                                                          id == contact.userId),
                                                );
                                              },
                                              leading: profileGroupMember(
                                                icon: (members.usersId.contains(
                                                        contact.userId!))
                                                    ? Icons.check
                                                    : null,
                                                size: 36,
                                                userId: contact.userId!,
                                                onTap: null,
                                              ),
                                              title: Text(
                                                user.name!,
                                                style: FontConfig.medium(
                                                  size: 14,
                                                  color: (isDark)
                                                      ? Colors.white
                                                      : ColorConfig.colorDark,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    );
                                  },
                                ).toList(),
                              );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget profileGroupMember({
  required double size,
  required IconData? icon,
  required String userId,
  required Function? onTap,
}) {
  return GestureDetector(
    onTap: (onTap == null) ? null : () => onTap(),
    child: SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          PhotoProfileWidget(userId: userId, size: size),
          Align(
            alignment: Alignment.bottomRight,
            child: (icon == null)
                ? const SizedBox()
                : Container(
                    width: ((size * 37.5) / 100).ceil().toDouble(),
                    height: ((size * 37.5) / 100).ceil().toDouble(),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorConfig.colorPrimary,
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: ((size * 29) / 100).ceil().toDouble(),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class PersonalDetailPage extends StatelessWidget {
  const PersonalDetailPage({
    Key? key,
    required this.userId,
    required this.yourId,
  }) : super(key: key);
  final String yourId, userId;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                // Navigate
                RouteHandle.toDetailPersonalChat(
                  context: context,
                  userId: userId,
                  yourId: yourId,
                );
              },
              icon: const Icon(Icons.chat),
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbUser(userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              // Object
              final User user =
                  User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseUtils.dbUser(yourId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  // Object
                  final User you = User.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Photo Profile
                        GestureDetector(
                          onTap: () {
                            if (user.profile != null) {
                              // Navigate
                              RouteHandle.toDetailImage(
                                context: context,
                                url: user.profile!,
                                file: null,
                              );
                            }
                          },
                          child: BasicPhotoProfile(
                            size: 124,
                            url: user.profile,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Text(
                          user.name!,
                          style: FontConfig.medium(
                            size: 20,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Email
                        Text(
                          user.email!,
                          style: FontConfig.light(
                            size: 12,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 24),
                        // Voice || Video Call
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                              icon: Icon(
                                Icons.call,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
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
                              icon: Icon(
                                Icons.videocam,
                                color: (isDark)
                                    ? Colors.white
                                    : ColorConfig.colorDark,
                              ),
                            ),
                          ],
                        ),
                        // Same Group
                        (user.groups!.isNotEmpty)
                            ? SizedBox(
                                width: double.infinity,
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseUtils.dbGroups()
                                      .orderBy("name")
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: SizedBox(
                                          width: 36,
                                          height: 36,
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }
                                    return (snapshot.data!.docs.isEmpty)
                                        ? const SizedBox()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  36,
                                                  16,
                                                  12,
                                                ),
                                                child: Text(
                                                  "Same Group",
                                                  style: FontConfig.medium(
                                                    size: 16,
                                                    color: (isDark)
                                                        ? Colors.white
                                                        : ColorConfig.colorDark,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children: List.generate(
                                                    user.groups!.length,
                                                    (index) {
                                                  final String id =
                                                      user.groups![index];

                                                  var filter = you.groups!
                                                      .where(
                                                          (data) => data == id);

                                                  return Column(
                                                    children: filter
                                                        .map(
                                                          (id) =>
                                                              CardSameGroupWidget(
                                                            groupId: id,
                                                          ),
                                                        )
                                                        .toList(),
                                                  );
                                                }),
                                              ),
                                            ],
                                          );
                                  },
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 24),
                        // Delete || Add
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: (you.contacts!
                                  .where((data) => data['user_id'] == userId)
                                  .isNotEmpty)
                              ? ListTile(
                                  onTap: () {
                                    // Update Db
                                    User.dbService
                                        .deleteContact(
                                      yourId: yourId,
                                      userId: userId,
                                    )
                                        .then(
                                      (success) {
                                        if (success) {
                                          // Show Snackbar
                                          showCustomSnackbar(
                                            context: context,
                                            text:
                                                "This user has been delete from contact",
                                            color: Colors.green,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Delete From Contact",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ListTile(
                                  onTap: () {
                                    // Update Db
                                    User.dbService
                                        .addContact(
                                      yourId: yourId,
                                      userId: userId,
                                    )
                                        .then(
                                      (success) {
                                        if (success) {
                                          // Show Snackbar
                                          showCustomSnackbar(
                                            context: context,
                                            text:
                                                "This user has been add to contact",
                                            color: Colors.green,
                                          );
                                        }
                                      },
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Add To Contact",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                        // Block
                        Container(
                          color: ColorConfig.colorPrimary,
                          child: (you.contacts!
                                  .where((data) =>
                                      data['user_id'] == userId &&
                                      data['block'])
                                  .isNotEmpty)
                              ? ListTile(
                                  onTap: () {
                                    // Update Db
                                    User.dbService.updateBlock(
                                      yourId: yourId,
                                      userId: userId,
                                      value: false,
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.block,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Unblock",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ListTile(
                                  onTap: () {
                                    // Update Db
                                    User.dbService.updateBlock(
                                      yourId: yourId,
                                      userId: userId,
                                      value: true,
                                    );
                                  },
                                  leading: const Icon(
                                    Icons.block,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    "Block",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

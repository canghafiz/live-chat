import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';
import 'package:path/path.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({
    Key? key,
    required this.groupId,
    required this.yourId,
  }) : super(key: key);
  final String yourId, groupId;

  @override
  Widget build(BuildContext context) {
    void addMember() {
      // Update Group Db
      Group.dbService.addMember(groupId: groupId, userId: yourId);
      // Update User Db
      User.dbService.joinGroup(yourId: yourId, groupId: groupId);
    }

    void unMember() {
      // Update Group Db
      Group.dbService.deleteMember(groupId: groupId, userId: yourId);
      // Update User Db
      User.dbService.outGroup(yourId: yourId, groupId: groupId);
    }

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
                RouteHandle.toDetailGroupChat(
                  context: context,
                  groupId: groupId,
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
            stream: FirebaseUtils.dbGroup(groupId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }
              // Object
              final Group group =
                  Group.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseUtils.dbUser(group.owner!).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  // Object
                  final User user = User.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        // Photo Profile
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            (group.owner != yourId)
                                ? GestureDetector(
                                    onTap: () {
                                      if (group.profile != null) {
                                        // Navigate
                                        RouteHandle.toDetailImage(
                                          context: context,
                                          url: group.profile!,
                                          file: null,
                                        );
                                      }
                                    },
                                    child: BasicPhotoProfile(
                                      size: 124,
                                      url: group.profile,
                                    ),
                                  )
                                : SizedBox(
                                    width: 124,
                                    height: 124,
                                    child: Stack(
                                      children: [
                                        // Photo
                                        GestureDetector(
                                          onTap: () {
                                            if (group.profile != null) {
                                              // Navigate
                                              RouteHandle.toDetailImage(
                                                context: context,
                                                url: group.profile!,
                                                file: null,
                                              );
                                            }
                                          },
                                          child: BasicPhotoProfile(
                                            size: 124,
                                            url: group.profile,
                                          ),
                                        ),
                                        // Btn Take
                                        GestureDetector(
                                          onTap: () {
                                            // Show Modal Bottom
                                            FunctionUtils.showCustomBottomSheet(
                                              context: context,
                                              content: PhotoBottomWidget(
                                                imageNotNull:
                                                    group.profile != null,
                                                delete: () {
                                                  // Update Storage
                                                  FirebaseStorageService.delete(
                                                          group.profile!)
                                                      .then(
                                                    (_) {
                                                      // Update Group Db
                                                      Group.dbService
                                                          .updateProfile(
                                                        groupId: groupId,
                                                        url: null,
                                                      );
                                                    },
                                                  );

                                                  Navigator.pop(context);
                                                },
                                                dbUpdate: (value) {
                                                  if (group.profile != null) {
                                                    // Update Storage
                                                    FirebaseStorageService
                                                            .delete(
                                                                group.profile!)
                                                        .then(
                                                      (_) {
                                                        // Update Group Db
                                                        Group.dbService
                                                            .updateProfile(
                                                          groupId: groupId,
                                                          url: null,
                                                        );

                                                        // Update Storage
                                                        FirebaseStorageService.uploadImage(
                                                                folderName: Group
                                                                    .profileUrl,
                                                                fileName:
                                                                    basename(value
                                                                        .path),
                                                                pickedFile:
                                                                    XFile(value
                                                                        .path))
                                                            .then(
                                                          (url) => Group
                                                              .dbService
                                                              .updateProfile(
                                                            groupId: groupId,
                                                            url: url,
                                                          ),
                                                        );
                                                      },
                                                    );
                                                    return;
                                                  }

                                                  // Update Storage
                                                  FirebaseStorageService
                                                          .uploadImage(
                                                              folderName: Group
                                                                  .profileUrl,
                                                              fileName:
                                                                  basename(value
                                                                      .path),
                                                              pickedFile: XFile(
                                                                  value.path))
                                                      .then(
                                                    (url) => Group.dbService
                                                        .updateProfile(
                                                      groupId: groupId,
                                                      url: url,
                                                    ),
                                                  );

                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                          },
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: ColorConfig.colorPrimary,
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: (group.owner! != yourId)
                              ? Text(
                                  group.name!,
                                  style: FontConfig.medium(
                                    size: 20,
                                    color: (isDark)
                                        ? Colors.white
                                        : ColorConfig.colorDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : GestureDetector(
                                  onTap: () {
                                    // Show Modal Bottom
                                    FunctionUtils.showCustomBottomSheet(
                                      context: context,
                                      content: EditFormWidget(
                                        inputFormater: null,
                                        inputType: null,
                                        intialValue: group.name!,
                                        title: "Name",
                                        onSubmit: (value) {
                                          // Update Group Db
                                          Group.dbService.updateName(
                                            groupId: groupId,
                                            name: value,
                                          );

                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          group.name!,
                                          style: FontConfig.medium(
                                            size: 20,
                                            color: (isDark)
                                                ? Colors.white
                                                : ColorConfig.colorDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.edit,
                                        color: (isDark)
                                            ? Colors.white
                                            : ColorConfig.colorDark,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                        // Description
                        Text(
                          "GROUP | ${group.members!.length} MEMBERS",
                          style: FontConfig.light(
                            size: 12,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 36),
                        // Owner
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  36,
                                  16,
                                  12,
                                ),
                                child: Text(
                                  "Owner",
                                  style: FontConfig.medium(
                                    size: 16,
                                    color: (isDark)
                                        ? Colors.white
                                        : ColorConfig.colorDark,
                                  ),
                                ),
                              ),
                              Container(
                                color: ColorConfig.colorPrimary,
                                child: ListTile(
                                  onTap: () {
                                    if (group.owner == yourId) {
                                      // Navigate
                                      RouteHandle.toMainPage(
                                        context: context,
                                        userId: yourId,
                                      );

                                      // Update State
                                      NavigationCubitHandle.read(context)
                                          .setNavigation(3);

                                      return;
                                    }

                                    // Navigate
                                    RouteHandle.toPersonalDetailPage(
                                      context: context,
                                      userId: group.owner!,
                                      yourId: yourId,
                                    );
                                  },
                                  leading: BasicPhotoProfile(
                                    size: 36,
                                    url: user.profile,
                                    color: Colors.white,
                                  ),
                                  title: Text(
                                    (group.owner == yourId)
                                        ? "You"
                                        : user.name!,
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // Members
                        SizedBox(
                          width: double.infinity,
                          child: (group.members!.isEmpty)
                              ? const SizedBox()
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseUtils.dbUsers()
                                      .orderBy('name')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const SizedBox();
                                    }

                                    return (group.members!.isEmpty)
                                        ? const SizedBox()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                  16,
                                                  24,
                                                  16,
                                                  12,
                                                ),
                                                child: Text(
                                                  "Members",
                                                  style: FontConfig.medium(
                                                    size: 16,
                                                    color: (isDark)
                                                        ? Colors.white
                                                        : ColorConfig.colorDark,
                                                  ),
                                                ),
                                              ),
                                              Column(
                                                children:
                                                    group.members!.map((data) {
                                                  // Object
                                                  final Member member =
                                                      Member.fromMap(data);

                                                  return StreamBuilder<
                                                      DocumentSnapshot>(
                                                    stream:
                                                        FirebaseUtils.dbUser(
                                                      member.userId!,
                                                    ).snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return const SizedBox();
                                                      }
                                                      // Object
                                                      final User user =
                                                          User.fromMap(snapshot
                                                                  .data!
                                                                  .data()
                                                              as Map<String,
                                                                  dynamic>);

                                                      return Container(
                                                        color: ColorConfig
                                                            .colorPrimary,
                                                        child: ListTile(
                                                          onTap: () {
                                                            if (snapshot
                                                                    .data!.id ==
                                                                yourId) {
                                                              // Navigate
                                                              RouteHandle
                                                                  .toMainPage(
                                                                context:
                                                                    context,
                                                                userId: yourId,
                                                              );

                                                              // Update State
                                                              NavigationCubitHandle
                                                                      .read(
                                                                          context)
                                                                  .setNavigation(
                                                                      3);

                                                              return;
                                                            }
                                                            // Navigate
                                                            RouteHandle
                                                                .toPersonalDetailPage(
                                                              context: context,
                                                              userId: snapshot
                                                                  .data!.id,
                                                              yourId: yourId,
                                                            );
                                                          },
                                                          leading:
                                                              BasicPhotoProfile(
                                                            size: 36,
                                                            url: user.profile,
                                                            color: Colors.white,
                                                          ),
                                                          title: Text(
                                                            (snapshot.data!
                                                                        .id ==
                                                                    yourId)
                                                                ? "You"
                                                                : user.name!,
                                                            style: FontConfig
                                                                .medium(
                                                              size: 14,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          trailing: const Icon(
                                                            Icons
                                                                .arrow_forward_ios,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }).toList(),
                                              ),
                                              (group.owner == yourId)
                                                  ? Container(
                                                      color: ColorConfig
                                                          .colorPrimary,
                                                      child: ListTile(
                                                        onTap: () {
                                                          // Navigate
                                                          RouteHandle
                                                              .toAddMember(
                                                            context: context,
                                                            userId: yourId,
                                                            groupId: groupId,
                                                          );
                                                        },
                                                        leading: const Icon(
                                                            Icons.add,
                                                            color:
                                                                Colors.white),
                                                        title: Text(
                                                          "Add Member",
                                                          style:
                                                              FontConfig.medium(
                                                            size: 14,
                                                            color: Colors.white,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          );
                                  },
                                ),
                        ),
                        SizedBox(height: (group.owner == yourId) ? 24 : 0),
                        // Delete
                        (group.owner == yourId)
                            ? Container(
                                color: ColorConfig.colorPrimary,
                                child: ListTile(
                                  onTap: () {
                                    if (group.profile != null) {
                                      // Update Storage
                                      FirebaseStorageService.delete(
                                              group.profile!)
                                          .then(
                                        (_) => Group.dbService
                                            .deleteGroup(groupId),
                                      );
                                      Navigator.pop(context);
                                      return;
                                    }

                                    // Update Group Db
                                    Group.dbService.deleteGroup(groupId);
                                    Navigator.pop(context);
                                  },
                                  leading: const Icon(Icons.delete,
                                      color: Colors.white),
                                  title: Text(
                                    "Delete Group",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 24),
                        // Out
                        (group.members!
                                .where((data) => data['user_id'] == yourId)
                                .isNotEmpty)
                            ? Container(
                                color: ColorConfig.colorPrimary,
                                child: ListTile(
                                  onTap: () {
                                    unMember();
                                  },
                                  leading: const Icon(Icons.exit_to_app,
                                      color: Colors.white),
                                  title: Text(
                                    "Out From Group",
                                    style: FontConfig.medium(
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                            : Container(
                                color: ColorConfig.colorPrimary,
                                child: ListTile(
                                  onTap: () {
                                    addMember();
                                  },
                                  title: Center(
                                    child: Text(
                                      "Join To Group",
                                      style: FontConfig.medium(
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              )
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

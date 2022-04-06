import 'dart:io';

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

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({
    Key? key,
    required this.yourId,
  }) : super(key: key);
  final String yourId;

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final formKey = GlobalKey<FormState>();

  void findGroup() {
    FirebaseUtils.dbUser(widget.yourId).get().then(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);

        // Group
        FirebaseUtils.dbGroups().get().then(
          (query) {
            for (DocumentSnapshot doc in query.docs) {
              // Object
              final Group group =
                  Group.fromMap(doc.data() as Map<String, dynamic>);

              if (!user.groups!.contains(doc.id)) {
                for (Map<String, dynamic> data in group.members!) {
                  // Object
                  final Member member = Member.fromMap(data);

                  if (member.userId! == widget.yourId) {
                    // Update User Db
                    User.dbService.joinGroup(
                      yourId: widget.yourId,
                      groupId: doc.id,
                    );
                  }

                  // Update User Db
                  User.dbService.joinGroup(
                    yourId: member.userId!,
                    groupId: doc.id,
                  );
                }
              }
            }
          },
        );
      },
    );
  }

  void create({
    required BuildContext context,
    required List members,
    required File? file,
  }) {
    // Temp
    List tempMembers = members;
    tempMembers.add(widget.yourId);

    if (file != null) {
      // Update Firebase Storage
      FirebaseStorageService.uploadImage(
        folderName: Group.profileUrl,
        fileName: basename(file.path),
        pickedFile: XFile(file.path),
      ).then(
        (url) {
          // Update Group Db
          Group.dbService
              .createGroup(
            members: tempMembers,
            name: controller.text,
            yourId: widget.yourId,
            profile: url,
          )
              .then(
            (success) {
              if (success) {
                // Check Group & Update User Db
                findGroup();

                Navigator.pop(context);
              }
            },
          );
        },
      );
      return;
    }

    // Update Group Db
    Group.dbService
        .createGroup(
      members: members,
      name: controller.text,
      yourId: widget.yourId,
      profile: null,
    )
        .then(
      (success) {
        if (success) {
          // Check Group & Update User Db
          findGroup();

          Navigator.pop(context);
        }
      },
    );
  }

  // Controller
  final controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update State
    GroupCubitHandle.read(context).updateImage(null);

    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // Call Logic & Update Db
              create(
                context: context,
                members: GroupCubitHandle.read(context).state.usersId,
                file: GroupCubitHandle.read(context).state.imageFile,
              );
            }
          },
          child: const Icon(Icons.arrow_forward, color: Colors.white),
          backgroundColor: ColorConfig.colorPrimary,
        ),
        appBar: AppBar(
          title: Text(
            'Create Group',
            style: FontConfig.medium(size: 20, color: Colors.white),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                // Photo
                BlocSelector<GroupCubit, GroupState, File?>(
                  selector: (state) => state.imageFile,
                  builder: (context, file) => SizedBox(
                    width: 124,
                    height: 124,
                    child: Stack(
                      children: [
                        // Photo
                        GestureDetector(
                          onTap: () {
                            if (file != null) {
                              // Navigate
                              RouteHandle.toDetailImage(
                                context: context,
                                url: null,
                                file: file,
                              );
                            }
                          },
                          child: ProfileCreateGroupWidget(
                            file: file,
                            isDark: isDark,
                          ),
                        ),
                        // Btn Take
                        GestureDetector(
                          onTap: () {
                            // Show Modal Bottom
                            FunctionUtils.showCustomBottomSheet(
                              context: context,
                              content: PhotoBottomWidget(
                                imageNotNull: file != null,
                                delete: () {
                                  // Update State
                                  GroupCubitHandle.read(context)
                                      .updateImage(null);
                                  Navigator.pop(context);
                                },
                                dbUpdate: (value) {
                                  // Update State
                                  GroupCubitHandle.read(context)
                                      .updateImage(value);
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
                ),
                const SizedBox(height: 24),
                // Form
                Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VariableConst.margin,
                      vertical: 24,
                    ),
                    child: TextFormField(
                      maxLength: 75,
                      controller: controller,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                      style: FontConfig.medium(
                        size: 14,
                        color: (isDark) ? Colors.white : ColorConfig.colorDark,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        labelText: "Name",
                        labelStyle: FontConfig.medium(
                          size: 12,
                          color: Colors.grey,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Members
                GroupMembers(
                  userId: widget.yourId,
                  showTotalMembers: true,
                  isDark: isDark,
                  groupId: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

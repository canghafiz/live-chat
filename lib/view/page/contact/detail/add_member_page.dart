import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class AddMemberPage extends StatelessWidget {
  const AddMemberPage({
    Key? key,
    required this.groupId,
    required this.userId,
  }) : super(key: key);
  final String userId, groupId;

  @override
  Widget build(BuildContext context) {
    // Update State
    return BlocSelector<ThemeCubit, ThemeState, bool>(
      selector: (state) => state.isDark,
      builder: (context, isDark) => Scaffold(
        backgroundColor: ColorConfig.colorPrimary,
        extendBody: true,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (GroupCubitHandle.read(context).state.usersId.isNotEmpty) {
              for (String id in GroupCubitHandle.read(context).state.usersId) {
                // Update Group Db
                Group.dbService.addMember(groupId: groupId, userId: id);

                // Update User Db
                User.dbService.joinGroup(yourId: id, groupId: groupId);
              }

              Navigator.pop(context);
              return;
            }

            // Show Snackbar
            showCustomSnackbar(
              context: context,
              text: "Please add some new users!",
              color: Colors.red,
            );
          },
          child: const Icon(Icons.arrow_forward, color: Colors.white),
          backgroundColor: ColorConfig.colorPrimary,
        ),
        appBar: AppBar(
          title: Text(
            'Add Member',
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
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseUtils.dbGroup(groupId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              // Object
              final Group group =
                  Group.fromMap(snapshot.data!.data() as Map<String, dynamic>);

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      color: (!isDark) ? Colors.white : ColorConfig.colorDark,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          group.name!,
                          style: FontConfig.medium(
                            size: 16,
                            color:
                                (isDark) ? Colors.white : ColorConfig.colorDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  Divider(
                    color: (isDark) ? Colors.white : ColorConfig.colorDark,
                    thickness: 1,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: GroupMembers(
                        userId: userId,
                        showTotalMembers: false,
                        isDark: isDark,
                        groupId: groupId,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

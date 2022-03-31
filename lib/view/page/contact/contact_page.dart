import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

import '../../../cubit/export_cubit.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key, required this.userId}) : super(key: key);
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Show Modal Bottom
            FunctionUtils.showCustomBottomSheet(
              context: context,
              content: BottomContactWidget(yourId: userId),
            );
          },
          backgroundColor: ColorConfig.colorPrimary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        appBar: AppBar(
          title: Text(
            "Contacts",
            style: FontConfig.medium(size: 20, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (TagCubitHandle.read(context).state.type ==
                    TagType.personal) {
                  // Navigate
                  RouteHandle.toPersonalContactSearch(
                    context: context,
                    yourId: userId,
                  );
                  return;
                }

                // Navigate
                RouteHandle.toGroupContactSearch(
                  context: context,
                  yourId: userId,
                );
              },
              icon: const Icon(Icons.search),
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
                    ? Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseUtils.dbUsers()
                              .orderBy("name")
                              .snapshots(),
                          builder: (context, snapshotUsers) {
                            if (!snapshotUsers.hasData) {
                              return const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseUtils.dbUser(userId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                }
                                // Object
                                final User your = User.fromMap(snapshot.data!
                                    .data() as Map<String, dynamic>);

                                return (your.contacts!.isEmpty)
                                    ? const SizedBox()
                                    : ListView.builder(
                                        itemCount:
                                            snapshotUsers.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          String id = snapshotUsers
                                              .data!.docs[index].id;

                                          var filter = your.contacts!.where(
                                            (data) => data['user_id'] == id,
                                          );

                                          return Column(
                                            children: filter.map(
                                              (data) {
                                                // Object
                                                final ContactUser contact =
                                                    ContactUser.fromMap(data);

                                                return CardContactWidget(
                                                  yourId: userId,
                                                  groupId: null,
                                                  userId: contact.userId,
                                                );
                                              },
                                            ).toList(),
                                          );
                                        },
                                      );
                              },
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseUtils.dbGroups()
                              .orderBy("name")
                              .snapshots(),
                          builder: (context, snapshotGroups) {
                            if (!snapshotGroups.hasData) {
                              return const Center(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseUtils.dbUser(userId).snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox();
                                }
                                // Object
                                final User your = User.fromMap(snapshot.data!
                                    .data() as Map<String, dynamic>);

                                return (your.contacts!.isEmpty)
                                    ? const SizedBox()
                                    : ListView.builder(
                                        itemCount:
                                            snapshotGroups.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          String id = snapshotGroups
                                              .data!.docs[index].id;

                                          var filter = your.groups!.where(
                                            (data) => data == id,
                                          );

                                          return Column(
                                            children: filter.map(
                                              (data) {
                                                return CardContactWidget(
                                                  yourId: userId,
                                                  groupId: data,
                                                  userId: null,
                                                );
                                              },
                                            ).toList(),
                                          );
                                        },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:live_chat/cubit/export_cubit.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class PersonalChatSearchPage extends SearchDelegate {
  PersonalChatSearchPage(this.yourId);

  final String yourId;
  String? result;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbUser(yourId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Object
                final User you =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseUtils.dbUsers().snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final results = snapshot.data!.docs.where((data) {
                      final User user =
                          User.fromMap(data.data() as Map<String, dynamic>);

                      return user.name!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    });

                    return (results.isEmpty)
                        ? Center(
                            child: Text("Empty",
                                style: FontConfig.medium(
                                  size: 16,
                                  color: (isDark)
                                      ? Colors.white
                                      : ColorConfig.colorDark,
                                )))
                        : ListView(
                            children: results.map<Widget>((doc) {
                              final User user = User.fromMap(
                                  doc.data() as Map<String, dynamic>);

                              return (you.contacts!
                                      .where(
                                          (data) => data['user_id'] == doc.id)
                                      .isNotEmpty)
                                  ? ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Text(user.name ?? ""),
                                      onTap: () {
                                        // Navigate
                                        RouteHandle.toDetailPersonalChat(
                                          context: context,
                                          userId: doc.id,
                                          yourId: yourId,
                                        );
                                      },
                                    )
                                  : const SizedBox();
                            }).toList(),
                          );
                  },
                );
              },
            ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbUser(yourId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Object
                final User you =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseUtils.dbUsers().snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final results = snapshot.data!.docs.where((data) {
                      final User user =
                          User.fromMap(data.data() as Map<String, dynamic>);

                      return user.name!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    });

                    return (query.isEmpty)
                        ? const SizedBox()
                        : (results.isEmpty)
                            ? Center(
                                child: Text("Empty",
                                    style: FontConfig.medium(
                                      size: 16,
                                      color: (isDark)
                                          ? Colors.white
                                          : ColorConfig.colorDark,
                                    )))
                            : ListView(
                                children: results.map<Widget>((doc) {
                                  final User user = User.fromMap(
                                      doc.data() as Map<String, dynamic>);

                                  return (you.contacts!
                                          .where((data) =>
                                              data['user_id'] == doc.id)
                                          .isNotEmpty)
                                      ? ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          title: Text(user.name ?? ""),
                                          onTap: () {
                                            // Navigate
                                            RouteHandle.toDetailPersonalChat(
                                              context: context,
                                              userId: doc.id,
                                              yourId: yourId,
                                            );
                                          },
                                        )
                                      : const SizedBox();
                                }).toList(),
                              );
                  },
                );
              },
            ));
  }
}

class GroupChatSearchPage extends SearchDelegate {
  GroupChatSearchPage(this.yourId);

  final String yourId;
  String? result;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, result);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbUser(yourId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Object
                final User you =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseUtils.dbGroups().snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final results = snapshot.data!.docs.where((data) {
                      final Group group =
                          Group.fromMap(data.data() as Map<String, dynamic>);

                      return group.name!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    });

                    return (results.isEmpty)
                        ? Center(
                            child: Text("Empty",
                                style: FontConfig.medium(
                                  size: 16,
                                  color: (isDark)
                                      ? Colors.white
                                      : ColorConfig.colorDark,
                                )))
                        : ListView(
                            children: results.map<Widget>((doc) {
                              final Group group = Group.fromMap(
                                  doc.data() as Map<String, dynamic>);

                              return (you.groups!
                                      .where((id) => id == doc.id)
                                      .isNotEmpty)
                                  ? ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16),
                                      title: Text(group.name ?? ""),
                                      onTap: () {
                                        // Navigate
                                        RouteHandle.toDetailGroupChat(
                                          context: context,
                                          groupId: doc.id,
                                          yourId: yourId,
                                        );
                                      },
                                    )
                                  : const SizedBox();
                            }).toList(),
                          );
                  },
                );
              },
            ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return BlocSelector<ThemeCubit, ThemeState, bool>(
        selector: (state) => state.isDark,
        builder: (context, isDark) => StreamBuilder<DocumentSnapshot>(
              stream: FirebaseUtils.dbUser(yourId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox();
                }
                // Object
                final User you =
                    User.fromMap(snapshot.data!.data() as Map<String, dynamic>);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseUtils.dbGroups().snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final results = snapshot.data!.docs.where((data) {
                      final Group group =
                          Group.fromMap(data.data() as Map<String, dynamic>);

                      return group.name!
                          .toLowerCase()
                          .contains(query.toLowerCase());
                    });

                    return (query.isEmpty)
                        ? const SizedBox()
                        : (results.isEmpty)
                            ? Center(
                                child: Text("Empty",
                                    style: FontConfig.medium(
                                      size: 16,
                                      color: (isDark)
                                          ? Colors.white
                                          : ColorConfig.colorDark,
                                    )))
                            : ListView(
                                children: results.map<Widget>((doc) {
                                  final Group group = Group.fromMap(
                                      doc.data() as Map<String, dynamic>);

                                  return (you.groups!
                                          .where((id) => id == doc.id)
                                          .isNotEmpty)
                                      ? ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                          title: Text(group.name ?? ""),
                                          onTap: () {
                                            // Navigate
                                            RouteHandle.toDetailGroupChat(
                                              context: context,
                                              groupId: doc.id,
                                              yourId: yourId,
                                            );
                                          },
                                        )
                                      : const SizedBox();
                                }).toList(),
                              );
                  },
                );
              },
            ));
  }
}

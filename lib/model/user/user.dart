import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat/service/export_service.dart';
import 'package:live_chat/utils/export_utils.dart';

class User {
  User({
    this.contacts,
    this.email,
    this.groups,
    this.name,
    this.online,
    this.profile,
    this.channel,
  });

  String? name, profile, email;
  bool? online;
  List? contacts, groups;
  Map<String, dynamic>? channel;

  // Map
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      contacts: data['contacts'],
      email: data['email'],
      groups: data['groups'],
      name: data['name'],
      online: data['online'],
      profile: data['profile'],
      channel: data['channel'],
    );
  }

  // Db
  static final UserDbService _dbService = UserDbService();

  static UserDbService get dbService => _dbService;

  // Storage
  static const String _profileUrl = "Profile/Users/";

  static String get profileUrl => _profileUrl;

  // Token Notification
  static void subsToken(String userId) {
    String structure(String id) {
      return "from${id}to$userId";
    }

    // For Personal
    FirebaseUtils.dbUsers().snapshots().listen(
      (query) {
        if (query.docs.isNotEmpty) {
          for (DocumentSnapshot user in query.docs) {
            // Update Token
            NotificationService.subscribeTopic(
              structure(user.id).toString(),
            );
          }
        }
      },
    );

    // For Group
    FirebaseUtils.dbUser(userId).snapshots().listen(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);

        if (user.groups!.isNotEmpty) {
          for (String groupId in user.groups!) {
            // Update Token
            NotificationService.subscribeTopic(groupId);
          }
        }
      },
    );
  }

  static void unsubsToken(String userId) {
    String structure(String id) {
      return "from${id}to$userId";
    }

    // For Personal
    FirebaseUtils.dbUsers().get().then(
      (query) {
        if (query.docs.isNotEmpty) {
          for (DocumentSnapshot user in query.docs) {
            // Update Token
            NotificationService.unSubscribeTopic(
              structure(user.id).toString(),
            );
          }
        }
      },
    );

    // For Group
    FirebaseUtils.dbUser(userId).get().then(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);

        if (user.groups!.isNotEmpty) {
          for (String groupId in user.groups!) {
            // Update Token
            NotificationService.unSubscribeTopic(groupId);
          }
        }
      },
    );
  }
}

// Low Level
class UserDbService {
  // Singleton
  static final _instance = UserDbService._constructor(UserFirebaseDb());
  UserDbService._constructor(this._dataManager);

  factory UserDbService() {
    return _instance;
  }

  // Process
  final UserDataManager _dataManager;

  void deleteGroup(String userId) {
    FirebaseUtils.dbUser(userId).get().then(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);

        for (String id in user.groups!) {
          FirebaseUtils.dbGroup(id).get().then(
            (doc) {
              if (!doc.exists) {
                // Update User Db
                outGroup(yourId: userId, groupId: id);
              }
            },
          );
        }
      },
    );
  }

  Future<bool> updateName({
    required String userId,
    required String name,
  }) async {
    return await _dataManager.updateName(userId: userId, name: name);
  }

  Future<bool> updatePhotoProfile({
    required String userId,
    required String? url,
  }) async {
    return await _dataManager.updatePhotoProfile(userId: userId, url: url);
  }

  Future<bool> addContact({
    required String yourId,
    required String userId,
  }) async {
    return await _dataManager.addContact(yourId: yourId, userId: userId);
  }

  Future<bool> deleteContact({
    required String yourId,
    required String userId,
  }) async {
    return await _dataManager.deleteContact(yourId: yourId, userId: userId);
  }

  Future<bool> updateBlock({
    required String yourId,
    required String userId,
    required bool value,
  }) async {
    return await _dataManager.updateBlock(
      yourId: yourId,
      userId: userId,
      value: value,
    );
  }

  Future<bool> joinGroup({
    required String yourId,
    required String groupId,
  }) async {
    return await _dataManager.joinGroup(yourId: yourId, groupId: groupId);
  }

  Future<bool> outGroup({
    required String yourId,
    required String groupId,
  }) async {
    return await _dataManager.outGroup(yourId: yourId, groupId: groupId);
  }

  Future<void> updateOnlineStatus({
    required String userId,
    required bool value,
  }) async {
    _dataManager.updateOnlineStatus(userId: userId, value: value);
  }
}

abstract class UserDataManager {
  FutureOr<void> updateOnlineStatus({
    required String userId,
    required bool value,
  });

  FutureOr<bool> updatePhotoProfile({
    required String userId,
    required String? url,
  });

  FutureOr<bool> updateName({
    required String userId,
    required String name,
  });

  FutureOr<bool> addContact({
    required String yourId,
    required String userId,
  });

  FutureOr<bool> deleteContact({
    required String yourId,
    required String userId,
  });

  FutureOr<bool> updateBlock({
    required String yourId,
    required String userId,
    required bool value,
  });

  FutureOr<bool> joinGroup({
    required String yourId,
    required String groupId,
  });

  FutureOr<bool> outGroup({
    required String yourId,
    required String groupId,
  });
}

// Firebase
class UserFirebaseDb implements UserDataManager {
  // Singleton
  static final _instance = UserFirebaseDb._constructor();
  UserFirebaseDb._constructor();

  factory UserFirebaseDb() {
    return _instance;
  }

  //  Process
  @override
  Future<bool> updateName({
    required String userId,
    required String name,
  }) async {
    return await FirebaseUtils.dbUser(userId)
        .update({
          "name": name,
        })
        .then((_) => true)
        .catchError((e) {
          log("Update name error on $e");
          return false;
        });
  }

  @override
  Future<bool> updatePhotoProfile({
    required String userId,
    required String? url,
  }) async {
    return await FirebaseUtils.dbUser(userId)
        .update({
          "profile": url,
        })
        .then((_) => true)
        .catchError((e) {
          log("Update photo profile error on $e");
          return false;
        });
  }

  @override
  Future<bool> addContact({
    required String yourId,
    required String userId,
  }) async {
    return await FirebaseUtils.dbUser(yourId)
        .update({
          "contacts": FieldValue.arrayUnion([
            {
              "block": false,
              "user_id": userId,
            }
          ]),
        })
        .then((_) => true)
        .catchError((e) {
          log("Update contact error on $e");
          return false;
        });
  }

  @override
  Future<bool> deleteContact({
    required String yourId,
    required String userId,
  }) async {
    return FirebaseUtils.dbUser(yourId).get().then(
      (doc) async {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);

        final int index =
            user.contacts!.indexWhere((data) => data['user_id'] == userId);

        return FirebaseUtils.dbUser(yourId)
            .update(
              {
                "contacts": FieldValue.arrayRemove(
                  [user.contacts![index]],
                ),
              },
            )
            .then((_) => true)
            .catchError(
              (e) {
                log("Update contact error on $e");
                return false;
              },
            );
      },
    );
  }

  @override
  Future<bool> updateBlock({
    required String yourId,
    required String userId,
    required bool value,
  }) async {
    deleteContact(yourId: yourId, userId: userId);

    return FirebaseUtils.dbUser(yourId)
        .update(
          {
            "contacts": FieldValue.arrayUnion([
              {
                "block": value,
                "user_id": userId,
              },
            ]),
          },
        )
        .then((_) => true)
        .catchError(
          (e) {
            log("Update contact error on $e");
            return false;
          },
        );
  }

  @override
  Future<bool> joinGroup({
    required String yourId,
    required String groupId,
  }) async {
    return await FirebaseUtils.dbUser(yourId)
        .update({
          "groups": FieldValue.arrayUnion([groupId]),
        })
        .then((_) => true)
        .catchError((e) {
          log("Update groups error on $e");
          return false;
        });
  }

  @override
  Future<bool> outGroup(
      {required String yourId, required String groupId}) async {
    return await FirebaseUtils.dbUser(yourId)
        .update({
          "groups": FieldValue.arrayRemove([groupId]),
        })
        .then((_) => true)
        .catchError((e) {
          log("Update groups error on $e");
          return false;
        });
  }

  @override
  Future<void> updateOnlineStatus({
    required String userId,
    required bool value,
  }) async {
    await FirebaseUtils.dbUser(userId).update({"online": value});
  }
}

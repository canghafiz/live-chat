import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/model/export_model.dart';

class Group {
  Group({
    this.chatDate,
    this.members,
    this.name,
    this.owner,
    this.profile,
  });

  String? name, owner, chatDate, profile;
  List? members;

  // Map
  Map<String, dynamic> toMap({
    required List members,
    required String name,
    required String owner,
    required String? profile,
  }) {
    return {
      "chat_date": null,
      "members": members,
      "name": name,
      "owner": owner,
      "profile": profile,
    };
  }

  factory Group.fromMap(Map<String, dynamic> data) {
    return Group(
      chatDate: data['chat_date'],
      members: data['members'],
      name: data['name'],
      owner: data['owner'],
      profile: data['profile'],
    );
  }

  // Db
  static final GroupDbService _dbService = GroupDbService();

  static GroupDbService get dbService => _dbService;

  // Storage
  static const String _profileUrl = "Profile/Groups/";

  static String get profileUrl => _profileUrl;
}

// Low Level
class GroupDbService {
  // Singleton
  static final _instance = GroupDbService._constructor(GroupFirebaseDb());
  GroupDbService._constructor(this._dataManager);

  factory GroupDbService() {
    return _instance;
  }

  // Process
  final GroupDataManager _dataManager;

  Future<bool> createGroup({
    required List members,
    required String name,
    required String yourId,
    required String? profile,
  }) async {
    return _dataManager.createGroup(
      members: members,
      name: name,
      yourId: yourId,
      profile: profile,
    );
  }

  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async {
    _dataManager.addMember(groupId: groupId, userId: userId);
  }

  Future<void> deleteMember({
    required String groupId,
    required String userId,
  }) async {
    _dataManager.deleteMember(groupId: groupId, userId: userId);
  }

  Future<void> updateProfile({
    required String groupId,
    required String? url,
  }) async {
    _dataManager.updateProfile(groupId: groupId, url: url);
  }

  Future<void> updateName({
    required String groupId,
    required String name,
  }) async {
    _dataManager.updateName(groupId: groupId, name: name);
  }

  Future<void> deleteGroup(String groupId) async {
    _dataManager.deleteGroup(groupId);
  }
}

abstract class GroupDataManager {
  FutureOr<bool> createGroup({
    required List members,
    required String name,
    required String yourId,
    required String? profile,
  });
  FutureOr<void> addMember({required String groupId, required String userId});
  FutureOr<void> deleteMember({
    required String groupId,
    required String userId,
  });
  FutureOr<void> updateProfile({required String groupId, required String? url});
  FutureOr<void> updateName({required String groupId, required String name});
  FutureOr<void> deleteGroup(String groupId);
}

// Firebase
class GroupFirebaseDb implements GroupDataManager {
  // Singleton
  static final _instance = GroupFirebaseDb._constructor();
  GroupFirebaseDb._constructor();

  factory GroupFirebaseDb() {
    return _instance;
  }

  // Process
  final Group _group = Group();
  final Member _member = Member();

  @override
  Future<bool> createGroup({
    required List members,
    required String name,
    required String yourId,
    required String? profile,
  }) async {
    List temp = [];
    for (String id in members) {
      Map<String, dynamic> member = _member.toMap(id);
      temp.add(member);
    }
    return await FirebaseUtils.dbGroups()
        .add(
          _group.toMap(
            members: temp,
            name: name,
            owner: yourId,
            profile: profile,
          ),
        )
        .then((_) => true)
        .catchError(
      (e) {
        log("Create group error on $e");
        return false;
      },
    );
  }

  @override
  Future<void> addMember({
    required String groupId,
    required String userId,
  }) async {
    await FirebaseUtils.dbGroup(groupId).update({
      "members": FieldValue.arrayUnion([_member.toMap(userId)]),
    });
  }

  @override
  Future<void> deleteMember({
    required String groupId,
    required String userId,
  }) async {
    FirebaseUtils.dbGroup(groupId).get().then((doc) async {
      // Object
      final Group group = Group.fromMap(doc.data() as Map<String, dynamic>);

      final int index =
          group.members!.indexWhere((data) => data['user_id'] == userId);

      await FirebaseUtils.dbGroup(groupId).update({
        "members": FieldValue.arrayRemove([group.members![index]]),
      });
    });
  }

  @override
  Future<void> updateProfile({
    required String groupId,
    required String? url,
  }) async {
    await FirebaseUtils.dbGroup(groupId).update({"profile": url});
  }

  @override
  Future<void> updateName({
    required String groupId,
    required String name,
  }) async {
    await FirebaseUtils.dbGroup(groupId).update({"name": name});
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await FirebaseUtils.dbGroup(groupId).delete();
  }
}

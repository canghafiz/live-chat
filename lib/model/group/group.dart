import 'dart:async';

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
}

abstract class GroupDataManager {
  FutureOr<void> addMember({required String groupId, required String userId});
  FutureOr<void> deleteMember({
    required String groupId,
    required String userId,
  });
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
  final Member _member = Member();

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
}

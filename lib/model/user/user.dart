import 'dart:async';
import 'dart:developer';
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
}

abstract class UserDataManager {
  FutureOr<bool> updatePhotoProfile({
    required String userId,
    required String? url,
  });

  FutureOr<bool> updateName({
    required String userId,
    required String name,
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
}

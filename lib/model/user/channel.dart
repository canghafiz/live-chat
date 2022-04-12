import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class Channel {
  Channel({
    this.onOtherCall,
    this.proceess,
  });

  String? proceess;
  bool? onOtherCall;

  // Map
  Map<String, dynamic> toMap() {
    return {
      "calling_process": "Undoing",
      "on_other_call": false,
    };
  }

  factory Channel.fromMap(Map<String, dynamic> data) {
    return Channel(
      onOtherCall: data['on_other_call'],
      proceess: data['calling_process'],
    );
  }

  // Db
  static final ChannelDbService _db = ChannelDbService();

  static ChannelDbService get dbService => _db;

  // Check Channel Status
  static Future<bool> checkChannelOtherCall(String userId) {
    return FirebaseUtils.dbUser(userId).get().then(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);
        final Channel channel = Channel.fromMap(user.channel!);

        return channel.onOtherCall!;
      },
    );
  }

  static void checkChannelProcess({
    required String userId,
    required Function onFalse,
    required Function onAccept,
  }) {
    FirebaseUtils.dbUser(userId).snapshots().listen(
      (doc) {
        // Object
        final User user = User.fromMap(doc.data() as Map<String, dynamic>);
        final Channel channel = Channel.fromMap(user.channel!);

        if (channel.proceess == "Left") {
          onFalse.call();
        } else if (channel.proceess == "Accept") {
          onAccept.call();
        }
      },
    );
  }
}

// Low Level
class ChannelDbService {
  // Singleton
  static final _instance = ChannelDbService._constructor(ChannelFirebaseDb());
  ChannelDbService._constructor(this._dataManager);

  factory ChannelDbService() {
    return _instance;
  }

  // Process
  final ChannelDataManager _dataManager;

  Future<void> updateCallingProcess({
    required String userId,
    required String value,
  }) async {
    _dataManager.updateCallingProcess(
      userId: userId,
      value: value,
    );
  }

  Future<void> updateOnOtherCall({
    required String userId,
    required bool value,
  }) async {
    _dataManager.updateOnOtherCall(
      userId: userId,
      value: value,
    );
  }
}

abstract class ChannelDataManager {
  FutureOr<void> updateCallingProcess({
    required String userId,
    required String value,
  });
  FutureOr<void> updateOnOtherCall({
    required String userId,
    required bool value,
  });
}

// Firebase
class ChannelFirebaseDb implements ChannelDataManager {
  // Singleton
  static final _instance = ChannelFirebaseDb._constructor();
  ChannelFirebaseDb._constructor();

  factory ChannelFirebaseDb() {
    return _instance;
  }

  @override
  Future<void> updateCallingProcess({
    required String userId,
    required String value,
  }) async {
    await FirebaseUtils.dbUser(userId).set(
      {
        "channel": {
          "calling_process": value,
        },
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateOnOtherCall({
    required String userId,
    required bool value,
  }) async {
    await FirebaseUtils.dbUser(userId).set(
      {
        "channel": {
          "on_other_call": value,
        }
      },
      SetOptions(merge: true),
    );
  }
}

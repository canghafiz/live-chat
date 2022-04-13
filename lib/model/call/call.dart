import 'dart:async';

import 'package:live_chat/utils/export_utils.dart';

class Call {
  Call({
    this.answer,
    this.time,
    this.type,
    this.userId,
  });

  String? userId, time, type;
  bool? answer;

  // Map
  Map<String, dynamic> toMap({
    required String userId,
    required String type,
    required bool answer,
  }) {
    return {
      "answer": answer,
      "time":
          "${VariableConst.timeYearMonthDay.call().toString()} ${VariableConst.timeHourMin.call().toString()}",
      "type": type,
      "user_id": userId,
    };
  }

  factory Call.fromMap(Map<String, dynamic> data) {
    return Call(
      answer: data['answer'],
      time: data['time'],
      type: data['type'],
      userId: data['user_id'],
    );
  }

  // Db
  static final CallDbService _db = CallDbService();

  static CallDbService get dbService => _db;
}

// Low Level
class CallDbService {
  // Singleton
  static final _instance = CallDbService._constructor(CallFirebaseDb());
  CallDbService._constructor(this._dataManager);

  factory CallDbService() {
    return _instance;
  }

  // Process
  final CallDataManager _dataManager;

  Future<void> add({
    required String userId,
    required String type,
    required bool answer,
    required String callerId,
  }) async {
    if (answer) {
      // For You
      _dataManager.add(
        userId: userId,
        type: type,
        answer: answer,
        callerId: callerId,
      );
    } else {
      // For You
      _dataManager.add(
        userId: userId,
        type: type,
        answer: answer,
        callerId: callerId,
      );

      // For User
      _dataManager.add(
        userId: callerId,
        type: type,
        answer: answer,
        callerId: userId,
      );
    }
  }

  Future<void> deleteCall({
    required String userId,
    required String callId,
  }) async {
    _dataManager.deleteCall(userId: userId, callId: callId);
  }
}

abstract class CallDataManager {
  FutureOr<void> add({
    required String userId,
    required String type,
    required bool answer,
    required String callerId,
  });
  FutureOr<void> deleteCall({
    required String userId,
    required String callId,
  });
}

// Firebase
class CallFirebaseDb implements CallDataManager {
  // Singleton
  static final _instance = CallFirebaseDb._constructor();
  CallFirebaseDb._constructor();

  factory CallFirebaseDb() {
    return _instance;
  }

  // Process
  final Call _call = Call();

  @override
  Future<void> add({
    required String userId,
    required String type,
    required bool answer,
    required String callerId,
  }) async {
    await FirebaseUtils.dbCalls(userId).add(
      _call.toMap(
        userId: callerId,
        type: type,
        answer: answer,
      ),
    );
  }

  @override
  Future<void> deleteCall({
    required String userId,
    required String callId,
  }) async {
    await FirebaseUtils.dbCalls(userId).doc(callId).delete();
  }
}

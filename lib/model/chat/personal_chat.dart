import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_chat/utils/export_utils.dart';

class PersonalChatText {
  PersonalChatText({
    this.from,
    this.message,
    this.read,
    this.time,
    this.type,
  });

  String? type, message, time, from;
  bool? read;

  // Map
  Map<String, dynamic> toMap({
    required String userId,
    required String message,
  }) {
    return {
      "from": userId,
      "message": message,
      "read": false,
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeText,
    };
  }

  factory PersonalChatText.fromMap(Map<String, dynamic> data) {
    return PersonalChatText(
      from: data['from'],
      message: data['message'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class PersonalChatImage {
  PersonalChatImage({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  bool? read;

  // Map
  Map<String, dynamic> toMap({
    required String userId,
    required String url,
  }) {
    return {
      "from": userId,
      "url": url,
      "read": false,
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeImage,
    };
  }

  factory PersonalChatImage.fromMap(Map<String, dynamic> data) {
    return PersonalChatImage(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class PersonalChatAudio {
  PersonalChatAudio({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  bool? read;

  // Map
  Map<String, dynamic> toMap({
    required String userId,
    required String url,
  }) {
    return {
      "from": userId,
      "url": url,
      "read": false,
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeAudio,
    };
  }

  factory PersonalChatAudio.fromMap(Map<String, dynamic> data) {
    return PersonalChatAudio(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

// Low Level
class PersonalChatDbService {
  // Singleton
  static final _instance =
      PersonalChatDbService._constructor(PersonalChatFirebaseDb());
  PersonalChatDbService._constructor(this._dataManager);

  factory PersonalChatDbService() {
    return _instance;
  }

  // Process
  final PersonalChatDataManager _dataManager;

  void sendChat({
    required Function sendChat,
    required String yourId,
    required String userId,
  }) {
    // Update Chat Db
    sendChat.call();

    // For You
    updateChatDate(
        yourId: yourId,
        userId: userId,
        value:
            "${VariableConst.timeYearMonthDay.call().toString()} ${VariableConst.timeHourMin.call().toString()}");
    // For User
    updateChatDate(
        yourId: userId,
        userId: yourId,
        value:
            "${VariableConst.timeYearMonthDay.call().toString()} ${VariableConst.timeHourMin.call().toString()}");

    // Call Chat Db
    // For You
    FirebaseUtils.dbChat(yourId).doc(userId).get().then(
      (doc) {
        // Data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['chats'] != null) {
          List chats = data["chats"];

          if (!chats
              .contains(VariableConst.timeYearMonthDay.call().toString())) {
            updateChats(yourId: yourId, userId: userId);
          }
        } else {
          updateChats(yourId: yourId, userId: userId);
          updateTotalRead(
            yourId: yourId,
            userId: userId,
            value: 0,
          );
        }
      },
    );

    // For User
    FirebaseUtils.dbChat(userId).doc(yourId).get().then(
      (doc) {
        // Data
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data["chats"] != null) {
          List chats = data["chats"];

          if (!chats
              .contains(VariableConst.timeYearMonthDay.call().toString())) {
            updateChats(yourId: userId, userId: yourId);
          }
        } else {
          updateChats(yourId: userId, userId: yourId);
          updateTotalRead(
            yourId: userId,
            userId: yourId,
            value: 0,
          );
        }
      },
    );

    // Update Count Read
    FirebaseUtils.dbChat(userId)
        .doc(yourId)
        .collection(VariableConst.timeYearMonthDay.call().toString())
        .where("from", isEqualTo: yourId)
        .where("read", isEqualTo: false)
        .get()
        .then(
          (query) => updateTotalRead(
            yourId: userId,
            userId: yourId,
            value: query.docs.length,
          ),
        );
  }

  Future<void> updateChats({
    required String yourId,
    required String userId,
  }) async {
    _dataManager.updateChats(yourId: yourId, userId: userId);
  }

  Future<void> updateChatDate({
    required String yourId,
    required String userId,
    required String value,
  }) async {
    _dataManager.updateChatDate(
      yourId: yourId,
      userId: userId,
      value: value,
    );
  }

  Future<void> updateReadChat({
    required String yourId,
    required String date,
    required String userId,
    required String chatId,
  }) async {
    // For You
    _dataManager.updateReadChat(
      yourId: yourId,
      date: date,
      userId: userId,
      chatId: chatId,
    );

    // For User
    FirebaseUtils.dbChat(userId)
        .doc(yourId)
        .collection(date)
        .orderBy("time")
        .get()
        .then(
      (query) {
        final int index = query.docs
            .indexWhere((data) => !data['read'] && data['from'] != yourId);

        _dataManager.updateReadChat(
          yourId: userId,
          date: date,
          userId: yourId,
          chatId: query.docs[index].id,
        );
      },
    );
  }

  Future<void> updateTotalRead({
    required String yourId,
    required String userId,
    required int value,
  }) async {
    _dataManager.updateTotalRead(yourId: yourId, userId: userId, value: value);
  }

  Future<void> sendText({
    required String yourId,
    required String userId,
    required String date,
    required String message,
    required String from,
  }) async {
    _dataManager.sendText(
      yourId: yourId,
      userId: userId,
      date: date,
      message: message,
      from: from,
    );
  }

  Future<void> sendImage({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  }) async {
    _dataManager.sendImage(
      yourId: yourId,
      userId: userId,
      date: date,
      url: url,
      from: from,
    );
  }

  Future<void> sendAudio({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  }) async {
    _dataManager.sendAudio(
      yourId: yourId,
      userId: userId,
      date: date,
      url: url,
      from: from,
    );
  }

  Future<void> deleteChat({
    required String yourId,
    required String userId,
  }) async {
    _dataManager.deleteChat(yourId: yourId, userId: userId);
  }
}

abstract class PersonalChatDataManager {
  FutureOr<void> deleteChat({
    required String yourId,
    required String userId,
  });

  FutureOr<void> updateChats({
    required String yourId,
    required String userId,
  });

  FutureOr<void> updateChatDate({
    required String yourId,
    required String userId,
    required String value,
  });

  FutureOr<void> updateReadChat({
    required String yourId,
    required String date,
    required String userId,
    required String chatId,
  });

  FutureOr<void> updateTotalRead({
    required String yourId,
    required String userId,
    required int value,
  });

  FutureOr<void> sendText({
    required String yourId,
    required String userId,
    required String date,
    required String message,
    required String from,
  });

  FutureOr<void> sendImage({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  });

  FutureOr<void> sendAudio({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  });
}

// Firebase
class PersonalChatFirebaseDb implements PersonalChatDataManager {
  // Singleton
  static final _instance = PersonalChatFirebaseDb._constructor();
  PersonalChatFirebaseDb._constructor();

  factory PersonalChatFirebaseDb() {
    return _instance;
  }

  // Process
  final PersonalChatText _text = PersonalChatText();
  final PersonalChatImage _image = PersonalChatImage();
  final PersonalChatAudio _audio = PersonalChatAudio();

  @override
  Future<void> updateReadChat({
    required String yourId,
    required String date,
    required String userId,
    required String chatId,
  }) async {
    await FirebaseUtils.dbChat(yourId)
        .doc(userId)
        .collection(date)
        .doc(chatId)
        .update({
      "read": true,
    });
  }

  @override
  Future<void> updateTotalRead({
    required String yourId,
    required String userId,
    required int value,
  }) async {
    await FirebaseUtils.dbChat(yourId).doc(userId).set(
      {"total_unread": value},
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> sendText({
    required String yourId,
    required String userId,
    required String from,
    required String date,
    required String message,
  }) async {
    await FirebaseUtils.dbChat(yourId).doc(userId).collection(date).add(
          _text.toMap(userId: from, message: message),
        );
  }

  @override
  Future<void> sendAudio({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  }) async {
    await FirebaseUtils.dbChat(yourId).doc(userId).collection(date).add(
          _audio.toMap(userId: from, url: url),
        );
  }

  @override
  Future<void> sendImage({
    required String yourId,
    required String userId,
    required String date,
    required String url,
    required String from,
  }) async {
    await FirebaseUtils.dbChat(yourId).doc(userId).collection(date).add(
          _image.toMap(userId: from, url: url),
        );
  }

  @override
  Future<void> updateChatDate({
    required String yourId,
    required String userId,
    required String value,
  }) async {
    FirebaseUtils.dbChat(yourId).doc(userId).set(
      {
        "date": value,
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> updateChats({
    required String yourId,
    required String userId,
  }) async {
    FirebaseUtils.dbChat(yourId).doc(userId).set(
      {
        "chats": FieldValue.arrayUnion(
            [VariableConst.timeYearMonthDay.call().toString()]),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> deleteChat({
    required String yourId,
    required String userId,
  }) async {
    await FirebaseUtils.dbChat(yourId).doc(userId).delete();
  }
}

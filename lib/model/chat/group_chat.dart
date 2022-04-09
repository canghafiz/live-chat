import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:live_chat/utils/export_utils.dart';

class GroupChatText {
  GroupChatText({
    this.from,
    this.message,
    this.read,
    this.time,
    this.type,
  });

  String? type, message, time, from;
  List? read;

  // Map
  Map<String, dynamic> toMap({required String from, required String message}) {
    return {
      "from": from,
      "message": message,
      "read": [from],
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeText,
    };
  }

  factory GroupChatText.fromMap(Map<String, dynamic> data) {
    return GroupChatText(
      from: data['from'],
      message: data['message'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class GroupChatImage {
  GroupChatImage({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  List? read;

  // Map
  Map<String, dynamic> toMap({required String from, required String url}) {
    return {
      "from": from,
      "url": url,
      "read": [from],
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeImage,
    };
  }

  factory GroupChatImage.fromMap(Map<String, dynamic> data) {
    return GroupChatImage(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

class GroupChatAudio {
  GroupChatAudio({
    this.from,
    this.url,
    this.read,
    this.time,
    this.type,
  });

  String? type, url, time, from;
  List? read;

  // Map
  Map<String, dynamic> toMap({required String from, required String url}) {
    return {
      "from": from,
      "url": url,
      "read": [from],
      "time": VariableConst.timeHourMin.call().toString(),
      "type": VariableConst.chatTypeAudio,
    };
  }

  factory GroupChatAudio.fromMap(Map<String, dynamic> data) {
    return GroupChatAudio(
      from: data['from'],
      url: data['url'],
      read: data['read'],
      time: data['time'],
      type: data['type'],
    );
  }
}

// Low Level
class GroupChatDbService {
  // Singleton
  static final _instance =
      GroupChatDbService._constructor(GroupChatFirebaseDb());
  GroupChatDbService._constructor(this._dataManager);

  factory GroupChatDbService() {
    return _instance;
  }

  // Process
  final GroupChatDataManager _dataManager;

  void sendChat({
    required String groupId,
    required Function(String) sendChat,
  }) {
    // Update Chat Db
    FirebaseUtils.dbChatGroup(groupId)
        .where("date",
            isEqualTo: VariableConst.timeYearMonthDay.call().toString())
        .get()
        .then(
      (query) {
        if (query.docs.isNotEmpty) {
          // Call Send Chat
          sendChat.call(query.docs[0].id);
          _dataManager.updateChatDate(groupId);
        } else {
          FirebaseUtils.dbChatGroup(groupId).add(
            {
              "date": VariableConst.timeYearMonthDay.call().toString(),
            },
          ).then(
            (_) {
              FirebaseUtils.dbChatGroup(groupId)
                  .where("date",
                      isEqualTo:
                          VariableConst.timeYearMonthDay.call().toString())
                  .get()
                  .then(
                (query) {
                  if (query.docs.isNotEmpty) {
                    // Call Send Chat
                    sendChat.call(query.docs[0].id);
                    _dataManager.updateChatDate(groupId);
                  }
                },
              );
            },
          );
        }
      },
    );
  }

  Future<void> updateChatRead({
    required String groupId,
    required String chatId,
    required String chatsId,
    required String userId,
  }) async {
    _dataManager.updateChatRead(
      groupId: groupId,
      chatId: chatId,
      chatsId: chatsId,
      userId: userId,
    );
  }

  Future<void> sendText({
    required String groupId,
    required String chatId,
    required String from,
    required String message,
  }) async {
    _dataManager.sendText(
      groupId: groupId,
      chatId: chatId,
      from: from,
      message: message,
    );
  }

  Future<void> sendImage({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  }) async {
    _dataManager.sendImage(
      groupId: groupId,
      chatId: chatId,
      from: from,
      url: url,
    );
  }

  Future<void> sendAudio({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  }) async {
    _dataManager.sendAudio(
      groupId: groupId,
      chatId: chatId,
      from: from,
      url: url,
    );
  }
}

abstract class GroupChatDataManager {
  FutureOr<void> updateChatDate(String groupId);
  FutureOr<void> updateChatRead({
    required String groupId,
    required String chatId,
    required String chatsId,
    required String userId,
  });
  FutureOr<void> sendText({
    required String groupId,
    required String chatId,
    required String from,
    required String message,
  });
  FutureOr<void> sendImage({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  });
  FutureOr<void> sendAudio({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  });
}

// Firebase
class GroupChatFirebaseDb implements GroupChatDataManager {
  // Singleton
  static final _instance = GroupChatFirebaseDb._constructor();
  GroupChatFirebaseDb._constructor();

  factory GroupChatFirebaseDb() {
    return _instance;
  }

  // Process
  final GroupChatText _text = GroupChatText();
  final GroupChatImage _image = GroupChatImage();
  final GroupChatAudio _audio = GroupChatAudio();

  @override
  Future<void> sendImage({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  }) async {
    await FirebaseUtils.dbChatGroup(groupId)
        .doc(chatId)
        .collection("DATA")
        .add(_image.toMap(from: from, url: url));
  }

  @override
  Future<void> sendAudio({
    required String groupId,
    required String chatId,
    required String from,
    required String url,
  }) async {
    await FirebaseUtils.dbChatGroup(groupId)
        .doc(chatId)
        .collection("DATA")
        .add(_audio.toMap(from: from, url: url));
  }

  @override
  Future<void> sendText({
    required String groupId,
    required String chatId,
    required String from,
    required String message,
  }) async {
    await FirebaseUtils.dbChatGroup(groupId)
        .doc(chatId)
        .collection("DATA")
        .add(_text.toMap(from: from, message: message));
  }

  @override
  Future<void> updateChatDate(String groupId) async {
    await FirebaseUtils.dbGroup(groupId).update({
      "chat_date":
          "${VariableConst.timeYearMonthDay.call().toString()} ${VariableConst.timeHourMin.call().toString()}"
    });
  }

  @override
  Future<void> updateChatRead({
    required String groupId,
    required String chatId,
    required String chatsId,
    required String userId,
  }) async {
    await FirebaseUtils.dbChatGroup(groupId)
        .doc(chatId)
        .collection("DATA")
        .doc(chatsId)
        .update({
      "read": FieldValue.arrayUnion([userId]),
    });
  }
}

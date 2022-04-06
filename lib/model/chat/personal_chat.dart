import 'dart:async';

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
class PersonalChatService {
  // Singleton
  static final _instance =
      PersonalChatService._constructor(PersonalChatFirebaseDb());
  PersonalChatService._constructor(this._dataManager);

  factory PersonalChatService() {
    return _instance;
  }

  // Process
  final PersonalChatDataManager _dataManager;

  Future<void> updateReadChat({
    required String yourId,
    required String date,
    required String userId,
    required String chatId,
  }) async {
    _dataManager.updateReadChat(
      yourId: yourId,
      date: date,
      userId: userId,
      chatId: chatId,
    );
  }
}

abstract class PersonalChatDataManager {
  FutureOr<void> updateReadChat({
    required String yourId,
    required String date,
    required String userId,
    required String chatId,
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseUtils {
  static final auth = FirebaseAuth.instance;
  static final storage = FirebaseStorage.instance;
  static final messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;
  static CollectionReference dbUsers() {
    return _db.collection('Users');
  }

  static CollectionReference dbGroups() {
    return _db.collection('Groups');
  }

  static DocumentReference dbGroup(String groupId) {
    return _db.collection('Groups').doc(groupId);
  }

  static DocumentReference dbUser(String userId) {
    return _db.collection('Users').doc(userId);
  }

  static CollectionReference dbChat(String userId) {
    return _db.collection('Users').doc(userId).collection('CHAT');
  }

  static CollectionReference dbChatGroup(String groupId) {
    return _db.collection('Groups').doc(groupId).collection('CHAT');
  }

  static CollectionReference dbCalls(String userId) {
    return _db.collection('Users').doc(userId).collection('CALLS');
  }
}

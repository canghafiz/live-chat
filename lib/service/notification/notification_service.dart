import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:live_chat/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class NotificationService {
  static final _authorization =
      dotenv.get('FIREBASE_API_KEY', fallback: 'FIREBASE_API_KEY not found');

  static void subscribeTopic(String value) {
    FirebaseUtils.messaging.subscribeToTopic(value);
  }

  static void unSubscribeTopic(String value) {
    FirebaseUtils.messaging.unsubscribeFromTopic(value);
  }

  static Future<void> setupMessageHandling({
    required BuildContext context,
    required String yourId,
  }) async {
    await _onMessage(context: context, yourId: yourId);
  }

  static Future<void> _onMessage({
    required BuildContext context,
    required String yourId,
  }) async {
    FirebaseMessaging.onMessage.listen(
      (message) {
        // Define Message
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification!.android;
        if (notification != null && android != null) {
          // When notif on click
          _notifSetting(
            context: context,
            notifPlugin: flutterLocalNotificationsPlugin,
            message: notification.body!,
            yourId: yourId,
          );
          // Define Data From Db
          FirebaseUtils.dbUser(notification.title!).get().then(
            (doc) {
              // Object
              final User user =
                  User.fromMap(doc.data() as Map<String, dynamic>);

              // Notif structure
              flutterLocalNotificationsPlugin.show(
                notification.hashCode,
                user.name,
                notification.body,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                    channel.id,
                    channel.name,
                    groupKey: channel.groupId,
                    playSound: true,
                    icon: "@mipmap/ic_launcher",
                    setAsGroupSummary: true,
                    priority: Priority.high,
                    importance: Importance.max,
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  static void _notifSetting({
    required FlutterLocalNotificationsPlugin notifPlugin,
    required String yourId,
    required String message,
    required BuildContext context,
  }) {
    var android = const AndroidInitializationSettings("@mipmap/ic_launcher");
    var ios = const IOSInitializationSettings();

    notifPlugin.initialize(
      InitializationSettings(android: android, iOS: ios),
      onSelectNotification: (_) async {
        // if (message.contains("follow") ||
        //     message.contains("like") ||
        //     message.contains("live")) {
        //   // Notif Page
        //   bottomBloc.add(const SetBottomNavigation(2));
        // } else {
        //   // Chat
        //   navigatorKey.currentState!.push(
        //     navigatorTo(
        //       context: context,
        //       screen: ChatListPage(yourId: yourId),
        //     ),
        //   );
        // }
      },
    );
  }

  static Future<bool> sendNotification({
    required String title,
    required String subject,
    required String topics,
  }) async {
    var postUrl = 'https://fcm.googleapis.com/fcm/send';

    String toParams = "/topics/$topics";

    final data = {
      "notification": {"body": subject, "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "status": "done",
        "sound": 'default',
        "screen": topics,
      },
      "to": toParams,
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization': _authorization
    };

    final response = await http.post(Uri.tryParse(postUrl)!,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do
      debugPrint("Success send notif to $topics");
      return true;
    } else {
      // on failure do
      debugPrint("Failed send notif to $topics");
      return false;
    }
  }
}

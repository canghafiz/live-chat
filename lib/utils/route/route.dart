import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';
import 'package:live_chat/view/export_view.dart';

class RouteHandle {
  static PageRoute goToPage(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: const Duration(seconds: 0),
    );
  }

  // Auth
  static toPasswordChange(BuildContext context) {
    Navigator.push(context, goToPage(const PasswordPage()));
  }

  // Main
  static toMainPage({
    required BuildContext context,
    required String userId,
  }) {
    // Navigate
    Navigator.pushAndRemoveUntil(
        context,
        goToPage(
          MainPage(
            userId: userId,
          ),
        ),
        (route) => false);
  }

  // Chat
  static toDetailPersonalChat({
    required BuildContext context,
    required String userId,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        DetailPersonalChatPage(
          userId: userId,
          yourId: yourId,
        ),
      ),
    );
  }

  static toDetailGroupChat({
    required BuildContext context,
    required String groupId,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        DetailGroupChatPage(
          groupId: groupId,
          yourId: yourId,
        ),
      ),
    );
  }

  static toDetailImage({
    required BuildContext context,
    required String? url,
    required File? file,
  }) {
    Navigator.push(
      context,
      goToPage(ImageDetailPage(url: url, file: file)),
    );
  }

  // Contact
  static toPersonalDetailPage({
    required BuildContext context,
    required String userId,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        PersonalDetailPage(userId: userId, yourId: yourId),
      ),
    );
  }

  static toGroupDetailPage({
    required BuildContext context,
    required String groupId,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        GroupDetailPage(groupId: groupId, yourId: yourId),
      ),
    );
  }

  static toCreateGroup({
    required BuildContext context,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        CreateGroupPage(yourId: yourId),
      ),
    );
  }

  static toAddMember({
    required BuildContext context,
    required String userId,
    required String groupId,
  }) {
    Navigator.push(
      context,
      goToPage(
        AddMemberPage(groupId: groupId, userId: userId),
      ),
    );
  }

  // Search
  static toPersonalChatSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(context: context, delegate: PersonalChatSearchPage(yourId));
  }

  static toGroupChatSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(context: context, delegate: GroupChatSearchPage(yourId));
  }

  static toGroupContactSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(context: context, delegate: GroupContactSearchPage(yourId));
  }

  static toPersonalContactSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(context: context, delegate: PersonalContactSearchPage(yourId));
  }

  static toNewPersonalContactSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(
      context: context,
      delegate: NewPersonalContactSearchPage(yourId),
    );
  }

  static toNewGroupContactSearch({
    required BuildContext context,
    required String yourId,
  }) {
    showSearch(
      context: context,
      delegate: NewGroupContactSearchPage(yourId),
    );
  }

  // Call
  static toDetailCall({
    required BuildContext context,
    required Call call,
    required String callId,
    required String yourId,
  }) {
    Navigator.push(
      context,
      goToPage(
        DetailCallPage(
          call: call,
          callId: callId,
          yourId: yourId,
        ),
      ),
    );
  }

  static toVoiceCall({
    required BuildContext context,
    required String userId,
    required String yourId,
    required CallType type,
  }) {
    Channel.checkChannelOtherCall(userId).then(
      (allow) {
        if (!allow) {
          // Update Db
          Channel.dbService.updateCallingProcess(
            userId: (type == CallType.caller) ? yourId : userId,
            value: (type == CallType.caller) ? "Calling" : "Accept",
          );
          // For You
          Channel.dbService.updateOnOtherCall(
            userId: yourId,
            value: true,
          );
          // For User
          Channel.dbService.updateOnOtherCall(
            userId: userId,
            value: true,
          );

          Navigator.push(
            context,
            goToPage(
              VoiceCallPage(
                callType: type,
                userId: userId,
                yourId: yourId,
              ),
            ),
          );
        } else {
          // Show Snackbar
          showCustomSnackbar(
            context: context,
            text: "User is on other calling!",
            color: Colors.red,
          );
        }
      },
    );
  }

  static toVideoCall({
    required BuildContext context,
    required String userId,
    required String yourId,
    required CallType type,
  }) {
    Channel.checkChannelOtherCall(userId).then(
      (allow) {
        if (!allow) {
          // Update Db
          Channel.dbService.updateCallingProcess(
            userId: (type == CallType.caller) ? yourId : userId,
            value: (type == CallType.caller) ? "Calling" : "Accept",
          );
          // For You
          Channel.dbService.updateOnOtherCall(
            userId: yourId,
            value: true,
          );
          // For User
          Channel.dbService.updateOnOtherCall(
            userId: userId,
            value: true,
          );

          Navigator.push(
            context,
            goToPage(
              VideoCallPage(
                callType: type,
                userId: userId,
                yourId: yourId,
              ),
            ),
          );
        } else {
          // Show Snackbar
          showCustomSnackbar(
            context: context,
            text: "User is on other calling!",
            color: Colors.red,
          );
        }
      },
    );
  }

  //  Web
  static toWeb(BuildContext context) {
    Navigator.push(context, goToPage(const WebPage()));
  }
}

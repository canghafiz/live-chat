import 'package:flutter/material.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/const/variable.dart';
import 'package:live_chat/view/export_view.dart';

class RouteHandle {
  static PageRoute _goToPage(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionDuration: const Duration(seconds: 0),
    );
  }

  // Auth
  static toPasswordChange(BuildContext context) {
    Navigator.push(context, _goToPage(const PasswordPage()));
  }

  // Main
  static toMainPage({
    required BuildContext context,
    required String userId,
  }) {
    // Navigate
    Navigator.pushAndRemoveUntil(
        context,
        _goToPage(
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
      _goToPage(
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
      _goToPage(
        DetailGroupChatPage(
          groupId: groupId,
          yourId: yourId,
        ),
      ),
    );
  }

  static toDetailImage({
    required BuildContext context,
    required String url,
  }) {
    Navigator.push(
      context,
      _goToPage(ImageDetailPage(url: url)),
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
      _goToPage(
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
      _goToPage(
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
      _goToPage(
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
      _goToPage(
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
      _goToPage(
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
    Navigator.push(
      context,
      _goToPage(
        VoiceCallPage(
          callType: type,
          userId: userId,
          yourId: yourId,
        ),
      ),
    );
  }

  //  Web
  static toWeb(BuildContext context) {
    Navigator.push(context, _goToPage(const WebPage()));
  }
}

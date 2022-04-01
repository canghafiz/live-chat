import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:live_chat/model/export_model.dart';
import 'package:live_chat/utils/export_utils.dart';

class SlugMessageChatWidget extends StatefulWidget {
  const SlugMessageChatWidget({
    Key? key,
    required this.yourId,
    required this.chatId,
    required this.userId,
    required this.groupId,
  }) : super(key: key);
  final String? userId, groupId;
  final String chatId, yourId;

  @override
  State<SlugMessageChatWidget> createState() => _SlugMessageChatWidgetState();
}

class _SlugMessageChatWidgetState extends State<SlugMessageChatWidget> {
  String _message = '';
  bool _isRead = false;

  void update({
    required String message,
    required bool isRead,
  }) {
    setState(() {
      _message = message;
      _isRead = isRead;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (widget.userId != null)
        ? StreamBuilder<QuerySnapshot>(
            stream: FirebaseUtils.dbChat(widget.yourId)
                .doc(widget.userId)
                .collection(widget.chatId)
                .orderBy(
                  'time',
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text(_message);
              } else {
                if (snapshot.data!.docs.isNotEmpty) {
                  // Object
                  final data =
                      snapshot.data!.docs[0].data() as Map<String, dynamic>;
                  final PersonalChatText? chatText =
                      (data['type'] == VariableConst.chatTypeText)
                          ? PersonalChatText.fromMap(data)
                          : null;
                  final PersonalChatAudio? chatAudio =
                      (data['type'] == VariableConst.chatTypeAudio)
                          ? PersonalChatAudio.fromMap(data)
                          : null;
                  final PersonalChatImage? chatImage =
                      (data['type'] == VariableConst.chatTypeImage)
                          ? PersonalChatImage.fromMap(data)
                          : null;

                  if (_message == '') {
                    // Update
                    SchedulerBinding.instance!.addPostFrameCallback((_) {
                      update(
                        message: (chatText != null)
                            ? chatText.message!
                            : (chatAudio != null)
                                ? 'AUDIO'
                                : 'IMAGE',
                        isRead: (chatText != null)
                            ? chatText.read!
                            : (chatAudio != null)
                                ? chatAudio.read!
                                : chatImage!.read!,
                      );
                    });
                  }

                  return Text(
                    _message,
                    style: (_isRead)
                        ? FontConfig.light(size: 10, color: Colors.grey)
                        : FontConfig.bold(size: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
                return const SizedBox();
              }
            },
          )
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseUtils.dbChatGroup(widget.groupId!)
                .where("date", isEqualTo: widget.chatId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text(_message);
              }
              // Id
              String id = snapshot.data!.docs[0].id;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseUtils.dbChatGroup(widget.groupId!)
                    .doc(id)
                    .collection('DATA')
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(_message);
                  } else {
                    if (snapshot.data!.docs.isNotEmpty) {
                      // Object
                      final data =
                          snapshot.data!.docs[0].data() as Map<String, dynamic>;
                      final GroupChatText? chatText =
                          (data['type'] == VariableConst.chatTypeText)
                              ? GroupChatText.fromMap(data)
                              : null;
                      final GroupChatAudio? chatAudio =
                          (data['type'] == VariableConst.chatTypeAudio)
                              ? GroupChatAudio.fromMap(data)
                              : null;
                      final GroupChatImage? chatImage =
                          (data['type'] == VariableConst.chatTypeImage)
                              ? GroupChatImage.fromMap(data)
                              : null;

                      if (_message == '') {
                        // Update
                        SchedulerBinding.instance!.addPostFrameCallback((_) {
                          update(
                            message: (chatText != null)
                                ? chatText.message!
                                : (chatAudio != null)
                                    ? 'AUDIO'
                                    : 'IMAGE',
                            isRead: (chatText != null)
                                ? chatText.read!.contains(widget.yourId)
                                : (chatAudio != null)
                                    ? chatAudio.read!.contains(widget.yourId)
                                    : chatImage!.read!.contains(widget.yourId),
                          );
                        });
                      }

                      return Text(
                        _message,
                        style: (_isRead)
                            ? FontConfig.light(size: 10, color: Colors.grey)
                            : FontConfig.bold(size: 10, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }
                    return const SizedBox();
                  }
                },
              );
            },
          );
  }
}

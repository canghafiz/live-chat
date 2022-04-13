part of 'chat_cubit.dart';

@immutable
abstract class ChatState {}

enum AudioChatStatus { record, done, sending }

class ChatInitial extends ChatState {}

class TextFieldChat extends ChatState {
  final bool audioChatOn;

  TextFieldChat(this.audioChatOn);
}

class AudioChat extends ChatState {
  final AudioChatStatus status;

  AudioChat(this.status);
}

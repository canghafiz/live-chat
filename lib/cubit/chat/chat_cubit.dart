import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chat_state.dart';

class ChatCubitHandle {
  static ChatCubit read(BuildContext context) {
    return context.read<ChatCubit>();
  }

  static ChatCubit watch(BuildContext context) {
    return context.watch<ChatCubit>();
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  void setTextfield(bool audioChatOn) {
    emit(TextFieldChat(audioChatOn));
  }

  void setAudio(AudioChatStatus value) {
    emit(AudioChat(value));
  }
}

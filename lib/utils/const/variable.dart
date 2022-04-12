import 'package:live_chat/model/export_model.dart';

enum BackEndStatus { undoing, doing, success, error }

enum CallType { receiver, caller }

enum CallProcess { undoing, calling, accept, reject, done }

class VariableConst {
  static const appName = 'Live Chat';
  static const margin = 16.0;
  static const keyTheme = 'theme';
  static const chatTypeText = 'Text';
  static const chatTypeAudio = 'Audio';
  static const chatTypeImage = 'Image';
  static const callTypeVoice = 'Voice';
  static const callTypeVideo = 'Video';
  static String timeYearMonthDay() {
    return "${DateTime.now().year}-${(DateTime.now().month.toString().length < 2) ? "0${DateTime.now().month}" : "${DateTime.now().month}"}-${(DateTime.now().day.toString().length < 2) ? "0${DateTime.now().day}" : "${DateTime.now().day}"}";
  }

  static String timeHourMin() {
    return "${(DateTime.now().hour.toString().length < 2) ? "0${DateTime.now().hour}" : "${DateTime.now().hour}"}:${(DateTime.now().minute.toString().length < 2) ? "0${DateTime.now().minute}" : "${DateTime.now().minute}"}";
  }

  static final PersonalChatDbService personalChatDbService =
      PersonalChatDbService();
  static final GroupChatDbService groupChatDbService = GroupChatDbService();
  static const String imageChatStorage = "Chat/Images/";
  static const String audioChatStorage = "Chat/Audio/";
  static const notificationSound = "call_notification";
}

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
  static final PersonalChatService personalDbService = PersonalChatService();
}

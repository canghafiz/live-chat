import 'package:live_chat/utils/export_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  // Set
  // For Theme
  static Future<void> setTheme(bool value) async {
    final SharedPreferences prefs = await _prefs;

    prefs.setBool(VariableConst.keyTheme, value);
  }
}

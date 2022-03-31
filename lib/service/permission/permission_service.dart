import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> microphone() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  static Future<bool> gallery() async {
    if (!await Permission.camera.isGranted) {
      PermissionStatus status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
}

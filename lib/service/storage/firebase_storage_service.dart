import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:live_chat/utils/export_utils.dart';

class FirebaseStorageService {
  static Future<String> uploadImage({
    required String folderName,
    required String fileName,
    required XFile pickedFile,
  }) async {
    File file = File(pickedFile.path);
    // Upload to Firebase Storage
    var storageRef = FirebaseUtils.storage.ref("$folderName/$fileName");
    var upload = await storageRef.putFile(file);
    var url = await upload.ref.getDownloadURL();

    return url;
  }

  static Future<String> uploadAudio({
    required String folderName,
    required String fileName,
    required File file,
  }) async {
    // Upload to Firebase Storage
    var storageRef = FirebaseUtils.storage.ref("$folderName/$fileName");
    var upload = await storageRef.putFile(file);
    var url = await upload.ref.getDownloadURL();

    return url;
  }

  static Future<void> delete(String url) async {
    FirebaseUtils.storage.refFromURL(url).delete();
  }
}

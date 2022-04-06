import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_chat/utils/export_utils.dart';

class ImageService {
  // Gallery
  static Future<XFile?> getImageFromGallery() async {
    var file = await ImagePicker().pickImage(source: ImageSource.gallery);

    return file;
  }

  // Camera
  static Future<XFile?> getImageFromCamera() async {
    var file = await ImagePicker().pickImage(source: ImageSource.camera);

    return file;
  }

  // Crop
  static final _crop = ImageCropper();

  static Future<File?> imageCrop(File file) async {
    File? croppedFile = await _crop.cropImage(
      sourcePath: file.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: const AndroidUiSettings(
        toolbarTitle: 'Edit Photo',
        toolbarColor: ColorConfig.colorPrimary,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
        activeControlsWidgetColor: Colors.white,
      ),
      iosUiSettings: const IOSUiSettings(
        title: 'Edit Photo',
      ),
    );

    if (croppedFile != null) {
      return croppedFile;
    }
    return null;
  }
}

import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> pickImageFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> pickVideoFromGallery() async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<File?> pickVideoFromCamera() async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }
}

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

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

  Future<File?> pickVideoFromCamera({Duration? maxDuration}) async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxDuration ?? const Duration(minutes: 5),
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  Future<int?> getVideoDuration(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (_) {
      return null;
    }
  }
}

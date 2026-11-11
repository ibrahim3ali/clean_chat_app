import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core.dart';

class MediaPickerBottomSheet extends StatelessWidget {
  final Function(File file, String type, {int? duration}) onMediaSelected;
  final MediaPickerService _picker = MediaPickerService();

  MediaPickerBottomSheet({super.key, required this.onMediaSelected});

  static Future<void> show(
    BuildContext context, {
    required Function(File file, String type, {int? duration}) onMediaSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MediaPickerBottomSheet(onMediaSelected: onMediaSelected),
    );
  }

  void _pick(
    BuildContext context,
    Future<File?> Function() picker,
    String type,
  ) async {
    Navigator.of(context).pop();
    final file = await picker();
    if (file != null) {
      int? duration;
      if (type == 'video') {
        duration = await _picker.getVideoDuration(file);
      }
      onMediaSelected(file, type, duration: duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: context.tr('takePhoto'),
                  color: Colors.pink,
                  onTap: () =>
                      _pick(context, _picker.pickImageFromCamera, 'image'),
                ),
                _buildOption(
                  context,
                  icon: Icons.videocam_rounded,
                  label: context.tr('recordVideo'),
                  color: Colors.deepOrange,
                  onTap: () =>
                      _pick(context, _picker.pickVideoFromCamera, 'video'),
                ),
                _buildOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: context.tr('photoGallery'),
                  color: Colors.purple,
                  onTap: () =>
                      _pick(context, _picker.pickImageFromGallery, 'image'),
                ),
                _buildOption(
                  context,
                  icon: Icons.video_library_rounded,
                  label: context.tr('videoGallery'),
                  color: Colors.teal,
                  onTap: () =>
                      _pick(context, _picker.pickVideoFromGallery, 'video'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

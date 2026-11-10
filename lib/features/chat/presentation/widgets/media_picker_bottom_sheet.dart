import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/media_picker_service.dart';

class MediaPickerBottomSheet extends StatelessWidget {
  final Function(File file, String type) onMediaSelected;
  final MediaPickerService _picker = MediaPickerService();

  MediaPickerBottomSheet({super.key, required this.onMediaSelected});

  static Future<void> show(
    BuildContext context, {
    required Function(File file, String type) onMediaSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
      onMediaSelected(file, type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'كاميرا',
                  color: Colors.pink,
                  onTap: () =>
                      _pick(context, _picker.pickImageFromCamera, 'image'),
                ),
                _buildOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'الصور',
                  color: Colors.purple,
                  onTap: () =>
                      _pick(context, _picker.pickImageFromGallery, 'image'),
                ),
                _buildOption(
                  context,
                  icon: Icons.videocam_rounded,
                  label: 'فيديو',
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
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

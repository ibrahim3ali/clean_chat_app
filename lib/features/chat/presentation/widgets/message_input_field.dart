import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core.dart';
import 'media_picker_bottom_sheet.dart';
import 'voice_recording_bar.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(File file, String type, {int? duration}) onSendMedia;
  final ValueChanged<bool>? onTypingChanged;

  const MessageInputField({
    super.key,
    required this.onSendMessage,
    required this.onSendMedia,
    this.onTypingChanged,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final _controller = TextEditingController();
  final _audioRecorder = AudioRecorderService();
  Timer? _timer;
  bool _isTyping = false;
  bool _isRecording = false;

  void _onChanged(String text) {
    setState(() {});
    if (widget.onTypingChanged == null) return;
    if (text.trim().isNotEmpty) {
      if (!_isTyping) {
        _isTyping = true;
        widget.onTypingChanged!(true);
      }
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 2), () {
        if (mounted && _isTyping) {
          _isTyping = false;
          widget.onTypingChanged!(false);
        }
      });
    } else if (_isTyping) {
      _isTyping = false;
      _timer?.cancel();
      widget.onTypingChanged!(false);
    }
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _timer?.cancel();
    if (_isTyping) {
      _isTyping = false;
      widget.onTypingChanged?.call(false);
    }
    widget.onSendMessage(text);
    _controller.clear();
    setState(() {});
  }

  void _openAttachmentPicker() {
    MediaPickerBottomSheet.show(
      context,
      onMediaSelected: (file, type, {duration}) {
        widget.onSendMedia(file, type, duration: duration);
      },
    );
  }

  void _openCameraPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final picker = MediaPickerService();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                const SizedBox(height: 16),
                Text(
                  context.tr('camera'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCameraAction(
                      ctx,
                      icon: Icons.camera_alt_rounded,
                      label: context.tr('takePhoto'),
                      color: Colors.pink,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final file = await picker.pickImageFromCamera();
                        if (file != null) {
                          widget.onSendMedia(file, 'image');
                        }
                      },
                    ),
                    _buildCameraAction(
                      ctx,
                      icon: Icons.videocam_rounded,
                      label: context.tr('recordVideo'),
                      color: Colors.deepOrange,
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final file = await picker.pickVideoFromCamera();
                        if (file != null) {
                          final dur = await picker.getVideoDuration(file);
                          widget.onSendMedia(file, 'video', duration: dur);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraAction(
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
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startVoiceRecording() async {
    final permitted = await _audioRecorder.hasPermission();
    if (!permitted) return;
    await _audioRecorder.startRecording();
    setState(() => _isRecording = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.darkSurface : Colors.white;
    final inputBg =
        isDark ? AppColors.darkSurfaceVariant : AppColors.background;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: containerBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: _isRecording
            ? VoiceRecordingBar(
                recorder: _audioRecorder,
                onRecordingComplete: (file, dur) {
                  setState(() => _isRecording = false);
                  widget.onSendMedia(file, 'audio', duration: dur);
                },
                onCancel: () => setState(() => _isRecording = false),
              )
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    onPressed: _openAttachmentPicker,
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _controller,
                        onChanged: _onChanged,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: context.tr('typeMessage'),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (_controller.text.trim().isNotEmpty)
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else ...[
                    IconButton(
                      icon: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppColors.primary,
                      ),
                      tooltip: context.tr('camera'),
                      onPressed: _openCameraPicker,
                    ),
                    IconButton.filled(
                      onPressed: _startVoiceRecording,
                      icon: const Icon(Icons.mic, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

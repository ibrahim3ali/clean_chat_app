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
      onMediaSelected: (file, type) {
        widget.onSendMedia(file, type);
      },
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
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
                  const SizedBox(width: 6),
                  if (_controller.text.trim().isNotEmpty)
                    IconButton.filled(
                      onPressed: _send,
                      icon: const Icon(Icons.send_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    IconButton.filled(
                      onPressed: _startVoiceRecording,
                      icon: const Icon(Icons.mic, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/audio_recorder_service.dart';

class VoiceRecordingBar extends StatefulWidget {
  final AudioRecorderService recorder;
  final Function(File audioFile, int duration) onRecordingComplete;
  final VoidCallback onCancel;

  const VoiceRecordingBar({
    super.key,
    required this.recorder,
    required this.onRecordingComplete,
    required this.onCancel,
  });

  @override
  State<VoiceRecordingBar> createState() => _VoiceRecordingBarState();
}

class _VoiceRecordingBarState extends State<VoiceRecordingBar> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _seconds++);
    });
  }

  void _finish() async {
    _timer?.cancel();
    final result = await widget.recorder.stopRecording();
    if (result != null && result.durationSeconds > 0) {
      widget.onRecordingComplete(result.file, result.durationSeconds);
    } else {
      widget.onCancel();
    }
  }

  void _cancel() async {
    _timer?.cancel();
    await widget.recorder.cancelRecording();
    widget.onCancel();
  }

  String get _timeString {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _cancel,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.mic, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Text(
            _timeString,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            onPressed: _finish,
          ),
        ],
      ),
    );
  }
}

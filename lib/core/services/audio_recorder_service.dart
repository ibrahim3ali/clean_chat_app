import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  DateTime? _recordingStartTime;

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  Future<void> startRecording() async {
    final permitted = await _recorder.hasPermission();
    if (!permitted) return;

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    _recordingStartTime = DateTime.now();
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<RecordedAudioResult?> stopRecording() async {
    final isRec = await _recorder.isRecording();
    if (!isRec) return null;

    final path = await _recorder.stop();
    final durationSeconds = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!).inSeconds
        : 0;

    if (path == null) return null;
    return RecordedAudioResult(
      file: File(path),
      durationSeconds: durationSeconds,
    );
  }

  Future<void> cancelRecording() async {
    final isRec = await _recorder.isRecording();
    if (isRec) {
      final path = await _recorder.stop();
      if (path != null) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
    }
    _recordingStartTime = null;
  }

  void dispose() {
    _recorder.dispose();
  }
}

class RecordedAudioResult {
  final File file;
  final int durationSeconds;

  const RecordedAudioResult({
    required this.file,
    required this.durationSeconds,
  });
}
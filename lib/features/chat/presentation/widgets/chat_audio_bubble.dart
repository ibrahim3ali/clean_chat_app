import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';

class ChatAudioBubble extends StatefulWidget {
  final MessageEntity message;
  final bool isMe;

  const ChatAudioBubble({super.key, required this.message, required this.isMe});

  @override
  State<ChatAudioBubble> createState() => _ChatAudioBubbleState();
}

class _ChatAudioBubbleState extends State<ChatAudioBubble> {
  late final AudioPlayer _player;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  static final _mediaContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
      audioMode: AndroidAudioMode.normal,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
    ),
  );

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  void _initPlayer() async {
    if (widget.message.mediaDuration != null &&
        widget.message.mediaDuration! > 0) {
      _duration = Duration(seconds: widget.message.mediaDuration!);
    }
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.onDurationChanged.listen((dur) {
      if (mounted && dur > Duration.zero) {
        setState(() => _duration = dur);
      }
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
        });
      }
    });

    try {
      await _player.setVolume(1.0);
      await _player.setAudioContext(_mediaContext);
    } catch (_) {}
  }

  void _togglePlay() async {
    final url = widget.message.mediaUrl;
    if (url == null || url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('مسار الملف الصوتي غير صالح')),
        );
      }
      return;
    }

    try {
      if (_playerState == PlayerState.playing) {
        await _player.pause();
        return;
      }

      final isLocal = !url.startsWith('http://') && !url.startsWith('https://');
      if (isLocal) {
        final file = File(url);
        if (!await file.exists()) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('الملف الصوتي غير موجود على الجهاز')),
            );
          }
          return;
        }

        final size = await file.length();
        if (size == 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ملف التسجيل الصوتي فارغ (0 بايت)')),
            );
          }
          return;
        }

        await _player.setAudioContext(_mediaContext);
        await _player.setVolume(1.0);
        await _player.play(DeviceFileSource(url));
      } else {
        await _player.setAudioContext(_mediaContext);
        await _player.setVolume(1.0);
        await _player.play(UrlSource(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تشغيل الصوت: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _playerState == PlayerState.playing;
    final iconColor = widget.isMe ? Colors.white : AppColors.primary;
    final textColor = widget.isMe ? Colors.white70 : AppColors.textMuted;

    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment:
          widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 36,
              icon: Icon(
                isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: iconColor,
              ),
              onPressed: _togglePlay,
            ),
            SizedBox(
              width: 140,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  trackHeight: 3,
                ),
                child: Slider(
                  value: progress,
                  activeColor: iconColor,
                  inactiveColor: iconColor.withValues(alpha: 0.3),
                  onChanged: (val) {
                    if (_duration > Duration.zero) {
                      final target = _duration * val;
                      _player.seek(target);
                    }
                  },
                ),
              ),
            ),
            Text(
              _formatDuration(isPlaying ? _position : _duration),
              style: TextStyle(color: textColor, fontSize: 12),
            ),
          ],
        ),
        Text(
          DateFormatter.formatTime(widget.message.timestamp),
          style: TextStyle(color: textColor, fontSize: 11),
        ),
      ],
    );
  }
}
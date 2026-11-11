import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';

class ChatVideoBubble extends StatefulWidget {
  final MessageEntity message;
  final bool isMe;

  const ChatVideoBubble({super.key, required this.message, required this.isMe});

  @override
  State<ChatVideoBubble> createState() => _ChatVideoBubbleState();
}

class _ChatVideoBubbleState extends State<ChatVideoBubble> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final url = widget.message.mediaUrl;
    if (url != null && url.isNotEmpty) {
      final isLocal = !url.startsWith('http://') && !url.startsWith('https://');
      _controller = isLocal
          ? VideoPlayerController.file(File(url))
          : VideoPlayerController.networkUrl(Uri.parse(url));

      _controller!.initialize().then((_) {
        if (mounted) setState(() => _isInitialized = true);
      });
      _controller!.addListener(() {
        if (mounted &&
            _controller!.value.position >= _controller!.value.duration &&
            !_controller!.value.isPlaying) {
          setState(() {});
        }
      });
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final captionColor = widget.isMe
        ? Colors.white
        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);
    final timeColor = widget.isMe
        ? Colors.white70
        : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted);

    return Column(
      crossAxisAlignment:
          widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: maxWidth,
            height: 220,
            color: Colors.black87,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isInitialized && _controller != null)
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                GestureDetector(
                  onTap: _togglePlay,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.black54,
                    child: Icon(
                      _controller?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (_isInitialized && _controller != null)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.videocam_rounded,
                            size: 13,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(_controller!.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.message.text.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            widget.message.text,
            style: TextStyle(color: captionColor, fontSize: 14),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatTime(widget.message.timestamp),
          style: TextStyle(color: timeColor, fontSize: 11),
        ),
      ],
    );
  }
}

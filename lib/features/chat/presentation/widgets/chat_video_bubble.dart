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
    }
  }

  void _togglePlay() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

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
                    backgroundColor: Colors.black45,
                    child: Icon(
                      _controller?.value.isPlaying == true
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 34,
                      color: Colors.white,
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
            style: TextStyle(
              color: widget.isMe ? Colors.white : AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          DateFormatter.formatTime(widget.message.timestamp),
          style: TextStyle(
            color: widget.isMe ? Colors.white70 : AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
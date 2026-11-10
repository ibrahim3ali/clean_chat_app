import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/message_entity.dart';

class ChatImageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const ChatImageBubble({super.key, required this.message, required this.isMe});

  bool _isLocalFile(String path) {
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  void _openFullScreen(BuildContext context) {
    final url = message.mediaUrl;
    if (url == null || url.isEmpty) return;

    final isLocal = _isLocalFile(url);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: isLocal
                  ? Image.file(File(url), fit: BoxFit.contain)
                  : Image.network(url, fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String url, double maxWidth) {
    if (_isLocalFile(url)) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorBox(maxWidth),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          height: 180,
          width: maxWidth,
          color: Colors.black12,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorBox(maxWidth),
    );
  }

  Widget _buildErrorBox(double maxWidth) {
    return Container(
      height: 140,
      width: maxWidth,
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.72;

    return GestureDetector(
      onTap: () => _openFullScreen(context),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: 280),
              child: _buildImageWidget(message.mediaUrl ?? '', maxWidth),
            ),
          ),
          if (message.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            DateFormatter.formatTime(message.timestamp),
            style: TextStyle(
              color: isMe ? Colors.white70 : AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
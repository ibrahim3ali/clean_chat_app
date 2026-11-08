import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input_field.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity currentUser;
  final UserEntity otherUser;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String get _chatId {
    final uid1 = widget.currentUser.uid;
    final uid2 = widget.otherUser.uid;
    return (uid1.compareTo(uid2) < 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  Stream<bool> get _typingStream {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return false;
      final typing = data['typing'] as Map<String, dynamic>?;
      return typing?[widget.otherUser.uid] == true;
    });
  }

  void _setTyping(bool isTyping) {
    FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'typing': {
        widget.currentUser.uid: isTyping,
      },
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().listenToMessages(
          currentUserId: widget.currentUser.uid,
          otherUserId: widget.otherUser.uid,
        );
  }

  @override
  void dispose() {
    _setTyping(false);
    super.dispose();
  }

  void _sendMessage(String text) {
    _setTyping(false);
    context.read<ChatCubit>().sendMessage(
          currentUserId: widget.currentUser.uid,
          currentUserName: widget.currentUser.name,
          receiverId: widget.otherUser.uid,
          text: text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              child: Text(
                widget.otherUser.name.isNotEmpty
                    ? widget.otherUser.name.characters.first.toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUser.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _typingStream,
                  builder: (context, snapshot) {
                    final isTyping = snapshot.data == true;
                    if (isTyping) {
                      return const Text(
                        'يكتب الآن...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return Text(
                      widget.otherUser.isOnline ? 'متصل الآن' : 'غير متصل',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.otherUser.isOnline
                            ? Colors.green
                            : AppColors.textMuted,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatLoaded) {
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_chat_unread_outlined,
                            size: 60,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'لا توجد رسائل سابقة. ابدأ المحادثة الآن!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true, // Newest messages at the bottom
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == widget.currentUser.uid;

                      return ChatBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          StreamBuilder<bool>(
            stream: _typingStream,
            builder: (context, snapshot) {
              final isTyping = snapshot.data == true;
              if (!isTyping) return const SizedBox.shrink();
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.otherUser.name} يكتب الآن...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          MessageInputField(
            onSendMessage: _sendMessage,
            onTypingChanged: _setTyping,
          ),
        ],
      ),
    );
  }
}

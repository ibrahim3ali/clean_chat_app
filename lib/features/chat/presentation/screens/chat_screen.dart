import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core.dart';
import '../../../../features.dart';

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

  Stream<bool> get _typingStream => FirebaseFirestore.instance
      .collection('chats')
      .doc(_chatId)
      .snapshots()
      .map(
        (doc) =>
            (doc.data()?['typing']
                as Map<String, dynamic>?)?[widget.otherUser.uid] ==
            true,
      );

  void _setTyping(bool isTyping) {
    FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'typing': {widget.currentUser.uid: isTyping},
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    InAppNotificationWatcher.activeChatPartnerId = widget.otherUser.uid;
    context.read<ChatCubit>().listenToMessages(
      currentUserId: widget.currentUser.uid,
      otherUserId: widget.otherUser.uid,
    );
  }

  @override
  void dispose() {
    InAppNotificationWatcher.activeChatPartnerId = null;
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

  void _sendMedia(File file, String type, {int? duration}) {
    context.read<ChatCubit>().sendMediaMessage(
      currentUserId: widget.currentUser.uid,
      currentUserName: widget.currentUser.name,
      receiverId: widget.otherUser.uid,
      file: file,
      type: type,
      duration: duration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          context.read<ChatCubit>().clearSessionMedia();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: ChatAppBarTitle(
            otherUser: widget.otherUser,
            typingStream: _typingStream,
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
                  }
                  final messages = state is ChatLoaded
                      ? state.messages
                      : (state is ChatError
                          ? state.messages
                          : const <MessageEntity>[]);

                  if (messages.isEmpty) {
                    if (state is ChatError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: AppColors.error,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const ChatEmptyMessagesState();
                  }
                  return ChatMessagesList(
                    messages: messages,
                    currentUserId: widget.currentUser.uid,
                  );
                },
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded && state.isUploading) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    color: AppColors.primaryLight,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'جاري الرفع...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            MessageInputField(
              onSendMessage: _sendMessage,
              onSendMedia: _sendMedia,
              onTypingChanged: _setTyping,
            ),
          ],
        ),
      ),
    );
  }
}
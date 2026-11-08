import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../widgets/chat_app_bar_title.dart';
import '../widgets/chat_empty_messages_state.dart';
import '../widgets/chat_messages_list.dart';
import '../widgets/message_input_field.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity currentUser;
  final UserEntity otherUser;

  const ChatScreen({super.key, required this.currentUser, required this.otherUser});

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
      .map((doc) => (doc.data()?['typing'] as Map<String, dynamic>?)?[widget.otherUser.uid] == true);

  void _setTyping(bool isTyping) {
    FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'typing': {widget.currentUser.uid: isTyping},
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
        title: ChatAppBarTitle(otherUser: widget.otherUser, typingStream: _typingStream),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) return const Center(child: CircularProgressIndicator());
                if (state is ChatLoaded) {
                  if (state.messages.isEmpty) return const ChatEmptyMessagesState();
                  return ChatMessagesList(messages: state.messages, currentUserId: widget.currentUser.uid);
                }
                return const SizedBox.shrink();
              },
            ),
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

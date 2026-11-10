import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/get_messages_stream_usecase.dart';
import '../../domain/usecases/send_media_message_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesStreamUseCase getMessagesStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SendMediaMessageUseCase sendMediaMessageUseCase;
  StreamSubscription? _messagesSubscription;

  final List<MessageEntity> _sessionMediaMessages = [];
  List<MessageEntity> _lastFirestoreMessages = [];

  ChatCubit({
    required this.getMessagesStreamUseCase,
    required this.sendMessageUseCase,
    required this.sendMediaMessageUseCase,
  }) : super(ChatInitial());

  void listenToMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    _sessionMediaMessages.clear();
    _lastFirestoreMessages.clear();
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription = getMessagesStreamUseCase(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    ).listen(
      (messages) {
        _lastFirestoreMessages = messages;
        _emitCombinedMessages();
      },
      onError: (e) {
        emit(ChatError(e.toString(), messages: _allCombinedMessages));
      },
    );
  }

  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    try {
      await sendMessageUseCase(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        receiverId: receiverId,
        text: text,
      );
    } catch (e) {
      emit(ChatError(e.toString(), messages: _allCombinedMessages));
    }
  }

  void sendMediaMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required File file,
    required String type,
    String text = '',
    int? duration,
  }) {
    final tempMessage = MessageEntity(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      text: text,
      type: type,
      mediaUrl: file.path,
      mediaDuration: duration,
      timestamp: DateTime.now(),
    );

    _sessionMediaMessages.add(tempMessage);
    _emitCombinedMessages();
  }

  void clearSessionMedia() {
    _sessionMediaMessages.clear();
    _emitCombinedMessages();
  }

  List<MessageEntity> get _allCombinedMessages {
    return [..._lastFirestoreMessages, ..._sessionMediaMessages]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _emitCombinedMessages() {
    emit(ChatLoaded(_allCombinedMessages));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _sessionMediaMessages.clear();
    _lastFirestoreMessages.clear();
    return super.close();
  }
}

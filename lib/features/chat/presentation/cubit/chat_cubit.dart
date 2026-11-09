import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/usecases.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesStreamUseCase getMessagesStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  StreamSubscription? _messagesSubscription;

  ChatCubit({
    required this.getMessagesStreamUseCase,
    required this.sendMessageUseCase,
  }) : super(ChatInitial());

  void listenToMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription =
        getMessagesStreamUseCase(
          currentUserId: currentUserId,
          otherUserId: otherUserId,
        ).listen(
          (messages) {
            emit(ChatLoaded(messages));
          },
          onError: (e) {
            emit(ChatError(e.toString()));
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
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

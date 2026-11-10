import 'package:equatable/equatable.dart';

import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<MessageEntity> messages;
  final bool isUploading;

  const ChatLoaded(this.messages, {this.isUploading = false});

  ChatLoaded copyWith({List<MessageEntity>? messages, bool? isUploading}) {
    return ChatLoaded(
      messages ?? this.messages,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [messages, isUploading];
}

class ChatError extends ChatState {
  final String message;
  final List<MessageEntity> messages;

  const ChatError(this.message, {this.messages = const []});

  @override
  List<Object?> get props => [message, messages];
}

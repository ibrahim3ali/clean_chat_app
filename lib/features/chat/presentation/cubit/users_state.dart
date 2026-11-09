import 'package:equatable/equatable.dart';

import '../../../../features.dart';



abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<ChatConversationEntity> conversations;
  const UsersLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);

  @override
  List<Object?> get props => [message];
}

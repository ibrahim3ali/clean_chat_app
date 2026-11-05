import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final GetConversationsUseCase getConversationsUseCase;
  StreamSubscription? _subscription;

  UsersCubit({required this.getConversationsUseCase}) : super(UsersInitial());

  void loadConversations({required String currentUserId}) {
    emit(UsersLoading());
    _subscription?.cancel();
    _subscription = getConversationsUseCase(currentUserId).listen(
      (conversations) {
        emit(UsersLoaded(conversations));
      },
      onError: (e) {
        emit(UsersError(e.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

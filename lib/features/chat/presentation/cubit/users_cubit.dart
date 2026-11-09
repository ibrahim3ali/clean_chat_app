import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/search_user_by_email_usecase.dart';
import 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final GetConversationsUseCase getConversationsUseCase;
  final SearchUserByEmailUseCase searchUserByEmailUseCase;
  StreamSubscription? _subscription;

  UsersCubit({
    required this.getConversationsUseCase,
    required this.searchUserByEmailUseCase,
  }) : super(UsersInitial());

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

  Future<UserEntity?> searchUserByEmail(String email) async {
    return await searchUserByEmailUseCase(email);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

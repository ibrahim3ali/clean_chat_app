import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_all_users_usecase.dart';
import '../../features/chat/domain/usecases/get_conversations_usecase.dart';
import '../../features/chat/domain/usecases/get_messages_stream_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/presentation/cubit/chat_cubit.dart';
import '../../features/chat/presentation/cubit/users_cubit.dart';

class ServiceLocator {
  ServiceLocator._();

  // Auth
  static late final AuthRemoteDataSource authRemoteDataSource;
  static late final AuthRepository authRepository;
  static late final LoginUseCase loginUseCase;
  static late final RegisterUseCase registerUseCase;
  static late final LogoutUseCase logoutUseCase;
  static late final GetCurrentUserUseCase getCurrentUserUseCase;

  // Chat
  static late final ChatRemoteDataSource chatRemoteDataSource;
  static late final ChatRepository chatRepository;
  static late final GetAllUsersUseCase getAllUsersUseCase;
  static late final GetConversationsUseCase getConversationsUseCase;
  static late final GetMessagesStreamUseCase getMessagesStreamUseCase;
  static late final SendMessageUseCase sendMessageUseCase;

  static void init() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 1. Auth Feature DI
    authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: auth,
      firestore: firestore,
    );
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

    // 2. Chat Feature DI
    chatRemoteDataSource = ChatRemoteDataSourceImpl(
      firestore: firestore,
    );
    chatRepository = ChatRepositoryImpl(
      remoteDataSource: chatRemoteDataSource,
    );
    getAllUsersUseCase = GetAllUsersUseCase(chatRepository);
    getConversationsUseCase = GetConversationsUseCase(chatRepository);
    getMessagesStreamUseCase = GetMessagesStreamUseCase(chatRepository);
    sendMessageUseCase = SendMessageUseCase(chatRepository);
  }

  static AuthCubit get authCubit => AuthCubit(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        logoutUseCase: logoutUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
      );

  static UsersCubit get usersCubit => UsersCubit(
        getConversationsUseCase: getConversationsUseCase,
      );

  static ChatCubit get chatCubit => ChatCubit(
        getMessagesStreamUseCase: getMessagesStreamUseCase,
        sendMessageUseCase: sendMessageUseCase,
      );
}

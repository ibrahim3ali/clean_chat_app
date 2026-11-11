import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core.dart';
import '../../features.dart';

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
  static late final ChatStorageDataSource chatStorageDataSource;
  static late final ChatRemoteDataSource chatRemoteDataSource;
  static late final ChatRepository chatRepository;
  static late final GetAllUsersUseCase getAllUsersUseCase;
  static late final GetConversationsUseCase getConversationsUseCase;
  static late final SearchUserByEmailUseCase searchUserByEmailUseCase;
  static late final GetMessagesStreamUseCase getMessagesStreamUseCase;
  static late final SendMessageUseCase sendMessageUseCase;
  static late final SendMediaMessageUseCase sendMediaMessageUseCase;

  // Notifications
  static late final NotificationService notificationService;
  static late final InAppNotificationWatcher inAppNotificationWatcher;

  static void init() {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // 0. Notifications DI
    notificationService = NotificationService(firestore: firestore);
    inAppNotificationWatcher = InAppNotificationWatcher(firestore: firestore);

    // 1. Auth Feature DI
    authRemoteDataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: auth,
      firestore: firestore,
    );
    authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
    loginUseCase = LoginUseCase(authRepository);
    registerUseCase = RegisterUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

    // 2. Chat Feature DI
    chatStorageDataSource = ChatStorageDataSourceImpl();
    chatRemoteDataSource = ChatRemoteDataSourceImpl(
      firestore: firestore,
      storageDataSource: chatStorageDataSource,
    );
    chatRepository = ChatRepositoryImpl(remoteDataSource: chatRemoteDataSource);
    getAllUsersUseCase = GetAllUsersUseCase(chatRepository);
    getConversationsUseCase = GetConversationsUseCase(chatRepository);
    searchUserByEmailUseCase = SearchUserByEmailUseCase(chatRepository);
    getMessagesStreamUseCase = GetMessagesStreamUseCase(chatRepository);
    sendMessageUseCase = SendMessageUseCase(chatRepository);
    sendMediaMessageUseCase = SendMediaMessageUseCase(chatRepository);
  }

  static AuthCubit get authCubit => AuthCubit(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );

  static UsersCubit get usersCubit => UsersCubit(
    getConversationsUseCase: getConversationsUseCase,
    searchUserByEmailUseCase: searchUserByEmailUseCase,
  );

  static ChatCubit get chatCubit => ChatCubit(
    getMessagesStreamUseCase: getMessagesStreamUseCase,
    sendMessageUseCase: sendMessageUseCase,
    sendMediaMessageUseCase: sendMediaMessageUseCase,
  );

  static LocaleCubit get localeCubit => LocaleCubit();
  static ThemeCubit get themeCubit => ThemeCubit();
}

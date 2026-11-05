import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';
import 'features/chat/presentation/cubit/users_cubit.dart';
import 'features/chat/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Clean Architecture Dependency Injection
  ServiceLocator.init();

  runApp(const CleanChatApp());
}

class CleanChatApp extends StatelessWidget {
  const CleanChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => ServiceLocator.authCubit..checkAuthStatus(),
        ),
        BlocProvider<UsersCubit>(
          create: (_) => ServiceLocator.usersCubit,
        ),
        BlocProvider<ChatCubit>(
          create: (_) => ServiceLocator.chatCubit,
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: FirebaseAuth.instance.currentUser != null
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }
}

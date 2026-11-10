import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../core.dart';
import '../../features.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser != null
        ? AppRoutes.home
        : AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) {
          final extra = state.extra as ChatRouteExtra;
          return ChatScreen(
            currentUser: extra.currentUser,
            otherUser: extra.otherUser,
          );
        },
      ),
    ],
  );
}

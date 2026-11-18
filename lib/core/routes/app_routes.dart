import '../../features.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String profile = '/profile';
}

class ProfileRouteExtra {
  final UserEntity user;
  final bool isCurrentUser;
  final UserEntity? currentUser;

  const ProfileRouteExtra({
    required this.user,
    required this.isCurrentUser,
    this.currentUser,
  });
}

class ChatRouteExtra {
  final UserEntity currentUser;
  final UserEntity otherUser;

  const ChatRouteExtra({required this.currentUser, required this.otherUser});
}

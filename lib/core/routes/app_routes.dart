import '../../features.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';
}

class ChatRouteExtra {
  final UserEntity currentUser;
  final UserEntity otherUser;

  const ChatRouteExtra({required this.currentUser, required this.otherUser});
}

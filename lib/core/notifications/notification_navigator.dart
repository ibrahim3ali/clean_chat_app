import 'package:firebase_auth/firebase_auth.dart';

import '../../core.dart';
import '../../features.dart';

class NotificationNavigator {
  NotificationNavigator._();

  static void handlePayload(String? payloadStr) {
    if (payloadStr == null || payloadStr.isEmpty) return;

    final payload = NotificationPayload.fromJson(payloadStr);
    if (payload.senderId.isEmpty) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final currentUser = UserEntity(
      uid: firebaseUser.uid,
      name:
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          '',
      email: firebaseUser.email ?? '',
      isOnline: true,
    );

    final otherUser = payload.toUserEntity();

    AppRouter.router.push(
      AppRoutes.chat,
      extra: ChatRouteExtra(currentUser: currentUser, otherUser: otherUser),
    );
  }
}

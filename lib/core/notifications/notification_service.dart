import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';
import 'notification_navigator.dart';
import 'notification_payload.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final FirebaseFirestore _firestore;
  String? cachedToken;

  NotificationService({
    FirebaseMessaging? fcm,
    FirebaseFirestore? firestore,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');

    await LocalNotificationService.initialize(
      onSelectNotification: (payload) => NotificationNavigator.handlePayload(payload),
    );

    _setupForegroundListener();
    _setupInteractionListeners();
    _setupTokenRefreshListener();

    await getToken();
  }

  void _setupForegroundListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM Foreground] Title: ${message.notification?.title}, Body: ${message.notification?.body}');
      final notification = message.notification;
      final data = message.data;
      final title = notification?.title ?? data['senderName'] ?? 'رسالة جديدة';
      final body = notification?.body ?? data['text'] ?? '';
      final payload = NotificationPayload.fromMap(data);

      LocalNotificationService.showNotification(
        id: message.hashCode,
        title: title,
        body: body,
        payload: payload.toJson(),
      );
    });
  }

  void _setupInteractionListeners() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = NotificationPayload.fromMap(message.data);
      NotificationNavigator.handlePayload(payload.toJson());
    });

    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        final payload = NotificationPayload.fromMap(message.data);
        NotificationNavigator.handlePayload(payload.toJson());
      }
    });
  }

  void _setupTokenRefreshListener() {
    // ignore: deprecated_member_use
    _fcm.onTokenRefresh.listen((token) {
      debugPrint('[FCM] onTokenRefresh: $token');
      cachedToken = token;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        saveTokenToFirestore(uid, token: token);
      }
    });
  }

  Future<String?> getToken() async {
    try {
      // ignore: deprecated_member_use
      final token = await _fcm.getToken();
      cachedToken = token;
      debugPrint('====================================');
      debugPrint('[FCM TOKEN]: $token');
      debugPrint('====================================');
      return token;
    } catch (e) {
      debugPrint('[FCM] Error getting token: $e');
      return null;
    }
  }

  Future<void> saveTokenToFirestore(String userId, {String? token}) async {
    try {
      final fcmToken = token ?? await getToken();
      if (fcmToken != null && fcmToken.isNotEmpty) {
        await _firestore.collection('users').doc(userId).set(
          {'fcmToken': fcmToken},
          SetOptions(merge: true),
        );
        debugPrint('[FCM] Successfully saved token in Firestore for user $userId');
      } else {
        debugPrint('[FCM] Token is null, could not save for user $userId');
      }
    } catch (e) {
      debugPrint('[FCM] Error saving token to Firestore: $e');
    }
  }
}

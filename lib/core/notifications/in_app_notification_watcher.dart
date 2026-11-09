import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'local_notification_service.dart';
import 'notification_payload.dart';

class InAppNotificationWatcher {
  static String? activeChatPartnerId;
  final FirebaseFirestore _firestore;
  StreamSubscription? _subscription;
  final Map<String, String> _lastSeenMessages = {};
  bool _isInitialLoad = true;

  InAppNotificationWatcher({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  void startWatching(String currentUserId) {
    stopWatching();
    _lastSeenMessages.clear();
    _isInitialLoad = true;

    _subscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialLoad) {
        for (final doc in snapshot.docs) {
          final lastMsg = doc.data()['lastMessage'] as String?;
          if (lastMsg != null) {
            _lastSeenMessages[doc.id] = lastMsg;
          }
        }
        _isInitialLoad = false;
        return;
      }

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lastMsg = data['lastMessage'] as String?;
        final lastSenderId = data['lastSenderId'] as String?;
        if (lastMsg == null || lastSenderId == null) continue;

        if (lastSenderId == currentUserId) continue;
        if (lastSenderId == activeChatPartnerId) continue;

        final previousMsg = _lastSeenMessages[doc.id];
        if (previousMsg != lastMsg) {
          _lastSeenMessages[doc.id] = lastMsg;
          _notifyNewMessage(
            chatId: doc.id,
            senderId: lastSenderId,
            lastMessage: lastMsg,
          );
        }
      }
    });
  }

  Future<void> _notifyNewMessage({
    required String chatId,
    required String senderId,
    required String lastMessage,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(senderId).get();
      final userData = userDoc.data();
      final senderName = userData?['name'] as String? ?? 'مستخدم';
      final senderEmail = userData?['email'] as String? ?? '';

      final payload = NotificationPayload(
        senderId: senderId,
        senderName: senderName,
        senderEmail: senderEmail,
      );

      await LocalNotificationService.showNotification(
        id: chatId.hashCode,
        title: senderName,
        body: lastMessage,
        payload: payload.toJson(),
      );
    } catch (_) {}
  }

  void stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    _lastSeenMessages.clear();
  }
}

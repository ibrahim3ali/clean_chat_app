import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors.dart';
import '../../../../core/notifications.dart';
import '../../../auth/data/models.dart';
import '../../data.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final ConversationsStreamHandler _conversationsHandler;
  final FcmV1SenderService _fcmSender;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    FcmV1SenderService? fcmSender,
  }) : _conversationsHandler = ConversationsStreamHandler(firestore: firestore),
       _fcmSender = fcmSender ?? FcmV1SenderService(firestore: firestore);

  String _getChatId(String uid1, String uid2) =>
      (uid1.compareTo(uid2) < 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';

  @override
  Stream<List<UserModel>> getUsersStream() {
    return firestore
        .collection('users')
        .snapshots()
        .map(
          (s) => s.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList(),
        );
  }

  @override
  Stream<List<ChatConversationModel>> getConversationsStream(
    String currentUserId,
  ) {
    return _conversationsHandler.getStream(currentUserId);
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final clean = email.trim().toLowerCase();
      var q = await firestore
          .collection('users')
          .where('email', isEqualTo: clean)
          .limit(1)
          .get();
      if (q.docs.isEmpty) {
        q = await firestore
            .collection('users')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();
      }
      if (q.docs.isEmpty) return null;
      return UserModel.fromMap(q.docs.first.data(), q.docs.first.id);
    } catch (e) {
      throw ServerException('فشل في البحث عن المستخدم: $e');
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = _getChatId(currentUserId, otherUserId);
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (s) => s.docs.map((doc) => MessageModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
  }) async {
    try {
      final chatId = _getChatId(currentUserId, receiverId);
      final chatDocRef = firestore.collection('chats').doc(chatId);
      await chatDocRef.collection('messages').add({
        'senderId': currentUserId,
        'senderName': currentUserName,
        'receiverId': receiverId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      await chatDocRef.set({
        'lastMessage': text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'participants': [currentUserId, receiverId],
      }, SetOptions(merge: true));

      _fcmSender.sendPushNotification(
        receiverId: receiverId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderEmail: '',
        messageText: text.trim(),
      );
    } catch (e) {
      throw ServerException('فشل في إرسال الرسالة: $e');
    }
  }
}

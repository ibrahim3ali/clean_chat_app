import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/notifications/fcm_v1_sender_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/chat_conversation_model.dart';
import '../models/message_model.dart';
import 'chat_remote_data_source.dart';
import 'chat_storage_data_source.dart';
import 'conversations_stream_handler.dart';

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final ConversationsStreamHandler _conversationsHandler;
  final FcmV1SenderService _fcmSender;
  final ChatStorageDataSource _storageDataSource;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    FcmV1SenderService? fcmSender,
    ChatStorageDataSource? storageDataSource,
  }) : _conversationsHandler = ConversationsStreamHandler(firestore: firestore),
       _fcmSender = fcmSender ?? FcmV1SenderService(firestore: firestore),
       _storageDataSource = storageDataSource ?? ChatStorageDataSourceImpl();

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
          (s) => s.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .where((msg) => !msg.deletedFor.contains(currentUserId))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
    String type = 'text',
    String? mediaUrl,
    int? mediaDuration,
  }) async {
    try {
      final chatId = _getChatId(currentUserId, receiverId);
      final chatDocRef = firestore.collection('chats').doc(chatId);
      await chatDocRef.collection('messages').add({
        'senderId': currentUserId,
        'senderName': currentUserName,
        'receiverId': receiverId,
        'text': text.trim(),
        'type': type,
        'mediaUrl': ?mediaUrl,
        'mediaDuration': ?mediaDuration,
        'timestamp': FieldValue.serverTimestamp(),
      });

      String preview = text.trim();
      if (type == 'image') preview = preview.isNotEmpty ? preview : '📷 صورة';
      if (type == 'video') preview = preview.isNotEmpty ? preview : '🎥 فيديو';
      if (type == 'audio') preview = '🎤 تسجيل صوتي';

      await chatDocRef.set({
        'lastMessage': preview,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'participants': [currentUserId, receiverId],
        'clearedBy': [],
      }, SetOptions(merge: true));

      _fcmSender.sendPushNotification(
        receiverId: receiverId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderEmail: '',
        messageText: preview,
      );
    } catch (e) {
      throw ServerException('فشل في إرسال الرسالة: $e');
    }
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) async {
    try {
      final docRef = firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      if (deleteForEveryone) {
        await docRef.delete();
      } else {
        await docRef.set({
          'deletedFor': FieldValue.arrayUnion([currentUserId]),
        }, SetOptions(merge: true));
      }

      await _updateChatPreviewAfterDeletion(chatId);
    } catch (e) {
      throw ServerException('فشل في حذف الرسالة: $e');
    }
  }

  @override
  Future<void> clearChat({
    required String chatId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) async {
    try {
      final messagesSnap = await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = firestore.batch();
      for (final doc in messagesSnap.docs) {
        if (deleteForEveryone) {
          batch.delete(doc.reference);
        } else {
          batch.set(
            doc.reference,
            {'deletedFor': FieldValue.arrayUnion([currentUserId])},
            SetOptions(merge: true),
          );
        }
      }

      final chatDoc = firestore.collection('chats').doc(chatId);
      if (deleteForEveryone) {
        batch.update(chatDoc, {'lastMessage': ''});
      } else {
        batch.set(
          chatDoc,
          {'clearedBy': FieldValue.arrayUnion([currentUserId])},
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('فشل في مسح المحادثة: $e');
    }
  }

  Future<void> _updateChatPreviewAfterDeletion(String chatId) async {
    try {
      final remaining = await firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final chatDoc = firestore.collection('chats').doc(chatId);
      if (remaining.docs.isEmpty) {
        await chatDoc.update({'lastMessage': ''});
      } else {
        final doc = remaining.docs.first;
        final data = doc.data();
        final type = data['type'] as String? ?? 'text';
        final text = data['text'] as String? ?? '';
        String preview = text.trim();
        if (type == 'image') preview = preview.isNotEmpty ? preview : '📷 صورة';
        if (type == 'video') preview = preview.isNotEmpty ? preview : '🎥 فيديو';
        if (type == 'audio') preview = '🎤 تسجيل صوتي';

        await chatDoc.update({
          'lastMessage': preview,
          'lastUpdated': data['timestamp'] ?? FieldValue.serverTimestamp(),
          'lastSenderId': data['senderId'] ?? '',
        });
      }
    } catch (_) {}
  }

  @override
  Future<String> uploadMediaFile({
    required File file,
    required String chatId,
    required String folder,
  }) {
    return _storageDataSource.uploadChatFile(
      file: file,
      chatId: chatId,
      folder: folder,
    );
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/chat_conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<UserModel>> getUsersStream();

  Stream<List<ChatConversationModel>> getConversationsStream(String currentUserId);

  Future<UserModel?> getUserByEmail(String email);

  Stream<List<MessageModel>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  });

  Future<void> sendMessage({
    required String currentUserId,
    required String currentUserName,
    required String receiverId,
    required String text,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  String _getChatId(String uid1, String uid2) {
    return (uid1.compareTo(uid2) < 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';
  }

  @override
  Stream<List<UserModel>> getUsersStream() {
    return firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<ChatConversationModel>> getConversationsStream(String currentUserId) {
    final controller = StreamController<List<ChatConversationModel>>();

    List<UserModel> allUsers = [];
    Map<String, Map<String, dynamic>> chatsMap = {};

    void emitMerged() {
      final List<ChatConversationModel> list = [];

      for (final user in allUsers) {
        if (user.uid == currentUserId) continue;

        final chatData = chatsMap[user.uid];
        // Only include users who have an actual active chat with messages
        if (chatData == null) continue;

        final lastMsg = (chatData['lastMessage'] as String? ?? '').trim();
        if (lastMsg.isEmpty) continue;

        DateTime? lastTime;
        final rawTime = chatData['lastUpdated'];
        if (rawTime is Timestamp) {
          lastTime = rawTime.toDate();
        } else if (rawTime is String) {
          lastTime = DateTime.tryParse(rawTime);
        }

        final lastSender = chatData['lastSenderId'] as String? ?? '';

        list.add(ChatConversationModel(
          otherUserId: user.uid,
          otherUserName: user.name,
          otherUserEmail: user.email,
          isOnline: user.isOnline,
          lastMessage: lastMsg,
          lastMessageTime: lastTime,
          lastSenderId: lastSender,
        ));
      }

      // Sort from Newest to Oldest (من الأحدث إلى الأقدم)
      list.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) {
          return a.otherUserName.compareTo(b.otherUserName);
        }
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      if (!controller.isClosed) {
        controller.add(list);
      }
    }

    StreamSubscription? usersSub;
    StreamSubscription? chatsSub;

    controller.onListen = () {
      usersSub = firestore.collection('users').snapshots().listen(
        (snapshot) {
          allUsers = snapshot.docs
              .map((d) => UserModel.fromMap(d.data(), d.id))
              .toList();
          emitMerged();
        },
        onError: (e) => controller.addError(e),
      );

      chatsSub = firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .snapshots()
          .listen(
        (snapshot) {
          chatsMap.clear();
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);
            final otherId = participants.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            if (otherId.isNotEmpty) {
              chatsMap[otherId] = data;
            }
          }
          emitMerged();
        },
        onError: (e) => controller.addError(e),
      );
    };

    controller.onCancel = () {
      usersSub?.cancel();
      chatsSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final cleanEmail = email.trim().toLowerCase();

      // 1. Search lowercase
      var query = await firestore
          .collection('users')
          .where('email', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      // 2. Fallback to trimmed search
      if (query.docs.isEmpty) {
        query = await firestore
            .collection('users')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();
      }

      if (query.docs.isEmpty) return null;

      final doc = query.docs.first;
      return UserModel.fromMap(doc.data(), doc.id);
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
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
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
      final messagesCollection = chatDocRef.collection('messages');

      final messageData = {
        'senderId': currentUserId,
        'senderName': currentUserName,
        'receiverId': receiverId,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await messagesCollection.add(messageData);

      // Update recent message info for chat room
      await chatDocRef.set({
        'lastMessage': text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId,
        'participants': [currentUserId, receiverId],
      }, SetOptions(merge: true));
    } catch (e) {
      throw ServerException('فشل في إرسال الرسالة: $e');
    }
  }
}

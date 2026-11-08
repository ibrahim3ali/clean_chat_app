import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/chat_conversation_model.dart';

class ConversationsStreamHandler {
  final FirebaseFirestore firestore;

  ConversationsStreamHandler({required this.firestore});

  Stream<List<ChatConversationModel>> getStream(String currentUserId) {
    final controller = StreamController<List<ChatConversationModel>>();
    List<UserModel> allUsers = [];
    Map<String, Map<String, dynamic>> chatsMap = {};

    void emitMerged() {
      final List<ChatConversationModel> list = [];

      for (final user in allUsers) {
        if (user.uid == currentUserId) continue;

        final chatData = chatsMap[user.uid];
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

        list.add(ChatConversationModel(
          otherUserId: user.uid,
          otherUserName: user.name,
          otherUserEmail: user.email,
          isOnline: user.isOnline,
          lastMessage: lastMsg,
          lastMessageTime: lastTime,
          lastSenderId: chatData['lastSenderId'] as String? ?? '',
        ));
      }

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
        (snap) {
          allUsers = snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
          emitMerged();
        },
        onError: (e) => controller.addError(e),
      );

      chatsSub = firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .snapshots()
          .listen(
        (snap) {
          chatsMap.clear();
          for (final doc in snap.docs) {
            final data = doc.data();
            final participants = List<String>.from(data['participants'] ?? []);
            final otherId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
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
}

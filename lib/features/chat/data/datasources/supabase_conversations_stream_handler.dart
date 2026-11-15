import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../features.dart';

class SupabaseConversationsStreamHandler {
  final SupabaseClient client;

  SupabaseConversationsStreamHandler({SupabaseClient? client})
      : client = client ?? Supabase.instance.client;

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

        final clearedBy = List<String>.from(
          chatData['cleared_by'] ?? chatData['clearedBy'] ?? [],
        );
        if (clearedBy.contains(currentUserId)) continue;

        final lastMsg = (chatData['last_message'] ??
                chatData['lastMessage'] as String? ??
                '')
            .toString()
            .trim();
        if (lastMsg.isEmpty) continue;

        DateTime? lastTime;
        final rawTime = chatData['last_updated'] ?? chatData['lastUpdated'];
        if (rawTime is String) {
          lastTime = DateTime.tryParse(rawTime);
        } else if (rawTime is DateTime) {
          lastTime = rawTime;
        }

        list.add(
          ChatConversationModel(
            otherUserId: user.uid,
            otherUserName: user.name,
            otherUserEmail: user.email,
            isOnline: user.isOnline,
            lastMessage: lastMsg,
            lastMessageTime: lastTime,
            lastSenderId: (chatData['last_sender_id'] ??
                    chatData['lastSenderId'] ??
                    '')
                .toString(),
          ),
        );
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
      usersSub = client
          .from('profiles')
          .stream(primaryKey: ['id'])
          .listen((data) {
        allUsers = data
            .map((d) => UserModel.fromMap(d, d['id'].toString()))
            .toList();
        emitMerged();
      }, onError: (e) => controller.addError(e));

      chatsSub = client
          .from('chats')
          .stream(primaryKey: ['id'])
          .listen((data) {
        chatsMap.clear();
        for (final row in data) {
          final participants = List<String>.from(row['participants'] ?? []);
          if (!participants.contains(currentUserId)) continue;

          final otherId = participants.firstWhere(
            (id) => id != currentUserId,
            orElse: () => '',
          );
          if (otherId.isNotEmpty) {
            chatsMap[otherId] = row;
          }
        }
        emitMerged();
      }, onError: (e) => controller.addError(e));
    };

    controller.onCancel = () {
      usersSub?.cancel();
      chatsSub?.cancel();
    };

    return controller.stream;
  }
}

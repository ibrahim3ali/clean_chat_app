import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/notifications/fcm_v1_sender_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/chat_conversation_model.dart';
import '../models/message_model.dart';
import 'chat_remote_data_source.dart';
import 'chat_storage_data_source.dart';
import 'supabase_chat_storage_data_source_impl.dart';
import 'supabase_conversations_stream_handler.dart';

class SupabaseChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient client;
  final SupabaseConversationsStreamHandler _conversationsHandler;
  final ChatStorageDataSource _storageDataSource;
  final FcmV1SenderService _fcmSender;

  SupabaseChatRemoteDataSourceImpl({
    SupabaseClient? client,
    ChatStorageDataSource? storageDataSource,
    FcmV1SenderService? fcmSender,
  })  : client = client ?? Supabase.instance.client,
        _conversationsHandler = SupabaseConversationsStreamHandler(
          client: client ?? Supabase.instance.client,
        ),
        _storageDataSource = storageDataSource ??
            SupabaseChatStorageDataSourceImpl(client: client),
        _fcmSender = fcmSender ??
            FcmV1SenderService(firestore: FirebaseFirestore.instance);

  String _getChatId(String uid1, String uid2) =>
      (uid1.compareTo(uid2) < 0) ? '${uid1}_$uid2' : '${uid2}_$uid1';

  @override
  Stream<List<UserModel>> getUsersStream() {
    return client.from('profiles').stream(primaryKey: ['id']).map(
      (rows) => rows
          .map((row) => UserModel.fromMap(row, row['id'].toString()))
          .toList(),
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
      final data = await client
          .from('profiles')
          .select()
          .ilike('email', clean)
          .maybeSingle();

      if (data == null) return null;
      return UserModel.fromMap(data, data['id'].toString());
    } catch (e) {
      throw ServerException('فشل في البحث عن المستخدم في Supabase: $e');
    }
  }

  @override
  Stream<List<MessageModel>> getMessagesStream({
    required String currentUserId,
    required String otherUserId,
  }) {
    final chatId = _getChatId(currentUserId, otherUserId);

    return client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map((row) => MessageModel.fromMap(row, row['id'].toString()))
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

      String preview = text.trim();
      if (type == 'image') preview = preview.isNotEmpty ? preview : '📷 صورة';
      if (type == 'video') preview = preview.isNotEmpty ? preview : '🎥 فيديو';
      if (type == 'audio') preview = '🎤 تسجيل صوتي';

      // 1. إنشاء أو تحديث سجل المحادثة أولاً لتحقيق شرط الـ Foreign Key
      await client.from('chats').upsert({
        'id': chatId,
        'last_message': preview,
        'last_updated': DateTime.now().toUtc().toIso8601String(),
        'last_sender_id': currentUserId,
        'participants': [currentUserId, receiverId],
        'cleared_by': [],
      });

      // 2. إدراج الرسالة بعد التأكد من وجود المحادثة
      await client.from('messages').insert({
        'chat_id': chatId,
        'sender_id': currentUserId,
        'sender_name': currentUserName,
        'receiver_id': receiverId,
        'text': text.trim(),
        'type': type,
        'media_url': mediaUrl,
        'media_duration': mediaDuration,
        'deleted_for': [],
      });

      // إرسال إشعار FCM للمستقبل
      _fcmSender.sendPushNotification(
        receiverId: receiverId,
        senderId: currentUserId,
        senderName: currentUserName,
        senderEmail: '',
        messageText: preview,
      );
    } catch (e) {
      throw ServerException('فشل في إرسال الرسالة إلى Supabase: $e');
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
      if (deleteForEveryone) {
        await client.from('messages').delete().eq('id', messageId);
      } else {
        final existing = await client
            .from('messages')
            .select('deleted_for')
            .eq('id', messageId)
            .maybeSingle();

        final currentList = List<String>.from(existing?['deleted_for'] ?? []);
        if (!currentList.contains(currentUserId)) {
          currentList.add(currentUserId);
          await client
              .from('messages')
              .update({'deleted_for': currentList})
              .eq('id', messageId);
        }
      }

      await _updateChatPreviewAfterDeletion(chatId);
    } catch (e) {
      throw ServerException('فشل في حذف الرسالة في Supabase: $e');
    }
  }

  @override
  Future<void> clearChat({
    required String chatId,
    required String currentUserId,
    required bool deleteForEveryone,
  }) async {
    try {
      if (deleteForEveryone) {
        await client.from('messages').delete().eq('chat_id', chatId);
        await client.from('chats').update({'last_message': ''}).eq('id', chatId);
      } else {
        final existingChat = await client
            .from('chats')
            .select('cleared_by')
            .eq('id', chatId)
            .maybeSingle();

        final clearedBy = List<String>.from(existingChat?['cleared_by'] ?? []);
        if (!clearedBy.contains(currentUserId)) {
          clearedBy.add(currentUserId);
          await client
              .from('chats')
              .update({'cleared_by': clearedBy})
              .eq('id', chatId);
        }
      }
    } catch (e) {
      throw ServerException('فشل في مسح المحادثة في Supabase: $e');
    }
  }

  Future<void> _updateChatPreviewAfterDeletion(String chatId) async {
    try {
      final remaining = await client
          .from('messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(1);

      if (remaining.isEmpty) {
        await client.from('chats').update({'last_message': ''}).eq('id', chatId);
      } else {
        final row = remaining.first;
        final type = row['type'] as String? ?? 'text';
        final text = row['text'] as String? ?? '';
        String preview = text.trim();
        if (type == 'image') preview = preview.isNotEmpty ? preview : '📷 صورة';
        if (type == 'video') preview = preview.isNotEmpty ? preview : '🎥 فيديو';
        if (type == 'audio') preview = '🎤 تسجيل صوتي';

        await client.from('chats').update({
          'last_message': preview,
          'last_updated': row['created_at'],
          'last_sender_id': row['sender_id'] ?? '',
        }).eq('id', chatId);
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

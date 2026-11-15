import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'chat_storage_data_source.dart';

class SupabaseChatStorageDataSourceImpl implements ChatStorageDataSource {
  final SupabaseClient client;
  final Uuid _uuid;

  SupabaseChatStorageDataSourceImpl({
    SupabaseClient? client,
    Uuid? uuid,
  })  : client = client ?? Supabase.instance.client,
        _uuid = uuid ?? const Uuid();

  @override
  Future<String> uploadChatFile({
    required File file,
    required String chatId,
    required String folder,
  }) async {
    if (!await file.exists()) {
      throw const ServerException('الملف المحدد غير موجود على الجهاز.');
    }

    final ext = file.path.split('.').last.toLowerCase();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4()}.$ext';
    final path = 'chats/$chatId/$folder/$fileName';

    try {
      final storage = client.storage.from(SupabaseConstants.mediaBucket);
      await storage.upload(
        path,
        file,
        fileOptions: FileOptions(
          contentType: _getMimeType(ext),
          upsert: true,
        ),
      );

      return storage.getPublicUrl(path);
    } catch (e) {
      throw ServerException('فشل في رفع الملف إلى Supabase Storage: $e');
    }
  }

  String _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4a':
        return 'audio/m4a';
      case 'mp3':
        return 'audio/mpeg';
      case 'aac':
        return 'audio/aac';
      default:
        return 'application/octet-stream';
    }
  }
}

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';

abstract class ChatStorageDataSource {
  Future<String> uploadChatFile({
    required File file,
    required String chatId,
    required String folder,
  });
}

class ChatStorageDataSourceImpl implements ChatStorageDataSource {
  final FirebaseStorage storage;
  final Uuid _uuid;

  ChatStorageDataSourceImpl({FirebaseStorage? storage, Uuid? uuid})
    : storage = storage ?? FirebaseStorage.instance,
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
    final metadata = SettableMetadata(contentType: _getMimeType(ext));

    try {
      return await _uploadToRef(storage.ref().child(path), file, metadata);
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        try {
          final altBucket = _getAlternativeBucket(storage.bucket);
          if (altBucket != null && altBucket != storage.bucket) {
            final altStorage = FirebaseStorage.instanceFor(bucket: altBucket);
            return await _uploadToRef(
              altStorage.ref().child(path),
              file,
              metadata,
            );
          }
        } on FirebaseException catch (altError) {
          _handleFirebaseError(altError);
        }
      }
      _handleFirebaseError(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('فشل في رفع الملف: $e');
    }
  }

  Future<String> _uploadToRef(
    Reference ref,
    File file,
    SettableMetadata metadata,
  ) async {
    final uploadTask = ref.putFile(file, metadata);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String? _getAlternativeBucket(String currentBucket) {
    if (currentBucket.contains('firebasestorage.app')) {
      return currentBucket.replaceAll('firebasestorage.app', 'appspot.com');
    } else if (currentBucket.contains('appspot.com')) {
      return currentBucket.replaceAll('appspot.com', 'firebasestorage.app');
    }
    return null;
  }

  Never _handleFirebaseError(FirebaseException e) {
    if (e.code == 'object-not-found') {
      throw const ServerException(
        'خدمة Firebase Storage لم يتم تفعيلها بعد في لوحة التحكم (Firebase Console). '
        'يرجى فتح قسم Storage والضغط على "Get Started" وتفعيل القواعد.',
      );
    } else if (e.code == 'permission-denied' || e.code == 'unauthorized') {
      throw const ServerException(
        'تم رفض الوصول إلى Firebase Storage. يرجى ضبط القواعد (Rules) في الكونسول.',
      );
    } else {
      throw ServerException('خطأ Firebase Storage (${e.code}): ${e.message}');
    }
  }

  String _getMimeType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'm4a':
        return 'audio/m4a';
      case 'aac':
        return 'audio/aac';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }
}

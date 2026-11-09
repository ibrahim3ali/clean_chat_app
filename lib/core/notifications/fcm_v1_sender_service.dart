import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class FcmV1SenderService {
  final FirebaseFirestore _firestore;
  String? _cachedAccessToken;
  DateTime? _tokenExpiry;

  static const String _projectId = 'flutter-chat-app-3954a';
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  FcmV1SenderService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String?> _getAccessToken() async {
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(minutes: 5)))) {
      return _cachedAccessToken;
    }

    try {
      Map<String, dynamic>? accountJson;

      // 1. Try reading from Firestore config/fcm first (remote dynamic config)
      try {
        final configDoc = await _firestore.collection('config').doc('fcm').get();
        if (configDoc.exists && configDoc.data() != null) {
          accountJson = configDoc.data()!;
        }
      } catch (_) {}

      // 2. Fallback to local asset
      if (accountJson == null || accountJson['private_key'] == null || (accountJson['private_key'] as String).isEmpty) {
        final assetString = await rootBundle.loadString('assets/service_account.json');
        final parsed = jsonDecode(assetString) as Map<String, dynamic>;
        if (parsed['private_key'] != null && (parsed['private_key'] as String).isNotEmpty) {
          accountJson = parsed;
        }
      }

      if (accountJson == null || accountJson['private_key'] == null || (accountJson['private_key'] as String).isEmpty) {
        debugPrint('[FCM Sender] Service account private_key not configured.');
        return null;
      }

      final credentials = ServiceAccountCredentials.fromJson(accountJson);
      final client = await clientViaServiceAccount(credentials, _scopes);
      _cachedAccessToken = client.credentials.accessToken.data;
      _tokenExpiry = client.credentials.accessToken.expiry;
      client.close();
      return _cachedAccessToken;
    } catch (e) {
      debugPrint('[FCM Sender] Error acquiring access token: $e');
      return null;
    }
  }

  Future<void> sendPushNotification({
    required String receiverId,
    required String senderId,
    required String senderName,
    required String senderEmail,
    required String messageText,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(receiverId).get();
      final targetToken = userDoc.data()?['fcmToken'] as String?;
      if (targetToken == null || targetToken.isEmpty) {
        debugPrint('[FCM Sender] Receiver $receiverId has no FCM token saved.');
        return;
      }

      final accessToken = await _getAccessToken();
      if (accessToken == null) return;

      final url = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
      final body = {
        'message': {
          'token': targetToken,
          'notification': {'title': senderName, 'body': messageText},
          'data': {
            'senderId': senderId,
            'senderName': senderName,
            'senderEmail': senderEmail,
            'text': messageText,
          },
          'android': {
            'priority': 'HIGH',
            'notification': {
              'channel_id': 'high_importance_channel',
              'sound': 'default',
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(body),
      );
      debugPrint('[FCM Sender] Sent push to $receiverId: ${response.statusCode}');
    } catch (e) {
      debugPrint('[FCM Sender] Failed to send push notification: $e');
    }
  }
}

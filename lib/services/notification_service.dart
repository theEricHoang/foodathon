import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../config/service_account.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirestoreService _firestoreService;

  static const _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/foodathon/messages:send';
  static const _messagingScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  AccessCredentials? _cachedCredentials;

  NotificationService({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<String> _getAccessToken() async {
    if (_cachedCredentials != null &&
        _cachedCredentials!.accessToken.expiry.isAfter(DateTime.now())) {
      return _cachedCredentials!.accessToken.data;
    }

    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
    final client = http.Client();
    try {
      _cachedCredentials = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        [_messagingScope],
        client,
      );
      return _cachedCredentials!.accessToken.data;
    } finally {
      client.close();
    }
  }

  Future<void> sendNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {'title': title, 'body': body},
            if (data != null) 'data': data,
          },
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('FCM send failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to send notification: $e');
    }
  }

  Future<void> notifyCustomer({
    required String customerId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final userData =
        await _firestoreService.getDocument('users', customerId);
    final token = userData?['fcmToken'] as String?;
    if (token == null) return;

    await sendNotification(fcmToken: token, title: title, body: body, data: data);
  }

  Future<void> notifyRestaurantOwner({
    required String restaurantId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    final restaurantData =
        await _firestoreService.getDocument('restaurants', restaurantId);
    final ownerId = restaurantData?['ownerId'] as String?;
    if (ownerId == null) return;

    final userData = await _firestoreService.getDocument('users', ownerId);
    final token = userData?['fcmToken'] as String?;
    if (token == null) return;

    await sendNotification(fcmToken: token, title: title, body: body, data: data);
  }
}

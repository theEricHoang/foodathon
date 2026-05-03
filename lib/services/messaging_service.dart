import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _androidChannel = AndroidNotificationChannel(
  'order_updates',
  'Order Updates',
  description: 'Notifications for order status changes',
  importance: Importance.high,
);

class MessagingService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<String>? _tokenRefreshSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_androidChannel);

    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    final token = await messaging.getToken();
    debugPrint('FCM token: $token');
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: message.data['orderId'],
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    final orderId = response.payload;
    if (orderId != null && _navigatorKey?.currentState != null) {
      _navigateToOrder(orderId);
    }
  }

  void _handleMessageNavigation(RemoteMessage message) {
    final orderId = message.data['orderId'] as String?;
    if (orderId != null && _navigatorKey?.currentState != null) {
      _navigateToOrder(orderId);
    }
  }

  void _navigateToOrder(String orderId) {
    debugPrint('Navigate to order: $orderId');
    // Navigation will be handled by the app's routing once screens are set up.
    // The navigator key is available at _navigatorKey for future deep linking.
  }

  Future<String?> getToken() {
    return messaging.getToken();
  }

  void onTokenRefresh(void Function(String token) callback) {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = messaging.onTokenRefresh.listen(callback);
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
  }
}

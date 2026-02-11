import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:logger/logger.dart';

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Logger().i('Background message received: ${message.messageId}');
}

@singleton
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  
  final StreamController<RemoteMessage> _notificationTapStreamController =
      StreamController<RemoteMessage>.broadcast();

  String? _fcmToken;

  PushNotificationService(this._apiService);

  Stream<RemoteMessage> get onMessage => _messageStreamController.stream;
  Stream<RemoteMessage> get onNotificationTap => _notificationTapStreamController.stream;
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    try {
      _logger.i('Initializing push notification service');

      // Request permissions
      final settings = await requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        _logger.w('Push notification permission not granted');
        return;
      }

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      _logger.i('FCM Token: $_fcmToken');

      // Listen to token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token refreshed: $newToken');
        _fcmToken = newToken;
        _sendTokenToServer(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Foreground message received: ${message.messageId}');
        _logger.d('Title: ${message.notification?.title}');
        _logger.d('Body: ${message.notification?.body}');
        _logger.d('Data: ${message.data}');
        _messageStreamController.add(message);
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Notification tapped (background): ${message.messageId}');
        _notificationTapStreamController.add(message);
      });

      // Check if app was opened from a terminated state by tapping notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _logger.i('App opened from notification: ${initialMessage.messageId}');
        _notificationTapStreamController.add(initialMessage);
      }

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _logger.i('Push notification service initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize push notifications', error: e, stackTrace: stackTrace);
    }
  }

  Future<NotificationSettings> requestPermission() async {
    try {
      _logger.i('Requesting notification permissions');
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      _logger.i('Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e, stackTrace) {
      _logger.e('Failed to request permissions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      _logger.i('Subscribing to topic: $topic');
      await _messaging.subscribeToTopic(topic);
      _logger.i('Successfully subscribed to topic: $topic');
    } catch (e, stackTrace) {
      _logger.e('Failed to subscribe to topic: $topic', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      _logger.i('Unsubscribing from topic: $topic');
      await _messaging.unsubscribeFromTopic(topic);
      _logger.i('Successfully unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      _logger.e('Failed to unsubscribe from topic: $topic', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteToken() async {
    try {
      _logger.i('Deleting FCM token');
      await _messaging.deleteToken();
      _fcmToken = null;
      _logger.i('FCM token deleted successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to delete FCM token', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      _logger.i('Sending FCM token to server (platform: $platform)');
      
      await _apiService.post(
        ApiConstants.updateFcmToken,
        data: {
          'fcm_token': token,
          'platform': platform,
        },
      );
      
      _logger.i('FCM token sent to server successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to send FCM token to server', error: e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _messageStreamController.close();
    _notificationTapStreamController.close();
  }
}

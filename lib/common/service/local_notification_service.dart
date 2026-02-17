import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

@singleton
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  
  int? _currentChatId;
  final StreamController<NotificationResponse> _notificationTapStreamController =
  StreamController<NotificationResponse>.broadcast();
  Stream<NotificationResponse> get onNotificationTap => _notificationTapStreamController.stream;


  Future<void> initialize() async {
    try {
      _logger.i('Initializing local notification service');

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final initialized = await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (details) {
          _notificationTapStreamController.add(details);
          _logger.d('Notification tapped: ${details.payload}');
        },
      );
      
      _logger.i('Notification plugin initialized: $initialized');
      
      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        'messages_channel',
        'Messages',
        description: 'Notifications for new messages',
        importance: Importance.high,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
      
      _logger.i('Local notification service initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize local notifications', error: e, stackTrace: stackTrace);
    }
  }

  void setCurrentChatId(int? chatId) {
    _currentChatId = chatId;
    _logger.d('Current chat ID set to: $chatId');
    if (chatId != null) {
      cancelNotification(chatId);
    }
  }

  int? get currentChatId => _currentChatId;

  Future<void> showMessageNotification({
    required int chatId,
    required String title,
    required String body,
  }) async {
    // Don't show notification if we're currently viewing this chat
    if (_currentChatId == chatId) {
      _logger.d('Skipping notification - chat $chatId is currently open');
      return;
    }

    try {
      _logger.i('Showing local notification for chat $chatId $_currentChatId');

      final androidDetails = AndroidNotificationDetails(
        'messages_channel',
        'Messages',
        channelDescription: 'Notifications for new messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        tag: chatId.toString(),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        id: chatId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: chatId.toString(),
      );

      _logger.i('Local notification shown successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to show local notification', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> cancelNotification(int chatId) async {
    try {
      if (Platform.isAndroid) {
        final list = await _notifications.getActiveNotifications();
        final an = list.where((item) => item.tag == chatId.toString()).firstOrNull;
        if (an != null) {
          await _notifications.cancel(id: an.id ?? 0, tag: an.tag);
        } else {
          await _notifications.cancel(id: chatId);
        }
      }


      _logger.d('Notification cancelled for chat $chatId');
    } catch (e, stackTrace) {
      _logger.e('Failed to cancel notification', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.d('All notifications cancelled');
    } catch (e, stackTrace) {
      _logger.e('Failed to cancel notifications', error: e, stackTrace: stackTrace);
    }
  }
}

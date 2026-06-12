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
  int _notificationIdCounter = 100;
  final Map<int, List<int>> _chatNotificationIds = {};

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
      cancelNotificationsForChat(chatId);
    }
  }

  int? get currentChatId => _currentChatId;

  Future<void> showMessageNotification({
    required int chatId,
    required String title,
    required String body,
  }) async {
    if (_currentChatId == chatId) {
      _logger.d('Skipping notification - chat $chatId is currently open');
      return;
    }

    try {
      _logger.i('Showing local notification for chat $chatId');

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'chat',
      );

      if (Platform.isAndroid) {
        await _showAndroidGroupedNotification(
          chatId: chatId,
          title: title,
          body: body,
        );
      } else {
        await _notifications.show(
          id: chatId,
          title: title,
          body: body,
          notificationDetails: const NotificationDetails(iOS: iosDetails),
          payload: chatId.toString(),
        );
      }

      _logger.i('Local notification shown successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to show local notification', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _showAndroidGroupedNotification({
    required int chatId,
    required String title,
    required String body,
  }) async {
    final groupKey = 'chat_group_$chatId';
    final notifId = _notificationIdCounter++;

    _chatNotificationIds.putIfAbsent(chatId, () => []).add(notifId);

    final individualDetails = AndroidNotificationDetails(
      'messages_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      groupKey: groupKey,
      tag: chatId.toString(),
    );

    await _notifications.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: individualDetails),
      payload: chatId.toString(),
    );

    final count = _chatNotificationIds[chatId]!.length;
    final summaryDetails = AndroidNotificationDetails(
      'messages_channel',
      'Messages',
      channelDescription: 'Notifications for new messages',
      importance: Importance.high,
      priority: Priority.high,
      groupKey: groupKey,
      setAsGroupSummary: true,
      tag: 'summary_$chatId',
    );

    await _notifications.show(
      id: chatId,
      title: title,
      body: count > 1 ? '$count new messages' : body,
      notificationDetails: NotificationDetails(android: summaryDetails),
      payload: chatId.toString(),
    );
  }

  Future<void> cancelNotificationsForChat(int chatId) async {
    try {
      if (Platform.isAndroid) {
        final ids = _chatNotificationIds.remove(chatId) ?? [];
        for (final id in ids) {
          await _notifications.cancel(id: id, tag: chatId.toString());
        }
        await _notifications.cancel(id: chatId, tag: 'summary_$chatId');
      } else {
        await _notifications.cancel(id: chatId);
      }
      _logger.d('Notifications cancelled for chat $chatId');
    } catch (e, stackTrace) {
      _logger.e('Failed to cancel notifications', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> cancelNotification(int chatId) => cancelNotificationsForChat(chatId);

  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _logger.d('All notifications cancelled');
    } catch (e, stackTrace) {
      _logger.e('Failed to cancel notifications', error: e, stackTrace: stackTrace);
    }
  }
}

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:lets_talk/app/router/app_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/service/push_notification_service.dart';
import 'package:lets_talk/di/injection.dart';

mixin HandlePushNotification {
  late final AppRouter router;
  StreamSubscription? notificationSubscription;

  void setupPushNotifications() {
    final pushService = getIt<PushNotificationService>();

    // Check for initial message (app opened from terminated state)
    final initialMessage = pushService.initialMessage;
    if (initialMessage != null) {
      // Delay slightly to ensure router is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initialMessage);
        pushService.clearInitialMessage();
      });
    }

    // Listen for notification taps (app in background)
    notificationSubscription = pushService.onNotificationTap.listen(_handleNotificationTap);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final chatIdStr = data['chat_id'] ?? data['id'];

    if (chatIdStr != null) {
      final chatId = int.tryParse(chatIdStr.toString());
      if (chatId != null) {
        router.config.push(
          '${Routes.chats.path}/${Routes.chatDetails.path}',
          extra: ChatDetailsArgs(chatId: chatId),
        );
      }
    }
  }

}
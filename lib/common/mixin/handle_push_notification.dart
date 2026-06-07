import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lets_talk/app/router/app_router.dart';
import 'package:lets_talk/app/router/arg/chat_details_args.dart';
import 'package:lets_talk/app/router/routes.dart';
import 'package:lets_talk/common/service/local_notification_service.dart';
import 'package:lets_talk/common/service/push_notification_service.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/chats/domain/chat_details_bloc/chat_details_bloc.dart';
import 'package:lets_talk/feature/settings/domain/profile_bloc/profile_bloc.dart';

mixin HandlePushNotification {
  late final AppRouter router;
  StreamSubscription? notificationSubscription;
  StreamSubscription? localNotificationSubscription;

  void setupPushNotifications() {
    final pushService = getIt<PushNotificationService>();
    final localPushService = getIt<LocalNotificationService>();

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
    notificationSubscription = pushService.onNotificationTap.listen(
      _handleNotificationTap,
    );

    // Listen for local notification taps
    localNotificationSubscription = localPushService.onNotificationTap.listen(
      _handleLocalNotificationTap,
    );
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    final chatIdStr = response.payload;

    _navigateToChat(chatIdStr);
  }

  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final chatIdStr = data['chat_id'] ?? data['id'];

    _navigateToChat(chatIdStr);
  }

  void _navigateToChat(String? chatIdStr) {
    if (chatIdStr != null) {
      final chatId = int.tryParse(chatIdStr.toString());
      if (chatId != null) {
        router.config.replace(
          '${Routes.chats.path}/${Routes.chatDetails.path}',
          extra: ChatDetailsArgs(chatId: chatId),
        );
        final user = getIt<ProfileBloc>().state.user;
        if (user != null) {
          getIt<ChatDetailsBloc>().add(ChatDetailsLoad(chatId, user));
        }
      }
    }
  }
}
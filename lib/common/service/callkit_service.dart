import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:logger/logger.dart';

@singleton
class CallKitService {
  final ApiService _apiService;
  final Logger _logger = Logger();
  String? callKitCallId;

  CallKitService(this._apiService);

  final StreamController<Map<String, dynamic>> _acceptController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<Map<String, dynamic>> _declineController =
      StreamController<Map<String, dynamic>>.broadcast();

  final StreamController<Map<String, dynamic>> _initCallController =
  StreamController<Map<String, dynamic>>.broadcast();

  StreamSubscription? _eventSubscription;

  /// Cached accept data for cold-start scenario where the event fires
  /// before any listener subscribes to the broadcast stream.
  Map<String, dynamic>? _pendingAcceptData;

  Map<String, dynamic>? consumePendingAccept() {
    final data = _pendingAcceptData;
    _pendingAcceptData = null;
    return data;
  }

  Stream<Map<String, dynamic>> get onAccept => _acceptController.stream;
  Stream<Map<String, dynamic>> get onDecline => _declineController.stream;
  Stream<Map<String, dynamic>> get onInit => _initCallController.stream;

  Future<void> initialize() async {
    if (await FlutterCallkitIncoming.canUseFullScreenIntent()) {
      await FlutterCallkitIncoming.requestFullIntentPermission();
    }
    _eventSubscription?.cancel();
    _eventSubscription = FlutterCallkitIncoming.onEvent.listen(_handleEvent);
    _logger.i('CallKitService initialized');
    if (Platform.isIOS) {
      final token = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      _sendTokenToServer(token);
    }

    // Android cold-start: the accept event is lost because the EventChannel
    // sink is null when BroadcastReceiver fires. However the plugin persists
    // accepted calls in SharedPreferences — read them here as a fallback.
    if (Platform.isAndroid) {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      _logger.d('Active calls on init: $activeCalls');
      if (activeCalls is List && activeCalls.isNotEmpty) {
        for (final call in activeCalls) {
          if (call is Map) {
            final callMap = Map<String, dynamic>.from(call);
            if (callMap['isAccepted'] == true && _pendingAcceptData == null) {
              final extra = _extractExtra(callMap);
              _pendingAcceptData = extra;
              _logger.i('Recovered accepted call from activeCalls: ${callMap['id']}');
              break;
            }
          }
        }
      }
    }
  }


  Future<void> showIncomingCall(CallKitParams params) async {
    try {
      _logger.i('Show incoming call');
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e, st) {
      _logger.e('Failed to show incoming call', error: e, stackTrace: st);
    }
  }

  Future<void> endCall(String uuid) async {
    try {
      await FlutterCallkitIncoming.endCall(uuid);
      _pendingAcceptData = null;
    } catch (e, st) {
      _logger.e('Failed to end call $uuid', error: e, stackTrace: st);
    }
  }

  Future<void> endAllCalls() async {
    try {
      await FlutterCallkitIncoming.endAllCalls();
      callKitCallId = null;
      _pendingAcceptData = null;
    } catch (e, st) {
      _logger.e('Failed to end all calls', error: e, stackTrace: st);
    }
  }

  void _handleEvent(CallEvent? event) {
    if (event == null) return;

    final body = event.body is Map
        ? Map<String, dynamic>.from(event.body as Map)
        : <String, dynamic>{};

    _logger.d('CallKit event: ${event.event}, body: $body');

    switch (event.event) {
      case Event.actionCallIncoming:
        callKitCallId = body['id'];
      case Event.actionCallAccept:
        callKitCallId = body['id'];
        final extra = _extractExtra(body);
        _pendingAcceptData = extra;
        _acceptController.add(extra);
      case Event.actionCallDecline:
        _pendingAcceptData = null;
        final extra = _extractExtra(body);
        _declineController.add(extra);
      case Event.actionCallTimeout:
        _pendingAcceptData = null;
        final extra = _extractExtra(body);
        _declineController.add(extra);
      case Event.actionCallEnded:
        _pendingAcceptData = null;
        final extra = _extractExtra(body);
        _declineController.add(extra);

      case Event.actionCallCallback:
        callKitCallId = body['id'];
        final extra = _extractExtra(body);
        _initCallController.add(extra);

      default:
        break;
    }
  }

  Map<String, dynamic> _extractExtra(Map<String, dynamic> body) {
    final extra = body['extra'];
    if (extra is Map) {
      return Map<String, dynamic>.from(extra);
    }
    return body;
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      _logger.i('Sending VoIP token ($token) to server');

      await _apiService.post(
        ApiConstants.updateVoipToken,
        data: {
          'voip_token': token,
          'apns_env': kReleaseMode ? 'prod' : 'sandbox',
        },
      );

      _logger.i('VoIP token sent to server successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to send VoIP token to server', error: e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _acceptController.close();
    _declineController.close();
  }
}

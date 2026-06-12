import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/common/constants/api_constants.dart';
import 'package:lets_talk/common/service/api_service.dart';
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

  /// Cached params from the last incoming call event — used to forward extra
  /// data on accept/callback events which only carry the call id.
  CallKitParams? _lastIncomingParams;

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
      // if (token != null) _sendTokenToServer(token);
    }

    // Android cold-start: the accept event is lost because the EventChannel
    // sink is null when BroadcastReceiver fires. However the plugin persists
    // accepted calls in SharedPreferences — read them here as a fallback.
    if (Platform.isAndroid) {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      _logger.d('Active calls on init: $activeCalls');
      for (final call in activeCalls) {
        if (call.isAccepted && _pendingAcceptData == null) {
          _pendingAcceptData = call.extra ?? {};
          _logger.i('Recovered accepted call from activeCalls: ${call.id}');
          break;
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

    _logger.d('CallKit event: ${event.eventName}');

    switch (event) {
      case CallEventActionCallIncoming():
        callKitCallId = event.callKitParams.id;
        _lastIncomingParams = event.callKitParams;
      case CallEventActionCallAccept():
        callKitCallId = event.id;
        final extra = _lastIncomingParams?.extra ?? {};
        _pendingAcceptData = extra;
        _acceptController.add(extra);
      case CallEventActionCallDecline():
        _pendingAcceptData = null;
        _declineController.add({'id': event.id});
      case CallEventActionCallTimeout():
        _pendingAcceptData = null;
        _declineController.add({'id': event.id});
      case CallEventActionCallEnded():
        _pendingAcceptData = null;
        _declineController.add({'id': event.id});
      case CallEventActionCallCallback():
        callKitCallId = event.id;
        _initCallController.add(_lastIncomingParams?.extra ?? {});
      default:
        break;
    }
  }

  Future<void> unregisterFromServer() async {
    try {
      _logger.i('Unregistering VoIP token from server');
      await _apiService.post(
        ApiConstants.updateVoipToken,
        data: {
          'voip_token': null,
          'apns_env': kReleaseMode ? 'prod' : 'sandbox',
        },
      );
      _logger.i('VoIP token unregistered from server');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to unregister VoIP token from server',
        error: e,
        stackTrace: stackTrace,
      );
    }
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
      _logger.e(
        'Failed to send VoIP token to server',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _acceptController.close();
    _declineController.close();
  }
}

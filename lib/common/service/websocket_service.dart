import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:lets_talk/feature/shell/connectivity/domain/bloc/connectivity_bloc.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

@singleton
class WebSocketService with WidgetsBindingObserver {
  WebSocketService(this._connectivityBloc);

  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();
  StreamSubscription? _socketSubscription;
  final Logger _logger = Logger();

  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _intentionalDisconnect = false;
  bool _connecting = false;

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const List<Duration> _fastReconnectDelays = [
    Duration(milliseconds: 200),
    Duration(milliseconds: 500),
    Duration(milliseconds: 800),
  ];
  static const Duration _maxReconnectDelay = Duration(seconds: 8);

  final List<dynamic> _pendingMessages = [];
  static const int _maxPendingMessages = 100;

  /// dart:io WebSocket sends protocol-level ping frames at this interval;
  /// if pong is not received the connection is automatically closed.
  static const Duration _pingInterval = Duration(seconds: 25);
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _staleBackgroundThreshold = Duration(seconds: 30);

  DateTime? _backgroundedAt;

  Stream<dynamic> get stream => _controller.stream;

  @postConstruct
  void init() {
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription = _connectivityBloc.stream.listen((state) {
      if (state is ConnectivitySuccess) {
        final hasConnection =
            state.results.any((result) => result != ConnectivityResult.none);

        if (hasConnection && _channel == null && !_intentionalDisconnect) {
          _logger.i('Network restored, reconnecting WebSocket...');
          connect();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundedAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _logger.i('App resumed from background');
      final wasInBackground = _backgroundedAt != null
          ? DateTime.now().difference(_backgroundedAt!)
          : Duration.zero;
      _backgroundedAt = null;

      // After extended background the OS likely killed the TCP socket
      if (wasInBackground > _staleBackgroundThreshold && _channel != null) {
        _logger.i(
          'Force reconnect after ${wasInBackground.inSeconds}s in background',
        );
        _handleDisconnect();
      }

      if (_channel == null && !_intentionalDisconnect) {
        _logger.i('Reconnecting WebSocket on app resume...');
        connect();
      }
    }
  }

  Stream<Map<String, dynamic>> get signalingStream {
    return stream
        .transform<Map<String, dynamic>>(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              try {
                final Map<String, dynamic> map;
                if (data is String) {
                  map = jsonDecode(data);
                } else if (data is Map) {
                  map = Map<String, dynamic>.from(data);
                } else {
                  return;
                }
                _logger.d('WebSocket received: $map');
                sink.add(map);
              } catch (e) {
                _logger.e('Error parsing signaling message: $e');
              }
            },
          ),
        )
        .asBroadcastStream();
  }

  Future<void> connect({Iterable<String>? protocols}) async {
    _reconnectTimer?.cancel();
    _intentionalDisconnect = false;
    if (_channel != null || _connecting) return;
    _connecting = true;

    try {
      final ws = await WebSocket.connect(
        Env.wsUrl,
        protocols: protocols,
      ).timeout(_connectTimeout);
      ws.pingInterval = _pingInterval;

      _channel = IOWebSocketChannel(ws);

      _socketSubscription = _channel!.stream.listen(
        (data) {
          _controller.add(data);
        },
        onError: (error) {
          _logger.e('WebSocket stream error: $error');
          _controller.addError(error);
          _handleDisconnect();
        },
        onDone: () {
          _logger.i('WebSocket stream closed');
          _handleDisconnect();
        },
      );

      // Safety net: detect sink closure even if stream onDone doesn't fire
      _channel!.sink.done.then((_) {
        if (_channel != null) {
          _logger.i('WebSocket sink done, cleaning up');
          _handleDisconnect();
        }
      });

      _reconnectAttempts = 0;
      _logger.i('WebSocket connected to ${Env.wsUrl}');

      final bloc = getIt<AuthBloc>();
      if (bloc.state is AuthAuthenticated) {
        authenticate((bloc.state as AuthAuthenticated).token!);
      }
    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      _channel = null;
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _handleDisconnect() {
    if (_channel == null) return;
    final ch = _channel;
    _channel = null;
    _socketSubscription?.cancel();
    _socketSubscription = null;
    try {
      ch?.sink.close();
    } catch (_) {}
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_reconnectTimer?.isActive ?? false) return;

    final Duration delay;
    if (_reconnectAttempts < _fastReconnectDelays.length) {
      delay = _fastReconnectDelays[_reconnectAttempts];
    } else {
      final expMs = pow(2, _reconnectAttempts - _fastReconnectDelays.length + 1).toInt() * 1000;
      delay = Duration(milliseconds: min(expMs, _maxReconnectDelay.inMilliseconds));
    }
    _reconnectAttempts++;

    _logger.i(
      'Scheduling reconnect in ${delay.inMilliseconds}ms (attempt $_reconnectAttempts)',
    );
    _reconnectTimer = Timer(delay, connect);
  }

  Future<void> disconnect({
    int? closeCode,
    String? closeReason,
  }) async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();

    if (_channel != null) {
      final ch = _channel;
      _channel = null;
      await _socketSubscription?.cancel();
      _socketSubscription = null;

      await ch!.sink.close(
        closeCode ?? status.goingAway,
        closeReason,
      );
      _logger.i('WebSocket disconnected');
    }
  }

  void send(dynamic data) {
    if (_channel == null) {
      _logger.w('WebSocket not connected, queuing message');
      _queueMessage(data);
      connect();
      return;
    }

    try {
      if (data is Map || data is List) {
        final jsonStr = jsonEncode(data);
        _channel!.sink.add(jsonStr);
        _logger.d('WebSocket sent: $jsonStr');
      } else {
        _channel!.sink.add(data);
        _logger.d('WebSocket sent: $data');
      }
    } catch (e) {
      _logger.e('WebSocket send error: $e');
      _queueMessage(data);
      _handleDisconnect();
    }
  }

  void _queueMessage(dynamic data) {
    if (_pendingMessages.length >= _maxPendingMessages) {
      _pendingMessages.removeAt(0);
    }
    _pendingMessages.add(data);
  }

  void _flushPendingMessages() {
    if (_pendingMessages.isEmpty) return;
    _logger.i('Resending ${_pendingMessages.length} pending messages');
    final messages = List.from(_pendingMessages);
    _pendingMessages.clear();
    for (final msg in messages) {
      send(msg);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _connectivitySubscription?.cancel();
    _reconnectTimer?.cancel();
  }

  void sendMessage(
      int chatId,
      String text, {
        String? messageType,
        int? mediaId,
        int? replyToMessageId,
        String? tempMessageId,
      }) {
    final Map<String, dynamic> data = {
      'type': 'message',
      'chat_id': chatId,
      'text': text,
    };
    if (messageType != null) {
      data['message_type'] = messageType;
    }
    if (mediaId != null) {
      data['media_id'] = mediaId;
    }
    if (replyToMessageId != null) {
      data['reply_to_message_id'] = replyToMessageId;
    }
    if (tempMessageId != null) {
      data['temp_message_id'] = tempMessageId;
    }
    send(data);
  }

  void sendTyping(int chatId, bool isTyping) {
    send({
      "type": "typing",
      "chat_id": chatId,
      "is_typing": isTyping,
    });
  }

  void forwardMessage(int messageId, int targetChatId) {
    send({
      'type': 'forward_message',
      'message_id': messageId,
      'target_chat_id': targetChatId,
    });
  }

  void authenticate(String token) {
    send({
      'type': 'auth',
      'token': token,
    });
    _flushPendingMessages();
  }

  void readMessage(int chatId, int messageId) {
    send({
      "type": "read_message",
      "chat_id": chatId,
      "message_id": messageId
    });
  }

  void editMessage(int messageId, String newText) {
    send({
      "type": "edit_message",
      "message_id": messageId,
      "new_text": newText,
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:lets_talk/app/environment/environment.dart';
import 'package:lets_talk/di/injection.dart';
import 'package:lets_talk/feature/auth/domain/auth_bloc/auth_bloc.dart';
import 'package:lets_talk/feature/auth/domain/repository/auth_repository.dart';
import 'package:lets_talk/feature/shell/connectivity/domain/bloc/connectivity_bloc.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

@singleton
class WebSocketService with WidgetsBindingObserver {
  WebSocketService(this._connectivityBloc);

  WebSocketChannel? _channel;
  final StreamController<dynamic> _controller = StreamController<dynamic>.broadcast();
  StreamSubscription? _socketSubscription;
  final Logger _logger = Logger();

  final ConnectivityBloc _connectivityBloc;
  StreamSubscription? _connectivitySubscription;
  bool _intentionalDisconnect = false;

  Timer? _reconnectTimer;

  Stream<dynamic> get stream => _controller.stream;

  @postConstruct
  void init() {
    WidgetsBinding.instance.addObserver(this);

    _connectivitySubscription = _connectivityBloc.stream.listen((state) {
      if (state is ConnectivitySuccess) {
        final hasConnection = state.results.any((result) =>
        result != ConnectivityResult.none
        );

        if (hasConnection && _channel == null && !_intentionalDisconnect) {
          _logger.i('Network restored, reconnecting WebSocket...');
          connect();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _logger.i('App resumed from background');
      if (_channel == null && !_intentionalDisconnect) {
        _logger.i('Reconnecting WebSocket on app resume...');
        connect();
      }
    }
  }

  Stream<Map<String, dynamic>> get signalingStream {
    return stream.transform<Map<String, dynamic>>(
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
    ).asBroadcastStream();
  }

  void connect({Iterable<String>? protocols}) {
    _reconnectTimer?.cancel();
    _intentionalDisconnect = false;
    if (_channel != null) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(Env.wsUrl),
        protocols: protocols,
      );

      _socketSubscription = _channel!.stream.listen(
            (data) {
          _controller.add(data);
        },
        onError: (error) {
          _logger.e('WebSocket stream error: $error');
          _controller.addError(error);
          _scheduleReconnect();
        },
        onDone: () {
          _logger.i('WebSocket stream closed');
          _channel = null;
          _socketSubscription = null;
          _scheduleReconnect();
        },
      );

      _logger.i('WebSocket connected to ${Env.wsUrl}');
      final bloc = getIt<AuthBloc>();
      if (bloc.state is AuthAuthenticated) {
        authenticate((bloc.state as AuthAuthenticated).token!);
      }
    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _logger.i('Scheduling WebSocket reconnect in 5 seconds...');
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      _logger.i('Executing scheduled reconnect...');
      connect();
    });
  }

  Future<void> disconnect({
    int? closeCode,
    String? closeReason,
  }) async {
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();

    if (_channel != null) {
      await _socketSubscription?.cancel();
      _socketSubscription = null;

      await _channel!.sink.close(
        closeCode ?? status.goingAway,
        closeReason,
      );
      _channel = null;
      _logger.i('WebSocket disconnected');
    }
  }

  void send(dynamic data) async {
    if (_channel != null) {
      try {
        await _channel!.ready;
      } on SocketException catch (e) {
        _logger.e('SocketException: $e');
      } on WebSocketChannelException catch (e) {
        _logger.e('WebSocketChannelException: $e');
      }
      if (data is Map || data is List) {
        final jsonStr = jsonEncode(data);
        _channel!.sink.add(jsonStr);
        _logger.d('WebSocket sent: $jsonStr');
      } else {
        _channel!.sink.add(data);
        _logger.d('WebSocket sent: $data');
      }
    } else {
      _logger.w('WebSocket not connected, cannot send data');
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
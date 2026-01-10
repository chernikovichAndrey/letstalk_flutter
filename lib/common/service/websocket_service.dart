import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  WebSocketChannel? _channel;
  Stream<dynamic>? _broadcastStream;
  final Logger _logger = Logger();

  Stream<dynamic> get stream {
    if (_channel == null) {
      throw Exception('WebSocket connection not established');
    }
    return _broadcastStream!;
  }

  void connect(String url, {Iterable<String>? protocols}) {
    if (_channel != null) return;

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
        protocols: protocols,
      );
      _broadcastStream = _channel!.stream.asBroadcastStream();
      _logger.i('WebSocket connected to $url');
    } catch (e) {
      _logger.e('WebSocket connection error: $e');
      rethrow;
    }
  }

  Future<void> disconnect({
    int? closeCode,
    String? closeReason,
  }) async {
    if (_channel != null) {
      await _channel!.sink.close(
        closeCode ?? status.goingAway,
        closeReason,
      );
      _channel = null;
      _broadcastStream = null;
      _logger.i('WebSocket disconnected');
    }
  }

  void send(dynamic data) {
    if (_channel != null) {
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

  void sendMessage(int chatId, String text) {
    send({
      'type': 'message',
      'chat_id': chatId,
      'text': text,
    });
  }

  void authenticate(String token) {
    send({
      'type': 'auth',
      'token': token,
    });
  }
}

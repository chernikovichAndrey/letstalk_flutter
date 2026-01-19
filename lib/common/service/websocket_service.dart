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

            final type = map['type'];
            const signalingTypes = {
              'call_offered',
              'call_incoming',
              'call_answered',
              'ice_candidate',
              'call_ended',
              'call_rejected',
              'call_failed',
            };

            if (signalingTypes.contains(type)) {
              sink.add(map);
            }
          } catch (e) {
            _logger.e('Error parsing signaling message: $e');
          }
        },
      ),
    ).asBroadcastStream();
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

  void sendTyping(int chatId, bool isTyping) {
    send({
      "type": "typing",
      "chat_id": chatId,
      "is_typing": isTyping,
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
}

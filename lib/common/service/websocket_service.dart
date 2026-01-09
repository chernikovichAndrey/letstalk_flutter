import 'dart:async';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;
  final Logger _logger = Logger();
  
  Stream<dynamic> get stream {
    if (_channel == null) {
      throw Exception('WebSocket connection not established');
    }
    return _channel!.stream;
  }

  void connect(String url, {Iterable<String>? protocols}) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
        protocols: protocols,
      );
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
      _logger.i('WebSocket disconnected');
    }
  }

  void send(dynamic data) {
    if (_channel != null) {
      _channel!.sink.add(data);
      _logger.d('WebSocket sent: $data');
    } else {
      _logger.w('WebSocket not connected, cannot send data');
    }
  }
}

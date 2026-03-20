import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_models.dart';
import '../api/endpoints.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  WebSocketService();

  void connect(String accessToken) {
    disconnect();
    final uri = Uri.parse('${Endpoints.wsUrl}?token=$accessToken');
    _channel = WebSocketChannel.connect(uri);
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  Stream<MessageResponse> get messageStream {
    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }
    return _channel!.stream.map((event) {
      final jsonMap = jsonDecode(event as String);
      return MessageResponse.fromJson(jsonMap);
    });
  }

  void sendMessage(MessageCreate request) {
    if (_channel == null) throw Exception('WebSocket not connected');
    _channel!.sink.add(jsonEncode(request.toJson()));
  }
}

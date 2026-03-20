import 'package:flutter/material.dart';
import 'package:yoauto_api/yoauto_api.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService chatService;
  ChatProvider(this.chatService);

  List<ChatListResponse> _chats = [];
  List<MessageResponse> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatListResponse> get chats => _chats;
  List<MessageResponse> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _chats = await chatService.getChats();
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();
    try {
      _messages = await chatService.getMessages(chatId);
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      final messageCreate = MessageCreate(content: content);
      final sent = await chatService.sendMessage(chatId, messageCreate);
      _messages = [..._messages, sent];
      notifyListeners();
    } on AppException catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

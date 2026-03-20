import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/chat_models.dart';
import '../exceptions/app_exception.dart';
import 'package:dio/dio.dart';

class ChatService {
  final ApiClient _apiClient;
  ChatService(this._apiClient);

  Future<List<ChatListResponse>> getChats() async {
    try {
      final response = await _apiClient.dio.get(Endpoints.chats);
      final data = response.data;
      // API may return list directly or wrapped
      final List items = data is List ? data : (data['items'] ?? data['chats'] ?? []);
      return items.map((e) => ChatListResponse.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<List<MessageResponse>> getMessages(String chatId) async {
    try {
      final response = await _apiClient.dio.get(Endpoints.chatMessages(chatId));
      final data = response.data;
      final List items = data is List ? data : (data['items'] ?? data['messages'] ?? []);
      return items.map((e) => MessageResponse.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<MessageResponse> sendMessage(String chatId, MessageCreate message) async {
    try {
      final response = await _apiClient.dio.post(
        Endpoints.chatMessages(chatId),
        data: message.toJson(),
      );
      return MessageResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }
}

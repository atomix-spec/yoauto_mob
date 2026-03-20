import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../models/notification_models.dart';
import '../exceptions/app_exception.dart';
import 'package:dio/dio.dart';

class NotificationService {
  final ApiClient _apiClient;
  NotificationService(this._apiClient);

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get(Endpoints.notifications);
      final data = response.data;
      final List items = data is List ? data : (data['items'] ?? data['notifications'] ?? []);
      return items.map((e) => AppNotification.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }

  Future<void> registerDevice(PushDeviceCreate request) async {
    try {
      await _apiClient.dio.post(Endpoints.pushDevices, data: request.toJson());
    } on DioException catch (e) {
      if (e.error is AppException) throw e.error!;
      throw NetworkException();
    } catch (_) {
      throw ServerException();
    }
  }
}

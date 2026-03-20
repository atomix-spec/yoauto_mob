import 'package:flutter/material.dart';
import 'package:yoauto_api/yoauto_api.dart';

class NotificationsProvider extends ChangeNotifier {
  final NotificationService notificationService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationsProvider(this.notificationService);

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await notificationService.getNotifications();
    } on AppException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

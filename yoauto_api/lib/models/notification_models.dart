/// Notification list item
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? icon;
  final String? actionUrl;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({required this.id, required this.type, required this.title, required this.body, this.icon, this.actionUrl, required this.isRead, required this.createdAt});

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    type: json['type'],
    title: json['title'],
    body: json['body'],
    icon: json['icon'],
    actionUrl: json['action_url'],
    isRead: json['is_read'],
    createdAt: DateTime.parse(json['created_at']),
  );
}

/// Register push notification device
class PushDeviceCreate {
  final String deviceToken;
  final String deviceType;
  final String? deviceName;

  PushDeviceCreate({required this.deviceToken, required this.deviceType, this.deviceName});
  Map<String, dynamic> toJson() => {
    'device_token': deviceToken,
    'device_type': deviceType,
    if (deviceName != null) 'device_name': deviceName,
  };
}

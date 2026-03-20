/// Remote config - not yet supported by this API version.
class MobileConfig {
  final bool maintenanceMode;
  final String? minVersion;
  MobileConfig({this.maintenanceMode = false, this.minVersion});
  factory MobileConfig.fromJson(Map<String, dynamic> json) => MobileConfig(
    maintenanceMode: json['maintenance_mode'] ?? false,
    minVersion: json['min_version'],
  );
}

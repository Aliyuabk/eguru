class AgentCheckin {
  final String id;
  final String tenantId;
  final String electionId;
  final String agentId;
  final String assignmentId;
  final String puId;
  final String checkinType;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;
  final double? gpsDistanceFromPu;
  final String? photoUrl;
  final String? deviceId;
  final int? deviceBattery;
  final String? networkType;
  final bool isOfflineSync;
  final DateTime createdAt;

  AgentCheckin({
    required this.id,
    required this.tenantId,
    required this.electionId,
    required this.agentId,
    required this.assignmentId,
    required this.puId,
    required this.checkinType,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    this.gpsDistanceFromPu,
    this.photoUrl,
    this.deviceId,
    this.deviceBattery,
    this.networkType,
    this.isOfflineSync = false,
    required this.createdAt,
  });

  factory AgentCheckin.fromJson(Map<String, dynamic> json) {
    return AgentCheckin(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      electionId: json['election_id']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      puId: json['pu_id']?.toString() ?? '',
      checkinType: json['checkin_type'] ?? '',
      gpsLat: json['gps_lat'] != null ? double.parse(json['gps_lat']) : null,
      gpsLng: json['gps_lng'] != null ? double.parse(json['gps_lng']) : null,
      gpsAccuracy: json['gps_accuracy'] != null ? double.parse(json['gps_accuracy']) : null,
      gpsDistanceFromPu: json['gps_distance_from_pu'] != null ? double.parse(json['gps_distance_from_pu']) : null,
      photoUrl: json['photo_url'],
      deviceId: json['device_id'],
      deviceBattery: json['device_battery'],
      networkType: json['network_type'],
      isOfflineSync: json['is_offline_sync'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'election_id': electionId,
      'agent_id': agentId,
      'assignment_id': assignmentId,
      'pu_id': puId,
      'checkin_type': checkinType,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'gps_accuracy': gpsAccuracy,
      'gps_distance_from_pu': gpsDistanceFromPu,
      'photo_url': photoUrl,
      'device_id': deviceId,
      'device_battery': deviceBattery,
      'network_type': networkType,
      'is_offline_sync': isOfflineSync ? 1 : 0,
    };
  }
}
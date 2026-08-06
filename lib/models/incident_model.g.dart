// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Incident _$IncidentFromJson(Map<String, dynamic> json) => Incident(
      id: (json['id'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      electionId: (json['electionId'] as num?)?.toInt(),
      reporterId: (json['reporterId'] as num).toInt(),
      puId: (json['puId'] as num?)?.toInt(),
      wardId: (json['wardId'] as num?)?.toInt(),
      lgaId: (json['lgaId'] as num?)?.toInt(),
      stateId: (json['stateId'] as num?)?.toInt(),
      incidentType: json['incidentType'] as String,
      severity: json['severity'] as String? ?? 'medium',
      isPanic: json['isPanic'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String,
      gpsLat: (json['gpsLat'] as num?)?.toDouble(),
      gpsLng: (json['gpsLng'] as num?)?.toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble(),
      photoUrlsJson: (json['photoUrlsJson'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      videoUrl: json['videoUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      deviceId: json['deviceId'] as String?,
      status: json['status'] as String? ?? 'reported',
      assignedTo: (json['assignedTo'] as num?)?.toInt(),
      resolvedBy: (json['resolvedBy'] as num?)?.toInt(),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolutionNotes: json['resolutionNotes'] as String?,
      isOfflineSync: json['isOfflineSync'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$IncidentToJson(Incident instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'electionId': instance.electionId,
      'reporterId': instance.reporterId,
      'puId': instance.puId,
      'wardId': instance.wardId,
      'lgaId': instance.lgaId,
      'stateId': instance.stateId,
      'incidentType': instance.incidentType,
      'severity': instance.severity,
      'isPanic': instance.isPanic,
      'title': instance.title,
      'description': instance.description,
      'gpsLat': instance.gpsLat,
      'gpsLng': instance.gpsLng,
      'gpsAccuracy': instance.gpsAccuracy,
      'photoUrlsJson': instance.photoUrlsJson,
      'videoUrl': instance.videoUrl,
      'audioUrl': instance.audioUrl,
      'deviceId': instance.deviceId,
      'status': instance.status,
      'assignedTo': instance.assignedTo,
      'resolvedBy': instance.resolvedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolutionNotes': instance.resolutionNotes,
      'isOfflineSync': instance.isOfflineSync,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
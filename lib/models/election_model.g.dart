// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'election_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Election _$ElectionFromJson(Map<String, dynamic> json) => Election(
      id: (json['id'] as num).toInt(),
      tenantId: (json['tenantId'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      cycle: json['cycle'] as String,
      electionDate: DateTime.parse(json['electionDate'] as String),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      statesJson: (json['statesJson'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      lgasJson: (json['lgasJson'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      wardsJson: (json['wardsJson'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      pusJson: (json['pusJson'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      status: json['status'] as String,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdBy: (json['createdBy'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ElectionToJson(Election instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'type': instance.type,
      'cycle': instance.cycle,
      'electionDate': instance.electionDate.toIso8601String(),
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'statesJson': instance.statesJson,
      'lgasJson': instance.lgasJson,
      'wardsJson': instance.wardsJson,
      'pusJson': instance.pusJson,
      'status': instance.status,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

PollingUnit _$PollingUnitFromJson(Map<String, dynamic> json) => PollingUnit(
      id: (json['id'] as num).toInt(),
      wardId: (json['wardId'] as num).toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      gpsLat: (json['gpsLat'] as num?)?.toDouble(),
      gpsLng: (json['gpsLng'] as num?)?.toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble(),
      address: json['address'] as String?,
      registeredVoters: (json['registeredVoters'] as num?)?.toInt() ?? 0,
      accreditedVoters: (json['accreditedVoters'] as num?)?.toInt() ?? 0,
      isRural: json['isRural'] as bool? ?? false,
      networkQuality: json['networkQuality'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PollingUnitToJson(PollingUnit instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wardId': instance.wardId,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'gpsLat': instance.gpsLat,
      'gpsLng': instance.gpsLng,
      'gpsAccuracy': instance.gpsAccuracy,
      'address': instance.address,
      'registeredVoters': instance.registeredVoters,
      'accreditedVoters': instance.accreditedVoters,
      'isRural': instance.isRural,
      'networkQuality': instance.networkQuality,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Checklist _$ChecklistFromJson(Map<String, dynamic> json) => Checklist(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      electionId: (json['electionId'] as num?)?.toInt(),
      puId: (json['puId'] as num?)?.toInt(),
      materialsArrived: json['materialsArrived'] as bool? ?? false,
      pollOpened: json['pollOpened'] as bool? ?? false,
      accreditationStarted: json['accreditationStarted'] as bool? ?? false,
      votingStarted: json['votingStarted'] as bool? ?? false,
      countingStarted: json['countingStarted'] as bool? ?? false,
      pollClosed: json['pollClosed'] as bool? ?? false,
      status: json['status'] as String? ?? 'draft',
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChecklistToJson(Checklist instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'electionId': instance.electionId,
      'puId': instance.puId,
      'materialsArrived': instance.materialsArrived,
      'pollOpened': instance.pollOpened,
      'accreditationStarted': instance.accreditationStarted,
      'votingStarted': instance.votingStarted,
      'countingStarted': instance.countingStarted,
      'pollClosed': instance.pollClosed,
      'status': instance.status,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
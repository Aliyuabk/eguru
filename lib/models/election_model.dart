import 'package:json_annotation/json_annotation.dart';

part 'election_model.g.dart';

@JsonSerializable()
class Election {
  final int id;
  final int tenantId;
  final String name;
  final String type;
  final String cycle;
  final DateTime electionDate;
  final String? startTime;
  final String? endTime;
  final List<int>? statesJson;
  final List<int>? lgasJson;
  final List<int>? wardsJson;
  final List<int>? pusJson;
  final String status;
  final String? description;
  final String? logoUrl;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Election({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.type,
    required this.cycle,
    required this.electionDate,
    this.startTime,
    this.endTime,
    this.statesJson,
    this.lgasJson,
    this.wardsJson,
    this.pusJson,
    required this.status,
    this.description,
    this.logoUrl,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Election.fromJson(Map<String, dynamic> json) => _$ElectionFromJson(json);
  Map<String, dynamic> toJson() => _$ElectionToJson(this);
  
  bool get isActive => status == 'active';
  bool get isUpcoming => status == 'upcoming';
  bool get isClosed => status == 'closed';
  bool get isDraft => status == 'draft';
}

@JsonSerializable()
class PollingUnit {
  final int id;
  final int wardId;
  final String code;
  final String name;
  final String? description;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;
  final String? address;
  final int registeredVoters;
  final int accreditedVoters;
  final bool isRural;
  final String? networkQuality;
  final bool isActive;
  final DateTime createdAt;
  
  PollingUnit({
    required this.id,
    required this.wardId,
    required this.code,
    required this.name,
    this.description,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    this.address,
    this.registeredVoters = 0,
    this.accreditedVoters = 0,
    this.isRural = false,
    this.networkQuality,
    this.isActive = true,
    required this.createdAt,
  });

  factory PollingUnit.fromJson(Map<String, dynamic> json) => _$PollingUnitFromJson(json);
  Map<String, dynamic> toJson() => _$PollingUnitToJson(this);
}

@JsonSerializable()
class Checklist {
  final int id;
  final int userId;
  final int? electionId;
  final int? puId;
  final bool materialsArrived;
  final bool pollOpened;
  final bool accreditationStarted;
  final bool votingStarted;
  final bool countingStarted;
  final bool pollClosed;
  final String status;
  final DateTime? submittedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Checklist({
    required this.id,
    required this.userId,
    this.electionId,
    this.puId,
    this.materialsArrived = false,
    this.pollOpened = false,
    this.accreditationStarted = false,
    this.votingStarted = false,
    this.countingStarted = false,
    this.pollClosed = false,
    this.status = 'draft',
    this.submittedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Checklist.fromJson(Map<String, dynamic> json) => _$ChecklistFromJson(json);
  Map<String, dynamic> toJson() => _$ChecklistToJson(this);
}
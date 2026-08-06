import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'incident_model.g.dart';

@JsonSerializable()
class Incident {
  final int id;
  final int tenantId;
  final int? electionId;
  final int reporterId;
  final int? puId;
  final int? wardId;
  final int? lgaId;
  final int? stateId;
  final String incidentType;
  final String severity;
  final bool isPanic;
  final String title;
  final String description;
  final double? gpsLat;
  final double? gpsLng;
  final double? gpsAccuracy;
  final List<String>? photoUrlsJson;
  final String? videoUrl;
  final String? audioUrl;
  final String? deviceId;
  final String status;
  final int? assignedTo;
  final int? resolvedBy;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final bool isOfflineSync;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Incident({
    required this.id,
    required this.tenantId,
    this.electionId,
    required this.reporterId,
    this.puId,
    this.wardId,
    this.lgaId,
    this.stateId,
    required this.incidentType,
    this.severity = 'medium',
    this.isPanic = false,
    required this.title,
    required this.description,
    this.gpsLat,
    this.gpsLng,
    this.gpsAccuracy,
    this.photoUrlsJson,
    this.videoUrl,
    this.audioUrl,
    this.deviceId,
    this.status = 'reported',
    this.assignedTo,
    this.resolvedBy,
    this.resolvedAt,
    this.resolutionNotes,
    this.isOfflineSync = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Incident.fromJson(Map<String, dynamic> json) => _$IncidentFromJson(json);
  Map<String, dynamic> toJson() => _$IncidentToJson(this);
  
  String get severityLabel {
    switch (severity) {
      case 'low': return 'Low';
      case 'medium': return 'Medium';
      case 'high': return 'High';
      case 'critical': return 'Critical';
      default: return 'Unknown';
    }
  }
  
  Color get severityColor {
    switch (severity) {
      case 'low': return Colors.green;
      case 'medium': return Colors.orange;
      case 'high': return Colors.red;
      case 'critical': return Colors.purple;
      default: return Colors.grey;
    }
  }
  
  String get statusLabel {
    switch (status) {
      case 'reported': return 'Reported';
      case 'acknowledged': return 'Acknowledged';
      case 'investigating': return 'Investigating';
      case 'resolved': return 'Resolved';
      case 'escalated': return 'Escalated';
      case 'false_alarm': return 'False Alarm';
      default: return 'Unknown';
    }
  }
  
  Color get statusColor {
    switch (status) {
      case 'reported': return Colors.red;
      case 'acknowledged': return Colors.orange;
      case 'investigating': return Colors.blue;
      case 'resolved': return Colors.green;
      case 'escalated': return Colors.purple;
      case 'false_alarm': return Colors.grey;
      default: return Colors.grey;
    }
  }
}

class IncidentType {
  final String value;
  final String label;
  final IconData icon;
  
  const IncidentType({
    required this.value,
    required this.label,
    required this.icon,
  });

  static List<IncidentType> get types => [
    const IncidentType(value: 'violence', label: 'Violence', icon: Icons.warning),
    const IncidentType(value: 'intimidation', label: 'Intimidation', icon: Icons.person_off),
    const IncidentType(value: 'ballot_stuffing', label: 'Ballot Stuffing', icon: Icons.how_to_vote),
    const IncidentType(value: 'vote_buying', label: 'Vote Buying', icon: Icons.attach_money),
    const IncidentType(value: 'voter_suppression', label: 'Voter Suppression', icon: Icons.block),
    const IncidentType(value: 'material_shortage', label: 'Material Shortage', icon: Icons.inventory),
    const IncidentType(value: 'delay', label: 'Delay', icon: Icons.timer),
    const IncidentType(value: 'technical_issue', label: 'Technical Issue', icon: Icons.computer),
    const IncidentType(value: 'other', label: 'Other', icon: Icons.more_horiz),
  ];
}
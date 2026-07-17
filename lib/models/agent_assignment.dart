class AgentAssignment {
  final String id;
  final String tenantId;
  final String electionId;
  final String userId;
  final String puId;
  final String wardId;
  final String lgaId;
  final String stateId;
  final String assignmentType;
  final String status;
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String? notes;

  AgentAssignment({
    required this.id,
    required this.tenantId,
    required this.electionId,
    required this.userId,
    required this.puId,
    required this.wardId,
    required this.lgaId,
    required this.stateId,
    required this.assignmentType,
    required this.status,
    required this.assignedBy,
    required this.assignedAt,
    this.completedAt,
    this.notes,
  });

  factory AgentAssignment.fromJson(Map<String, dynamic> json) {
    return AgentAssignment(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      electionId: json['election_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      puId: json['pu_id']?.toString() ?? '',
      wardId: json['ward_id']?.toString() ?? '',
      lgaId: json['lga_id']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      assignmentType: json['assignment_type'] ?? '',
      status: json['status'] ?? '',
      assignedBy: json['assigned_by']?.toString() ?? '',
      assignedAt: json['assigned_at'] != null ? DateTime.parse(json['assigned_at']) : DateTime.now(),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'election_id': electionId,
      'user_id': userId,
      'pu_id': puId,
      'ward_id': wardId,
      'lga_id': lgaId,
      'state_id': stateId,
      'assignment_type': assignmentType,
      'status': status,
      'assigned_by': assignedBy,
      'assigned_at': assignedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
    };
  }
}
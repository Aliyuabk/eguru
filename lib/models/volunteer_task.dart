class VolunteerTask {
  final String id;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime? dueDate;
  final String location;
  final String status;
  final String? report;
  final DateTime? completedAt;
  final String assignedBy;
  final String assignedBy_name;

  VolunteerTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedDate,
    this.dueDate,
    required this.location,
    required this.status,
    this.report,
    this.completedAt,
    required this.assignedBy,
    required this.assignedBy_name,
  });

  factory VolunteerTask.fromJson(Map<String, dynamic> json) {
    return VolunteerTask(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedDate: json['assigned_date'] != null ? DateTime.parse(json['assigned_date']) : DateTime.now(),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      location: json['location'] ?? '',
      status: json['status'] ?? 'pending',
      report: json['report'],
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      assignedBy: json['assigned_by']?.toString() ?? '',
      assignedBy_name: json['assigned_by_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_date': assignedDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'location': location,
      'status': status,
      'report': report,
      'completed_at': completedAt?.toIso8601String(),
      'assigned_by': assignedBy,
      'assigned_by_name': assignedBy_name,
    };
  }
}
class Incident {
  final String id;
  final String title;
  final String description;
  final String location;
  final String type;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final String pollingUnitId;

  Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.type,
    required this.date,
    required this.status,
    this.imageUrl,
    required this.pollingUnitId,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'reported',
      imageUrl: json['image_url'],
      pollingUnitId: json['polling_unit_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'type': type,
      'date': date.toIso8601String(),
      'status': status,
      'image_url': imageUrl,
      'polling_unit_id': pollingUnitId,
    };
  }
}
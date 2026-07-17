class Observation {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final String pollingUnitId;

  Observation({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    this.imageUrl,
    required this.pollingUnitId,
  });

  factory Observation.fromJson(Map<String, dynamic> json) {
    return Observation(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'draft',
      imageUrl: json['image_url'],
      pollingUnitId: json['polling_unit_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'status': status,
      'image_url': imageUrl,
      'polling_unit_id': pollingUnitId,
    };
  }
}
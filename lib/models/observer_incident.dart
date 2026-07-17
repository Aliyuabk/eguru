class ObserverIncident {
  final String id;
  final String type;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final String? videoUrl;
  final String observerId;
  final String pollingUnitId;

  ObserverIncident({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
    this.videoUrl,
    required this.observerId,
    required this.pollingUnitId,
  });

  factory ObserverIncident.fromJson(Map<String, dynamic> json) {
    return ObserverIncident(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'reported',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      observerId: json['observer_id']?.toString() ?? '',
      pollingUnitId: json['polling_unit_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'status': status,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'observer_id': observerId,
      'polling_unit_id': pollingUnitId,
    };
  }
}
class ObserverObservation {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime date;
  final String time;
  final String status;
  final String? imageUrl;
  final String? videoUrl;
  final String observerId;
  final String pollingUnitId;

  ObserverObservation({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.imageUrl,
    this.videoUrl,
    required this.observerId,
    required this.pollingUnitId,
  });

  factory ObserverObservation.fromJson(Map<String, dynamic> json) {
    return ObserverObservation(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      time: json['time'] ?? '',
      status: json['status'] ?? 'draft',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      observerId: json['observer_id']?.toString() ?? '',
      pollingUnitId: json['polling_unit_id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'location': location,
      'date': date.toIso8601String(),
      'time': time,
      'status': status,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'observer_id': observerId,
      'polling_unit_id': pollingUnitId,
    };
  }
}
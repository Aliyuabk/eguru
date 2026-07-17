class CommunityReport {
  final String id;
  final String title;
  final String category;
  final String description;
  final String location;
  final DateTime date;
  final String status;
  final String? imageUrl;
  final String? videoUrl;
  final String volunteerId;

  CommunityReport({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.location,
    required this.date,
    required this.status,
    this.imageUrl,
    this.videoUrl,
    required this.volunteerId,
  });

  factory CommunityReport.fromJson(Map<String, dynamic> json) {
    return CommunityReport(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      status: json['status'] ?? 'draft',
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      volunteerId: json['volunteer_id']?.toString() ?? '',
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
      'status': status,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'volunteer_id': volunteerId,
    };
  }
}
class PollingUnit {
  final String id;
  final String name;
  final String code;
  final String ward;
  final String lga;
  final String state;
  final String election;
  final String coordinator;

  PollingUnit({
    required this.id,
    required this.name,
    required this.code,
    required this.ward,
    required this.lga,
    required this.state,
    required this.election,
    required this.coordinator,
  });

  factory PollingUnit.fromJson(Map<String, dynamic> json) {
    return PollingUnit(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      ward: json['ward'] ?? '',
      lga: json['lga'] ?? '',
      state: json['state'] ?? '',
      election: json['election'] ?? '',
      coordinator: json['coordinator'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'ward': ward,
      'lga': lga,
      'state': state,
      'election': election,
      'coordinator': coordinator,
    };
  }
}
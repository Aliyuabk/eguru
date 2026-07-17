import 'dart:convert';

class EC8AResult {
  final String id;
  final String tenantId;
  final String electionId;
  final String puId;
  final String wardId;
  final String lgaId;
  final String stateId;
  final String agentId;
  final String assignmentId;
  final String puCode;
  final String puName;
  final int registeredVoters;
  final int accreditedVoters;
  final int ballotPapersIssued;
  final int unusedBallots;
  final int spoiledBallots;
  final int rejectedVotes;
  final int validVotes;
  final int totalVotesCast;
  final List<Map<String, dynamic>> partyVotes;
  final String? photoUrl;
  final String? videoUrl;
  final String? audioUrl;
  final String? remarks;
  final double? gpsLat;
  final double? gpsLng;
  final String? deviceId;
  final String status;
  final bool isOfflineSync;
  final DateTime createdAt;

  EC8AResult({
    required this.id,
    required this.tenantId,
    required this.electionId,
    required this.puId,
    required this.wardId,
    required this.lgaId,
    required this.stateId,
    required this.agentId,
    required this.assignmentId,
    required this.puCode,
    required this.puName,
    required this.registeredVoters,
    required this.accreditedVoters,
    required this.ballotPapersIssued,
    required this.unusedBallots,
    required this.spoiledBallots,
    required this.rejectedVotes,
    required this.validVotes,
    required this.totalVotesCast,
    required this.partyVotes,
    this.photoUrl,
    this.videoUrl,
    this.audioUrl,
    this.remarks,
    this.gpsLat,
    this.gpsLng,
    this.deviceId,
    this.status = 'pending',
    this.isOfflineSync = false,
    required this.createdAt,
  });

  factory EC8AResult.fromJson(Map<String, dynamic> json) {
    return EC8AResult(
      id: json['id']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      electionId: json['election_id']?.toString() ?? '',
      puId: json['pu_id']?.toString() ?? '',
      wardId: json['ward_id']?.toString() ?? '',
      lgaId: json['lga_id']?.toString() ?? '',
      stateId: json['state_id']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      assignmentId: json['assignment_id']?.toString() ?? '',
      puCode: json['pu_code'] ?? '',
      puName: json['pu_name'] ?? '',
      registeredVoters: json['registered_voters'] ?? 0,
      accreditedVoters: json['accredited_voters'] ?? 0,
      ballotPapersIssued: json['ballot_papers_issued'] ?? 0,
      unusedBallots: json['unused_ballots'] ?? 0,
      spoiledBallots: json['spoiled_ballots'] ?? 0,
      rejectedVotes: json['rejected_votes'] ?? 0,
      validVotes: json['valid_votes'] ?? 0,
      totalVotesCast: json['total_votes_cast'] ?? 0,
      partyVotes: json['party_votes_json'] != null 
          ? List<Map<String, dynamic>>.from(jsonDecode(json['party_votes_json']))
          : [],
      photoUrl: json['photo_url'],
      videoUrl: json['video_url'],
      audioUrl: json['audio_url'],
      remarks: json['remarks'],
      gpsLat: json['gps_lat'] != null ? double.parse(json['gps_lat']) : null,
      gpsLng: json['gps_lng'] != null ? double.parse(json['gps_lng']) : null,
      deviceId: json['device_id'],
      status: json['status'] ?? 'pending',
      isOfflineSync: json['is_offline_sync'] == 1,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'election_id': electionId,
      'pu_id': puId,
      'ward_id': wardId,
      'lga_id': lgaId,
      'state_id': stateId,
      'agent_id': agentId,
      'assignment_id': assignmentId,
      'pu_code': puCode,
      'pu_name': puName,
      'registered_voters': registeredVoters,
      'accredited_voters': accreditedVoters,
      'ballot_papers_issued': ballotPapersIssued,
      'unused_ballots': unusedBallots,
      'spoiled_ballots': spoiledBallots,
      'rejected_votes': rejectedVotes,
      'valid_votes': validVotes,
      'total_votes_cast': totalVotesCast,
      'party_votes_json': jsonEncode(partyVotes),
      'photo_url': photoUrl,
      'video_url': videoUrl,
      'audio_url': audioUrl,
      'remarks': remarks,
      'gps_lat': gpsLat,
      'gps_lng': gpsLng,
      'device_id': deviceId,
      'status': status,
      'is_offline_sync': isOfflineSync ? 1 : 0,
    };
  }
}
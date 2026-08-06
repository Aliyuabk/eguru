class ApiConstants {
  // ✅ CORRECT URL - fixed spelling
  static const String baseUrl = 'https://guru.kowagurutech.ng/api/endpoints';
  
  // Auth endpoints
  static const String login = '/auth/login.php';
  static const String logout = '/auth/logout.php';
  static const String forgotPassword = '/auth/forgot_password.php';
  static const String changePassword = '/auth/change_password.php';
  static const String verifyToken = '/auth/verify_token.php';
  static const String verifyFingerprint = '/auth/verify_fingerprint.php';
  static const String registerFingerprint = '/auth/register_fingerprint.php';
  
  // Election endpoints
  static const String elections = '/elections/get_elections.php';
  static const String election = '/elections/get_election.php';
  static const String pollingUnits = '/elections/get_polling_units.php';
  static const String pollingUnit = '/elections/get_polling_unit.php';
  
  // Checklist endpoints
  static const String checklist = '/checklist/get_checklist.php';
  static const String updateChecklist = '/checklist/update_checklist.php';
  
  // Accreditation endpoints
  static const String accreditation = '/accreditation/get_accreditation.php';
  static const String submitAccreditation = '/accreditation/submit_accreditation.php';
  
  // Vote count endpoints
  static const String voteCount = '/vote_count/get_vote_count.php';
  static const String submitVoteCount = '/vote_count/submit_vote_count.php';
  
  // EC8A endpoints
  static const String uploadEC8A = '/ec8a/upload_ec8a.php';
  
  // Media endpoints
  static const String uploadMedia = '/media/upload_media.php';
  
  // Incident endpoints
  static const String incidents = '/incidents/get_incidents.php';
  static const String createIncident = '/incidents/create_incident.php';
  static const String updateIncident = '/incidents/update_incident.php';
  
  // Chat endpoints
  static const String chatRooms = '/chat/get_rooms.php';
  static const String chatMessages = '/chat/get_messages.php';
  static const String sendMessage = '/chat/send_message.php';
  static const String getContacts = '/chat/get_contacts.php';
  static const String getCoordinator = '/chat/get_coordinator.php';
  static const String markRead = '/chat/mark_read.php';
  static const String uploadFile = '/chat/upload_file.php';
  
  // Notification endpoints
  static const String notifications = '/notifications/get_notifications.php';
  static const String markNotificationRead = '/notifications/mark_read.php';
  
  // Profile endpoints
  static const String profile = '/profile/get_profile.php';
  static const String updateProfile = '/profile/update_profile.php';
  
  // Sync endpoints
  static const String syncData = '/sync/sync_data.php';
  static const String checkSyncStatus = '/sync/check_status.php';
  
  // Check-in endpoints
  static const String checkin = '/checkin/checkin.php';
  static const String checkinStatus = '/checkin/status.php';
}
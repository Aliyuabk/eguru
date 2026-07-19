class ApiConstants {
  static const String baseUrl = 'https://eguruelction.kowagurutech.ng/api/endpoints';
  
  // Auth endpoints
  static const String login = '/auth/login.php';
  static const String logout = '/auth/logout.php';
  static const String forgotPassword = '/auth/forgot_password.php';
  static const String changePassword = '/auth/change_password.php';
  static const String verifyToken = '/auth/verify_token.php';
  
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
  
  // Notification endpoints
  static const String notifications = '/notifications/get_notifications.php';
  
  // Profile endpoints
  static const String profile = '/profile/get_profile.php';
  static const String updateProfile = '/profile/update_profile.php';
}
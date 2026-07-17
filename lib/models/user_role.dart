enum UserRole {
  superAdmin,
  clientAdmin,
  national,
  state,
  senatorial,
  federalConstituency,
  lga,
  ward,
  puAgent,
  partyAgent,
  volunteer,
  observer,
  situationRoom,
  financeOfficer,
  citizen,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Administrator';
      case UserRole.clientAdmin:
        return 'Client Administrator';
      case UserRole.national:
        return 'National Coordinator';
      case UserRole.state:
        return 'State Coordinator';
      case UserRole.senatorial:
        return 'Senatorial Coordinator';
      case UserRole.federalConstituency:
        return 'Federal Constituency Coordinator';
      case UserRole.lga:
        return 'LGA Coordinator';
      case UserRole.ward:
        return 'Ward Coordinator';
      case UserRole.puAgent:
        return 'Polling Unit Agent';
      case UserRole.partyAgent:
        return 'Party Agent';
      case UserRole.volunteer:
        return 'Volunteer';
      case UserRole.observer:
        return 'Observer';
      case UserRole.situationRoom:
        return 'Situation Room';
      case UserRole.financeOfficer:
        return 'Finance Officer';
      case UserRole.citizen:
        return 'Citizen';
    }
  }
}
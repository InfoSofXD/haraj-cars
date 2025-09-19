enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  worker('worker', 'Worker'),
  client('client', 'Client');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.client,
    );
  }

  bool get isSuperAdmin => this == UserRole.superAdmin;
  bool get isWorker => this == UserRole.worker;
  bool get isClient => this == UserRole.client;
  bool get isAdmin => isSuperAdmin || isWorker;
}

class UserPermissions {
  final bool canViewDashboard;
  final bool canAddCars;
  final bool canEditCars;
  final bool canDeleteCars;
  final bool canManageUsers;
  final bool canManageAdmins;
  final bool canViewReports;
  final bool canAccessAdminPanel;
  final bool canSaveFavorites;
  final bool canViewCars;

  const UserPermissions({
    required this.canViewDashboard,
    required this.canAddCars,
    required this.canEditCars,
    required this.canDeleteCars,
    required this.canManageUsers,
    required this.canManageAdmins,
    required this.canViewReports,
    required this.canAccessAdminPanel,
    required this.canSaveFavorites,
    required this.canViewCars,
  });

  static UserPermissions forRole(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return const UserPermissions(
          canViewDashboard: true,
          canAddCars: true,
          canEditCars: true,
          canDeleteCars: true,
          canManageUsers: true,
          canManageAdmins: true,
          canViewReports: true,
          canAccessAdminPanel: true,
          canSaveFavorites: true,
          canViewCars: true,
        );
      case UserRole.worker:
        return const UserPermissions(
          canViewDashboard: true,
          canAddCars: true,
          canEditCars: true,
          canDeleteCars: false,
          canManageUsers: false,
          canManageAdmins: false,
          canViewReports: false,
          canAccessAdminPanel: true,
          canSaveFavorites: true,
          canViewCars: true,
        );
      case UserRole.client:
        return const UserPermissions(
          canViewDashboard: false,
          canAddCars: false,
          canEditCars: false,
          canDeleteCars: false,
          canManageUsers: false,
          canManageAdmins: false,
          canViewReports: false,
          canAccessAdminPanel: false,
          canSaveFavorites: true,
          canViewCars: true,
        );
    }
  }
}

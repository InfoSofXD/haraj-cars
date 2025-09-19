/// User roles enum for the Haraj Cars application
enum UserRole {
  superAdmin('super_admin', 'Super Admin'),
  worker('worker', 'Worker'),
  client('client', 'Client');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Get user role from string value
  static UserRole fromString(String value) {
    switch (value) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'worker':
        return UserRole.worker;
      case 'client':
        return UserRole.client;
      default:
        return UserRole.client;
    }
  }

  /// Check if user can manage cars (add, edit, delete)
  bool get canManageCars => this == UserRole.superAdmin || this == UserRole.worker;

  /// Check if user can access admin panel
  bool get canAccessAdminPanel => this == UserRole.superAdmin;

  /// Check if user can manage users
  bool get canManageUsers => this == UserRole.superAdmin;

  /// Check if user can view analytics
  bool get canViewAnalytics => this == UserRole.superAdmin || this == UserRole.worker;

  /// Check if user can only view cars and manage favorites
  bool get isReadOnly => this == UserRole.client;
}

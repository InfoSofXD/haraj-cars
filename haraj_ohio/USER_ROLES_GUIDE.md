# User Roles System Guide

## Overview

The Haraj Ohio application now implements a comprehensive user role system with three distinct user types, each with specific permissions and access levels.

## User Roles

### 1. Super Admin (`super_admin`)
**Full system access and control**

**Permissions:**
- ✅ View dashboard with full statistics
- ✅ Add, edit, and delete cars
- ✅ Manage all users (view, edit roles, delete)
- ✅ Manage other admins
- ✅ View reports and analytics
- ✅ Access admin panel
- ✅ Save favorites
- ✅ View all cars

**Use Cases:**
- System administrators
- Business owners
- Technical managers

### 2. Worker (`worker`)
**Limited admin access for car management**

**Permissions:**
- ✅ View dashboard with relevant statistics
- ✅ Add and edit cars
- ❌ Delete cars
- ❌ Manage users
- ❌ Manage admins
- ❌ View reports
- ✅ Access admin panel
- ✅ Save favorites
- ✅ View all cars

**Use Cases:**
- Car dealership employees
- Sales representatives
- Content managers

### 3. Client (`client`)
**Standard user access**

**Permissions:**
- ❌ View dashboard
- ❌ Add/edit/delete cars
- ❌ Manage users
- ❌ Manage admins
- ❌ View reports
- ❌ Access admin panel
- ✅ Save favorites
- ✅ View all cars
- ✅ Access community features

**Use Cases:**
- Regular customers
- Car buyers
- General users

## Implementation Details

### Database Schema

The user roles are stored in a dedicated `users` table with the following structure:

```sql
CREATE TABLE users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('super_admin', 'worker', 'client')),
    is_active BOOLEAN DEFAULT true,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Authentication Flow

1. **Sign Up Process:**
   - Users select their desired role during registration
   - Role is stored in both Supabase auth metadata and custom users table
   - Default role is `client` if not specified

2. **Sign In Process:**
   - Authentication through Supabase Auth
   - Role is fetched from custom users table
   - User permissions are determined based on role

3. **Role-Based Navigation:**
   - Super Admins and Workers: Access to admin dashboard
   - Clients: Access to client dashboard with favorites and stats

### Key Files

#### Core Models
- `lib/core/models/user_role.dart` - UserRole enum and UserPermissions class
- `lib/core/models/app_user.dart` - AppUser model with role information

#### Services
- `lib/core/services/auth_service.dart` - Role-based authentication service
- `lib/core/navigation/app_router.dart` - Role-based navigation routing

#### UI Components
- `lib/users/admin_side/role_based_dashboard.dart` - Admin dashboard for super admins and workers
- `lib/users/client/client_dashboard.dart` - Client-specific dashboard
- `lib/users/admin_side/user_management_screen.dart` - User management for super admins

#### Database
- `lib/supabase/sql/user_roles_schema.sql` - Complete database schema for user roles

## Setup Instructions

### 1. Database Setup

Run the following SQL script in your Supabase SQL Editor:

```sql
-- Run the user_roles_schema.sql file
-- This creates the users table, user_favorites table, and all necessary policies
```

### 2. Update Authentication Screens

The sign-up and sign-in screens have been updated to use the new authentication service:

- Role selection dropdown in sign-up form
- Role-based navigation after authentication
- Enhanced error handling and user feedback

### 3. Dashboard Implementation

The main dashboard now shows different content based on user role:

- **Super Admin Dashboard:** Full statistics, user management, all features
- **Worker Dashboard:** Car management, limited statistics, no user management
- **Client Dashboard:** Personal stats, favorites, recently viewed cars

## Security Features

### Row Level Security (RLS)

The database implements comprehensive RLS policies:

- Users can only read their own profile
- Super admins can manage all users
- Users can only manage their own favorites
- Role-based access to different features

### Permission Checks

All sensitive operations include permission checks:

```dart
if (!permissions.canManageUsers) {
  throw Exception('Only super admins can view all users');
}
```

## Usage Examples

### Creating a Super Admin

```dart
final result = await authService.signUp(
  email: 'admin@example.com',
  password: 'secure_password',
  fullName: 'Super Admin',
  phone: '+1234567890',
  role: UserRole.superAdmin,
);
```

### Checking User Permissions

```dart
if (authService.permissions?.canAddCars == true) {
  // Show add car button
}

if (authService.permissions?.canManageUsers == true) {
  // Show user management features
}
```

### Role-Based UI

```dart
Widget build(BuildContext context) {
  return Column(
    children: [
      if (authService.isSuperAdmin)
        SuperAdminFeatures(),
      if (authService.isWorker)
        WorkerFeatures(),
      if (authService.isClient)
        ClientFeatures(),
    ],
  );
}
```

## Migration from Old System

If you're migrating from the old admin system:

1. **Backup your data** before running the migration
2. **Run the user_roles_schema.sql** script
3. **Update existing admin users** to have `super_admin` role
4. **Test the new authentication flow**
5. **Update any custom code** that relied on the old admin system

## Best Practices

### Security
- Always check permissions before showing sensitive features
- Use RLS policies for database-level security
- Validate user roles on the server side
- Log admin actions for audit trails

### User Experience
- Show clear role indicators in the UI
- Provide helpful error messages for permission denials
- Use consistent role-based navigation
- Maintain user context across the application

### Development
- Use the `UserPermissions` class for permission checks
- Implement role-based feature flags
- Test all user roles thoroughly
- Document role-specific functionality

## Troubleshooting

### Common Issues

1. **User role not updating:**
   - Check if the user exists in the `users` table
   - Verify RLS policies are correctly set
   - Ensure the auth service is properly initialized

2. **Permission denied errors:**
   - Verify user role in the database
   - Check permission logic in the code
   - Ensure RLS policies allow the operation

3. **Dashboard not showing:**
   - Check if user is authenticated
   - Verify role assignment
   - Ensure proper navigation logic

### Debug Commands

```sql
-- Check user roles
SELECT id, email, role FROM users ORDER BY created_at DESC;

-- Check RLS policies
SELECT schemaname, tablename, policyname FROM pg_policies 
WHERE tablename IN ('users', 'user_favorites');

-- Test permission functions
SELECT get_user_role(), is_super_admin(), is_worker_or_admin();
```

## Future Enhancements

Potential improvements to the role system:

1. **Granular Permissions:** More specific permissions within roles
2. **Role Hierarchies:** Sub-roles within main roles
3. **Temporary Permissions:** Time-limited elevated access
4. **Audit Logging:** Detailed logs of role changes and actions
5. **Role Templates:** Predefined role sets for different organizations

## Support

For issues or questions about the user roles system:

1. Check the troubleshooting section above
2. Review the database schema and policies
3. Test with different user roles
4. Verify authentication flow and permissions

The user roles system provides a solid foundation for managing different types of users while maintaining security and providing appropriate access levels for each role.

import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/app_user.dart';
import '../../main/tabs/tab_manager/tab_manger.dart';
import '../../users/auth/sign_in_or_register/sing_in_tab.dart';
import '../../users/auth/sign_in_or_register/sing_up_tab.dart';
import '../../users/auth/admin_auth/admin_login_screen.dart';
import '../../users/auth/admin_auth/admin_register_screen.dart';
import '../../users/auth/client_auth/client_login_screen.dart';
import '../../users/auth/client_auth/client_register_screen.dart';
import '../../users/auth/role_selection_screen.dart';
import '../../splash_screen/intro.dart';

class AppRouter {
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String main = '/main';
  
  // New admin auth routes
  static const String adminLogin = '/adminx';
  static const String adminRegister = '/adminx/register';
  
  // New client auth routes
  static const String clientLogin = '/client_login_register';
  static const String clientRegister = '/client_login_register/register';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
          settings: settings,
        );
      
      case roleSelection:
        return MaterialPageRoute(
          builder: (_) => const RoleSelectionScreen(),
          settings: settings,
        );
      
      case signIn:
        return MaterialPageRoute(
          builder: (_) => const SignInScreen(),
          settings: settings,
        );
      
      case signUp:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
          settings: settings,
        );
      
      case main:
        return MaterialPageRoute(
          builder: (_) => const TabMangerScreen(),
          settings: settings,
        );
      
      // Admin auth routes
      case adminLogin:
        return MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
          settings: settings,
        );
      
      case adminRegister:
        return MaterialPageRoute(
          builder: (_) => const AdminRegisterScreen(),
          settings: settings,
        );
      
      // Client auth routes
      case clientLogin:
        return MaterialPageRoute(
          builder: (_) => const ClientLoginScreen(),
          settings: settings,
        );
      
      case clientRegister:
        return MaterialPageRoute(
          builder: (_) => const ClientRegisterScreen(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => const IntroScreen(),
          settings: settings,
        );
    }
  }

  static void navigateToSignIn(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      signIn,
      (route) => false,
    );
  }

  static void navigateToSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(signUp);
  }

  static void navigateToMain(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      main,
      (route) => false,
    );
  }

  static void navigateToSplash(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      splash,
      (route) => false,
    );
  }

  static void navigateToRoleSelection(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      roleSelection,
      (route) => false,
    );
  }

  // Admin auth navigation methods
  static void navigateToAdminLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      adminLogin,
      (route) => false,
    );
  }

  static void navigateToAdminRegister(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      adminRegister,
      (route) => false,
    );
  }

  // Client auth navigation methods
  static void navigateToClientLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      clientLogin,
      (route) => false,
    );
  }

  static void navigateToClientRegister(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      clientRegister,
      (route) => false,
    );
  }

  // Route handling based on URL paths
  static void handleRoute(BuildContext context, String route) {
    switch (route) {
      case adminLogin:
        navigateToAdminLogin(context);
        break;
      case adminRegister:
        navigateToAdminRegister(context);
        break;
      case clientLogin:
        navigateToClientLogin(context);
        break;
      case clientRegister:
        navigateToClientRegister(context);
        break;
      case roleSelection:
        navigateToRoleSelection(context);
        break;
      case splash:
      default:
        navigateToSplash(context);
        break;
    }
  }
}

class RoleBasedNavigator {
  static void navigateBasedOnRole(BuildContext context, AppUser user) {
    switch (user.role) {
      case UserRole.superAdmin:
      case UserRole.worker:
        // Admin users go to dashboard
        AppRouter.navigateToMain(context);
        break;
      case UserRole.client:
        // Client users go to main app (cars view)
        AppRouter.navigateToMain(context);
        break;
    }
  }

  static List<NavigationItem> getNavigationItems(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return [
          NavigationItem(
            title: 'Dashboard',
            icon: Icons.dashboard,
            route: '/dashboard',
          ),
          NavigationItem(
            title: 'Cars',
            icon: Icons.directions_car,
            route: '/cars',
          ),
          NavigationItem(
            title: 'Users',
            icon: Icons.people,
            route: '/users',
          ),
          NavigationItem(
            title: 'Reports',
            icon: Icons.analytics,
            route: '/reports',
          ),
          NavigationItem(
            title: 'Settings',
            icon: Icons.settings,
            route: '/settings',
          ),
        ];
      
      case UserRole.worker:
        return [
          NavigationItem(
            title: 'Dashboard',
            icon: Icons.dashboard,
            route: '/dashboard',
          ),
          NavigationItem(
            title: 'Cars',
            icon: Icons.directions_car,
            route: '/cars',
          ),
          NavigationItem(
            title: 'Favorites',
            icon: Icons.favorite,
            route: '/favorites',
          ),
          NavigationItem(
            title: 'Account',
            icon: Icons.person,
            route: '/account',
          ),
        ];
      
      case UserRole.client:
        return [
          NavigationItem(
            title: 'Cars',
            icon: Icons.directions_car,
            route: '/cars',
          ),
          NavigationItem(
            title: 'Favorites',
            icon: Icons.favorite,
            route: '/favorites',
          ),
          NavigationItem(
            title: 'Community',
            icon: Icons.group,
            route: '/community',
          ),
          NavigationItem(
            title: 'Account',
            icon: Icons.person,
            route: '/account',
          ),
        ];
    }
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final String route;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
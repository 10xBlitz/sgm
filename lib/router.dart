import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/dashboard.tab.dart';
import 'package:sgm/mainTabs/projects/projects.tab.dart';
import 'package:sgm/mainTabs/projects/subTabs/projects.list.sub_tab.dart';
import 'package:sgm/screens/auth/awaiting_approval.screen.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/screens/auth/user_profile.update.screen.dart';
import 'package:sgm/screens/main.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/global_manager.service.dart';

// Define routes that don't require authentication
final List<String> publicRoutes = [LoginScreen.routeName];

final Map<String, dynamic> defaultSubTab = {
  ProjectsTab.tabTitle: ProjectsListSubTab.title,
};

final router = GoRouter(
  initialLocation: MainScreen.routeName,

  // This redirect function runs on every navigation attempt
  redirect: (BuildContext context, GoRouterState state) async {
    debugPrint("Redirecting... ${state.fullPath}");
    final globalManager = GlobalManagerService();
    final authService = AuthService();
    globalManager.setGlobalContextIfNull(context);

    // Check if the user is logged in
    final bool isLoggedIn = authService.isLoggedIn;

    if (isLoggedIn && authService.currentUserProfile == null) {
      final isLoaded = await authService.loadProfile();
      if (isLoaded == false) {
        await authService.createProfile(
          name: "",
          email: authService.currentUser!.email!,
          phone: "",
        );
        return AwaitingApprovalScreen.routeName;
      }
      if (isLoaded == true) {
        if (!authService.isApproved || !authService.isConfirmedEmail) {
          return AwaitingApprovalScreen.routeName;
        }
      }
      if (isLoaded == null) {
        if (!context.mounted) return LoginScreen.routeName; // Redirect to login
        globalManager.showSnackbarError(
          context,
          "Profile loading failed. Something went wrong.",
        );
        return LoginScreen.routeName; // Redirect to login
      }
    }

    // If the user is NOT logged in and trying to access a protected route
    if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
      return LoginScreen.routeName; // Redirect to login
    }

    // If the user IS logged in and going to login page, send them to main route
    if (isLoggedIn && state.matchedLocation == LoginScreen.routeName) {
      return MainScreen.routeName;
    }

    // No redirection needed
    return null;
  },

  routes: <RouteBase>[
    GoRoute(
      path: MainScreen.routeName,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final extraData =
            state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : null;
        return CustomTransitionPage(
          key: state.pageKey,
          child: MainScreen(
            currentTab: extraData?['currentTab'] ?? DashboardTab.tabTitle,
            subTab:
                extraData?['subTab'] ??
                defaultSubTab[extraData?['currentTab'] ??
                    DashboardTab.tabTitle],
            projectId: extraData?['project'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: LoginScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: AwaitingApprovalScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const AwaitingApprovalScreen();
      },
    ),
    GoRoute(
      path: UserProfileUpdateScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const UserProfileUpdateScreen();
      },
    ),
  ],
);

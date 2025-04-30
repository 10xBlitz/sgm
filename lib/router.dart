import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/screens/main.screen.dart';
import 'package:sgm/services/auth_service.dart';

// Define routes that don't require authentication
final List<String> publicRoutes = [LoginScreen.routeName];

final router = GoRouter(
  initialLocation: MainScreen.routeName,

  // This redirect function runs on every navigation attempt
  redirect: (BuildContext context, GoRouterState state) {
    // Check if the user is logged in
    final bool isLoggedIn = authService.isLoggedIn;

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

  // Define all application routes
  routes: <RouteBase>[
    GoRoute(
      path: MainScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const MainScreen();
      },
    ),

    // Add login route
    GoRoute(
      path: LoginScreen.routeName,
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
  ],
);

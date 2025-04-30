import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/services/auth_service.dart';

class MainScreen extends StatelessWidget {
  static const routeName = "/";
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          spacing: 16,
          children: [
            Image.asset('assets/images/logo.png', height: 45, width: 45),
            Text(
              "Seoul Guide Medical",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
                fontFamily: 'Noto Sans KR',
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                context.go(LoginScreen.routeName);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(child: Text("Welcome to Seoul Guide Medical")),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/screens/auth/user_profile.update.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/widgets/user_avatar.dart';

class MainScreen extends StatefulWidget {
  static const routeName = "/";
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    // Create a global instance for easy access
    final authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          spacing: 16,
          children: [
            Image.asset('assets/images/logo.png', height: 45, width: 45),
            // Expanded(
            //   child: Text(
            //     "Seoul Guide Medical",
            //     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            //       color: Theme.of(context).colorScheme.onSecondaryContainer,
            //       fontWeight: FontWeight.w900,
            //     ),
            //   ),
            // ),
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
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                tooltip: 'Settings',
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(),
        width: 260,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  // Container overlap
                  Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.primary,
                    child: SafeArea(
                      top: true,
                      bottom: false,
                      // child: SizedBox(height: 50),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                            bottom: 8,
                            top: 14,
                          ),
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                height: 40,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            12.0,
                            16.0,
                            0.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              UserAvatar(
                                imageUrl:
                                    authService
                                        .currentUserProfile
                                        ?.profileImage ??
                                    '',
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      authService.currentUserProfile?.name ?? 'No Name',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      authService.currentUserProfile?.email ?? 'No Email',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      authService.currentUserProfile?.phoneNumber ?? 'No Phone',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w900,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    // Update Profile Button
                    FilledButton.icon(
                      onPressed: () async {
                        await showGeneralDialog(
                          context: context,
                          pageBuilder: (context, a1, a2) {
                            return UserProfileUpdateScreen();
                          },
                        );
                        if (!mounted) return;
                        setState(() {});
                      },
                      icon: Icon(Icons.edit),
                      label: Text("UPDATE PROFILE"),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Center(child: Text("Welcome to Seoul Guide Medical")),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/widgets/user_avatar.dart';

class UserProfileUpdateScreen extends StatelessWidget {
  static const routeName = '/user-profile-update';
  const UserProfileUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            InkWell(
              onTap: () {},
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: UserAvatar(
                              imageUrl:
                                  AuthService()
                                      .currentUserProfile
                                      ?.profileImage,
                              radius: 80,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHigh.withAlpha(200),
                              child: Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Outlined Contaier
                      FilledButton(
                        onPressed: () {},
                        child: Text("Update Profile Image"),
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

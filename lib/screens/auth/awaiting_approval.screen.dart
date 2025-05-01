import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/screens/auth/user_profile.update.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/global_manager.service.dart';

class AwaitingApprovalScreen extends StatefulWidget {
  static const routeName = "/awaiting-approval";
  const AwaitingApprovalScreen({super.key});

  @override
  State<AwaitingApprovalScreen> createState() => _AwaitingApprovalScreenState();
}

class _AwaitingApprovalScreenState extends State<AwaitingApprovalScreen> {
  final globalManager = GlobalManagerService();
  final authService = AuthService();
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await authService.loadProfile();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Approval and Confirmation',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      backgroundColor: theme.colorScheme.surfaceContainer,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 700, maxHeight: 800),
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 64, 16.0, 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!authService.isApproved) ...[
                    Icon(Icons.hourglass_top),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Waiting for account approval',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Please contact Admin for Approval and User Role',
                        style: theme.textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 16),
                  ],
                  if (!authService.isConfirmedEmail) ...[
                    Icon(Icons.email),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Waiting for Email Confirmation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 4),
                    Center(
                      child: Text(
                        'Please verify your email',
                        style: theme.textTheme.labelSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12),
                    FilledButton(
                      onPressed: () async {
                        final success =
                            await AuthService().resendEmailConfirmation();
                        if (!context.mounted) return;
                        if (success) {
                          globalManager.showSnackbar(
                            context,
                            "Confirmation code resent successfully.",
                          );
                          debugPrint('Confirmation code resent successfully.');
                          return;
                        }
                        globalManager.showSnackbarError(
                          context,
                          "Failed to resend confirmation code.",
                        );
                        debugPrint('Failed to resend confirmation code.');
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Resend Code'),
                          SizedBox(width: 8),
                          Icon(Icons.email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 16),
                  ],
                  Center(
                    child: Text(
                      'For now you can update your profile',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 12),
                  FilledButton(
                    onPressed: () async {
                      // show the user public profile as full screen dialog
                      showGeneralDialog(
                        context: context,
                        pageBuilder: (context, a1, a2) {
                          return UserProfileUpdateScreen();
                        },
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Update Profile'),
                        SizedBox(width: 8),
                        Icon(Icons.person),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 16),

                  FilledButton(
                    onPressed: () async {
                      await AuthService().logout();
                      if (!context.mounted) return;
                      context.go(LoginScreen.routeName);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Logout'),
                        SizedBox(width: 8),
                        Icon(Icons.logout),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

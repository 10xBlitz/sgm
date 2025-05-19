import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/announcements.tab.dart';
import 'package:sgm/mainTabs/chat.tab.dart';
import 'package:sgm/mainTabs/clinics/clinics.tab.dart';
import 'package:sgm/mainTabs/dashboard.tab.dart';
import 'package:sgm/mainTabs/forms.tab.dart';
import 'package:sgm/mainTabs/my_task.tab.dart';
import 'package:sgm/mainTabs/procedures.tab.dart';
import 'package:sgm/mainTabs/projects/projects.tab.dart';
import 'package:sgm/mainTabs/user_management.tab.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/screens/auth/user_profile.update.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/widgets/user_avatar.dart';

import 'button/side_nav_button.dart';

class SideNav extends StatefulWidget {
  const SideNav({super.key, required this.selectedTab, required this.onTapTab});

  final String selectedTab;
  final Future<void> Function(String targetTab) onTapTab;

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              // Container overlap
              Container(
                width: double.infinity,
                color: theme.colorScheme.primary,
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
                      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          UserAvatar(
                            imageUrl:
                                authService.currentUserProfile?.profileImage ??
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
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
          SizedBox(height: 32),
          Divider(height: 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: DashboardTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: ChatTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: MyTaskTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: ClinicsTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: ProjectsTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: ProceduresTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: FormsTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: UserManagementTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
              SideNavButton(
                onTapNav: widget.onTapTab,
                title: AnnouncementsTab.tabTitle,
                selectedNav: widget.selectedTab,
              ),
            ],
          ),
          SizedBox(height: 24),
          // Logout
          FilledButton.icon(
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                context.go(LoginScreen.routeName);
              }
            },
            icon: Icon(Icons.logout),
            label: Text("LOGOUT"),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

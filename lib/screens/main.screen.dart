import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/announcements.tab.dart';
import 'package:sgm/mainTabs/chat.tab.dart';
import 'package:sgm/mainTabs/clinics.tab.dart';
import 'package:sgm/mainTabs/dashboard.tab.dart';
import 'package:sgm/mainTabs/forms.tab.dart';
import 'package:sgm/mainTabs/my_task.tab.dart';
import 'package:sgm/mainTabs/procedures.tab.dart';
import 'package:sgm/mainTabs/projects.tab.dart';
import 'package:sgm/mainTabs/user_management.tab.dart';
import 'package:sgm/screens/auth/login.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/widgets/side_nav.dart';

class MainScreen extends StatefulWidget {
  static const routeName = "/";
  const MainScreen({super.key, this.currentTab = DashboardTab.tabTitle});

  final String currentTab;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String selectedTab = DashboardTab.tabTitle;

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
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 45,
                  width: 45,
                ),
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
        child: SideNav(
          selectedTab: selectedTab,
          onTapTab: (targetTab) {
            setState(() {
              selectedTab = targetTab;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
      // Update with better body
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (selectedTab) {
      case DashboardTab.tabTitle:
        return DashboardTab();
      case ChatTab.tabTitle:
        return ChatTab();
      case MyTaskTab.tabTitle:
        return MyTaskTab();
      case ClinicsTab.tabTitle:
        return ClinicsTab();
      case ProjectsTab.tabTitle:
        return ProjectsTab();
      case ProceduresTab.tabTitle:
        return ProceduresTab();
      case FormsTab.tabTitle:
        return FormsTab();
      case UserManagementTab.tabTitle:
        return UserManagementTab();
      case AnnouncementsTab.tabTitle:
        return AnnouncementsTab();
      default:
        return const Center(
          child: Text('Default Screen', style: TextStyle(color: Colors.grey)),
        );
    }
  }
}

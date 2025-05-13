import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/announcements.tab.dart';
import 'package:sgm/mainTabs/chat.tab.dart';
import 'package:sgm/mainTabs/clinics.tab.dart';
import 'package:sgm/mainTabs/dashboard.tab.dart';
import 'package:sgm/mainTabs/forms.tab.dart';
import 'package:sgm/mainTabs/my_task.tab.dart';
import 'package:sgm/mainTabs/procedures.tab.dart';
import 'package:sgm/mainTabs/projects/projects.tab.dart';
import 'package:sgm/mainTabs/user_management.tab.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/widgets/side_nav.dart';

import '../widgets/task/dialog/add_task_dialog.dart';

class MainScreen extends StatefulWidget {
  static const routeName = "/";
  const MainScreen({
    super.key,
    this.currentTab = DashboardTab.tabTitle,
    this.subTab,
    this.projectId,
  });

  final String currentTab;
  final String? subTab;

  /// in route, it is named as project
  final String? projectId;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String get selectedTab => widget.currentTab;
  String? get selectedSubTab => widget.subTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Row(
          spacing: 16,
          children: [
            InkWell(
              onTap: () async {
                Navigator.of(context).pop();
                await context.push(MainScreen.routeName);
              },
              child: Container(
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
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (widget.projectId != null &&
                          widget.currentTab == ProjectsTab.tabTitle) ...[
                        Text(
                          ProjectService()
                                  .getFromCache(widget.projectId!)
                                  ?.title ??
                              'No Title',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('•', style: theme.textTheme.titleMedium),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          widget.currentTab,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (widget.subTab != null)
                    Text(
                      widget.subTab ?? 'No Sub Tab',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.secondaryContainer,
        actions: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isProjectDetailTabs()) {
            await _handleAddTask(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      endDrawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(),
        width: 260,
        child: SideNav(
          selectedTab: selectedTab,
          onTapTab: (targetTab) async {
            Navigator.of(context).pop();
            await context.push(
              MainScreen.routeName,
              extra: {'currentTab': targetTab},
            );
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Future<void> _handleAddTask(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          AddTaskDialog(
            projectId: '${widget.projectId}',
            projectTitle: '${ ProjectService()
                .getFromCache(widget.projectId!)
                ?.title }',
            onAddTask: (args) {
              debugPrint('Task added: ${args.title}, Assignee: ${args.assigneeId} ${
                  args.assigneeId} -STTID ${args.statusId}');
              final assigneeId = args.assigneeId;
              final statusId = args.statusId;
              final time = args.dueDate;
              final title = args.title;
              TaskService().createTask(
                title: "$title: Huu test",
                project: widget.projectId,
                dateDue: time,
                assignee: assigneeId,
                status: statusId,
              ).then(
                (value) {
                  debugPrint("done");
                  ProjectService().getFromId(widget.projectId!);
                },
              );
            },
          ),
    );
  }

  Widget _buildBody() {
    return switch (selectedTab) {
      DashboardTab.tabTitle => DashboardTab(),
      ChatTab.tabTitle => ChatTab(),
      MyTaskTab.tabTitle => MyTaskTab(),
      ClinicsTab.tabTitle => ClinicsTab(),
      ProjectsTab.tabTitle => ProjectsTab(projectId: widget.projectId),
      ProceduresTab.tabTitle => ProceduresTab(),
      FormsTab.tabTitle => FormsTab(),
      UserManagementTab.tabTitle => UserManagementTab(),
      AnnouncementsTab.tabTitle => AnnouncementsTab(),
      _ => const Center(
        child: Text('Default Screen', style: TextStyle(color: Colors.grey)),
      ),
    };
  }

  bool isProjectDetailTabs(){
    return widget.projectId != null && widget.currentTab == ProjectsTab.tabTitle;
  }
}

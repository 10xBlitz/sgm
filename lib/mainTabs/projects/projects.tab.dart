import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/projects/subTabs/projects.list.all.tab.dart';
import 'package:sgm/mainTabs/projects/subTabs/projects.list.sub_tab.dart';
import 'package:sgm/screens/main.screen.dart';

class ProjectsTab extends StatefulWidget {
  static const String tabTitle = 'Projects';
  const ProjectsTab({super.key, this.projectId, this.subTab, this.subTabKey});
  final String? projectId;
  final String? subTab;
  final Key? subTabKey;

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  String get subTab => widget.subTab ?? ProjectsListSubTab.title;

  @override
  Widget build(BuildContext context) {
    if (widget.projectId == null) {
      return ProjectsListAllTab(
        onTapProject: (project) async {
          context.pushReplacement(
            MainScreen.routeName,
            extra: {
              'project': project.id,
              'currentTab': ProjectsTab.tabTitle,
              'subTab': widget.subTab,
            },
          );
        },
      );
    }

    return switch (subTab) {
      ProjectsListSubTab.title => ProjectsListSubTab(
        key: widget.subTabKey,
        projectId: widget.projectId!,
      ),
      _ => const Center(
        child: Text('Default Screen', style: TextStyle(color: Colors.grey)),
      ),
    };
  }
}

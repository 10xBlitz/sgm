import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/announcements.tab.dart';
import 'package:sgm/mainTabs/chat/chat.tab.dart';
import 'package:sgm/mainTabs/clinics/clinics.tab.dart';
import 'package:sgm/mainTabs/dashboard.tab.dart';
import 'package:sgm/mainTabs/forms.tab.dart';
import 'package:sgm/mainTabs/my_task.tab.dart';
import 'package:sgm/mainTabs/procedures.tab.dart';
import 'package:sgm/mainTabs/projects/projects.tab.dart';
import 'package:sgm/mainTabs/projects/subTabs/projects.list.sub_tab.dart';
import 'package:sgm/mainTabs/user_management.tab.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/services/form.service.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/form_question.service.dart';
import 'package:sgm/utils/loading_utils.dart';
import 'package:sgm/widgets/form/dialog/add_form_dialog.dart';
import 'package:sgm/widgets/side_nav.dart';

import '../mainTabs/clinics/subTabs/clinics.list.sub_tab.dart';
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
  final _projectsListSubTabKey = GlobalKey();
  final _clinicsListSubTabKey = GlobalKey();
  final _key = GlobalKey<ExpandableFabState>();

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
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: _buildFab(context),
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

  Widget _buildFab(BuildContext context) {
    if (!_isProjectDetailTabs()) return const SizedBox.shrink();
    return ExpandableFab(
      key: _key,
      distance: 70,
      type: ExpandableFabType.up,
      children: [
        Row(
          children: [
            Text('Add Task'),
            SizedBox(width: 8),
            FloatingActionButton.small(
              tooltip: 'Add Task',
              heroTag: null,
              child: const Icon(Icons.add_task_outlined),
              onPressed: () {
                _handleAddTask(context);
                _closeFab();
              },
            ),
          ],
        ),
        Row(
          children: [
            Text('Add Form'),
            SizedBox(width: 8),
            FloatingActionButton.small(
              tooltip: 'Add Form',
              heroTag: null,
              child: const Icon(Icons.menu_book_outlined),
              onPressed: () {
                _closeFab();
                _handleAddForm(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  void _closeFab() {
    // close fab
    final state = _key.currentState;
    if (state != null) {
      debugPrint('isOpen:${state.isOpen}');
      state.toggle();
    }
  }

  Future<void> _handleAddTask(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AddTaskDialog(
            projectId: '${widget.projectId}',
            projectTitle:
                '${ProjectService().getFromCache(widget.projectId!)?.title}',
            onAddTask: (args) async {
              debugPrint(
                'Task added: ${args.title}, Assignee: ${args.assigneeId} ${args.assigneeId} -STTID ${args.statusId}',
              );
              final assigneeId = args.assigneeId;
              final statusId = args.statusId;
              final time = args.dueDate;
              final title = args.title;
              final description = args.description;
              await TaskService()
                  .createTask(
                    title: title,
                    project: widget.projectId,
                    dateDue: time,
                    assignee: assigneeId,
                    status: statusId,
                    description: description,
                  )
                  .then((value) async {
                    // hide loading
                    debugPrint("done");
                    await ProjectService().getFromId(
                      widget.projectId!,
                      cached: true,
                    );
                    if (mounted) {
                      setState(() {
                        // Force rebuild of ProjectsListSubTab by recreating its key
                        if (_projectsListSubTabKey.currentState != null) {
                          (_projectsListSubTabKey.currentState
                                  as ProjectsListSubTabState?)
                              ?.reloadAPI();
                        }
                        if (_clinicsListSubTabKey.currentState != null) {
                          (_clinicsListSubTabKey.currentState
                                  as ClinicsListSubTabState?)
                              ?.reloadAPI();
                        }
                        // check the current tab
                      });
                    }
                  })
                  .catchError((error) {
                    // hide loading
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $error')));
                    }
                  });
            },
          ),
    );
  }

  // handle add form
  Future<void> _handleAddForm(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AddFormDialog(
            projectId: '${widget.projectId}',
            onSubmit: (formTitle, formName, formDescription, questions) async {
              debugPrint(
                'Form added: $formName, Description: $formDescription',
              );
              LoadingUtils.showLoading();
              try {
                var currentUserID = AuthService().currentUser?.id;

                // Create the form
                var newForm = await FormService().createForm(
                  linkedProject: widget.projectId,
                  name: formName,
                  description: formDescription,
                  createdBy: currentUserID,
                );

                debugPrint('Form created with ID: ${newForm?.id}');

                // Add questions to the form
                await Future.forEach(questions, (QuestionData question) async {
                  await FormQuestionService().createQuestion(
                    formId: '${newForm?.id}',
                    type: question.type,
                    question: question.title,
                    isRequired: question.required,
                    checkboxOptions: question.options ?? [],
                  );
                });

                LoadingUtils.dismissLoading();
                LoadingUtils.showSuccess('Form created successfully!');

                if (mounted) {
                  setState(() {
                    // Reload both API and forms
                    if (_clinicsListSubTabKey.currentState != null) {
                      (_clinicsListSubTabKey.currentState
                              as ClinicsListSubTabState?)
                          ?.reloadAPI();
                      (_clinicsListSubTabKey.currentState
                              as ClinicsListSubTabState?)
                          ?.reloadForms();
                    }
                    if (_projectsListSubTabKey.currentState != null) {
                      (_projectsListSubTabKey.currentState
                              as ProjectsListSubTabState?)
                          ?.reloadAPI();
                      (_projectsListSubTabKey.currentState
                              as ProjectsListSubTabState?)
                          ?.reloadForms();
                    }
                  });
                }
              } catch (e) {
                LoadingUtils.dismissLoading();
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
    );
  }

  Widget _buildBody() {
    return switch (selectedTab) {
      DashboardTab.tabTitle => DashboardTab(),
      ChatTab.tabTitle => ChatTab(),
      MyTaskTab.tabTitle => MyTaskTab(),
      ClinicsTab.tabTitle => ClinicsTab(
        projectId: widget.projectId,
        subTab: widget.subTab,
        subTabKey: _clinicsListSubTabKey,
      ),
      ProjectsTab.tabTitle => ProjectsTab(
        projectId: widget.projectId,
        subTabKey: _projectsListSubTabKey,
      ),
      ProceduresTab.tabTitle => ProceduresTab(
        subTab: widget.subTab,
        // add add / edit tabs here
      ),
      FormsTab.tabTitle => FormsTab(),
      UserManagementTab.tabTitle => UserManagementTab(),
      AnnouncementsTab.tabTitle => AnnouncementsTab(),
      _ => const Center(
        child: Text('Default Screen', style: TextStyle(color: Colors.grey)),
      ),
    };
  }

  bool _isProjectDetailTabs() {
    return widget.projectId != null &&
            widget.currentTab == ProjectsTab.tabTitle ||
        (widget.projectId != null && widget.currentTab == ClinicsTab.tabTitle);
  }
}

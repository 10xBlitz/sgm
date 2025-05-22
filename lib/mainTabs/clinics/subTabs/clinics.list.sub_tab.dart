import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/widgets/form_list_view/form_list_view.dart';
import 'package:sgm/widgets/task_list_view/task_list_view.dart';

abstract class ClinicsListSubTabState extends State<ClinicsListSubTab> {
  Future<void> reloadAPI();
  Future<void> reloadForms();
}

class ClinicsListSubTab extends StatefulWidget {
  static const String title = 'List';
  const ClinicsListSubTab({super.key, required this.projectId});
  final String projectId;

  @override
  State<ClinicsListSubTab> createState() => _ClinicsListSubTabState();
}

class _ClinicsListSubTabState extends ClinicsListSubTabState {
  ProjectRow? project;
  final _taskListKey = GlobalKey<TaskListViewState>();
  final _formListKey = GlobalKey<FormListViewState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (project != null) return;
      project = await ProjectService().getFromId(widget.projectId);
      setState(() {});
    });
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Clinic details header
        if (project != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: theme.colorScheme.surfaceContainerHigh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project!.title ?? 'Untitled Clinic',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (project!.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    project!.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        project!.status ?? 'No Status',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('yyyy-MM-dd').format(project!.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Combined scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Forms section
                FormListView(
                  key: _formListKey,
                  projectId: widget.projectId,
                  onFormUpdated: reloadForms,
                ),

                // List section header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: const Text("List by Creation Date"),
                ),
                const Divider(height: 1),

                // Tasks section
                TaskListView(
                  key: _taskListKey,
                  projectId: widget.projectId,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Future<void> reloadAPI() async {
    debugPrint("Reloading API for clinics");
    if (!mounted) return;

    try {
      final value = await ProjectService().getFromId(widget.projectId);
      if (!mounted) return;

      setState(() {
        project = value;
      });

      // Refresh the task list
      await reloadTasks();
    } catch (e) {
      debugPrint("Error reloading API: $e");
    }
  }

  Future<void> reloadTasks() async {
    final taskListState = _taskListKey.currentState;
    if (taskListState != null) {
      await taskListState.refresh();
    }
  }

  @override
  Future<void> reloadForms() async {
    if (!mounted) return;
    final formListState = _formListKey.currentState;
    if (formListState != null) {
      await formListState.reload();
    }
  }
}

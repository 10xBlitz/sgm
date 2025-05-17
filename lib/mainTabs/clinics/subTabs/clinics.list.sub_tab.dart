import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/form.row.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/services/form.service.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/widgets/paginated_data.dart';
import 'package:sgm/widgets/task/taskview/task.view.dart';

class ClinicsListSubTab extends StatefulWidget {
  static const String title = 'List';
  const ClinicsListSubTab({super.key, required this.projectId});
  final String projectId;

  @override
  State<ClinicsListSubTab> createState() => _ClinicsListSubTabState();
}

class _ClinicsListSubTabState extends State<ClinicsListSubTab> {
  ProjectRow? project;
  List<FormRow> _forms = [];
  bool _isLoadingForms = true;
  final _paginatedDataKey = GlobalKey<PaginatedDataState>();

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() {
      _isLoadingForms = true;
    });

    try {
      final forms = await FormService().getFormsByProject(widget.projectId);
      setState(() {
        _forms = forms;
        _isLoadingForms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingForms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading forms: $e')),
        );
      }
    }
  }

  // Column widths
  final double _titleWidth = 200.0;
  final double _statusWidth = 120.0;
  final double _dueDateWidth = 120.0;
  final double _assigneeWidth = 150.0;
  final double _birthdayWidth = 120.0;
  final double _nationalityWidth = 120.0;
  final double _phoneWidth = 120.0;

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
                if (_isLoadingForms)
                  const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()))
                else if (_forms.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('No forms for this clinic.', style: theme.textTheme.bodyMedium),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text('Forms', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      ..._forms.map((form) => _formItem(theme, form)),
                      const Divider(height: 1),
                    ],
                  ),

                // List section header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: const Text("List by Creation Date"),
                ),
                const Divider(height: 1),

                // List content
                PaginatedData(
                  key: _paginatedDataKey,
                  builder: (context, data, isLoading) {
                    // Calculate total table width from column widths
                    final tableWidth = _titleWidth + _statusWidth + _dueDateWidth +
                        _assigneeWidth + _birthdayWidth + _nationalityWidth + _phoneWidth;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildHeaderCell("Title", width: _titleWidth),
                                  _buildHeaderCell("Status", width: _statusWidth),
                                  _buildHeaderCell("Due Date", width: _dueDateWidth),
                                  _buildHeaderCell("Assignee", width: _assigneeWidth),
                                  _buildHeaderCell("Birthday", width: _birthdayWidth),
                                  _buildHeaderCell("Nationality", width: _nationalityWidth),
                                  _buildHeaderCell("Phone", width: _phoneWidth),
                                ],
                              ),
                            ),

                            // Data rows
                            ...List.generate(data.length, (index) {
                              final item = data[index] as TaskRow;
                              return InkWell(
                                onTap: () {
                                  showGeneralDialog(
                                    context: context,
                                    pageBuilder: (context, a1, a2) {
                                      return TaskView(task: item);
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildDataCell(
                                        item.title ?? 'Untitled Task',
                                        width: _titleWidth,
                                      ),
                                      _buildStatusCell(item, width: _statusWidth),
                                      _buildDataCell(
                                        item.dateDue != null
                                            ? DateFormat('yyyy-MM-dd').format(item.dateDue!)
                                            : 'No due date',
                                        width: _dueDateWidth,
                                      ),
                                      _buildAssigneeCell(item, width: _assigneeWidth),
                                      _buildDataCell(
                                        item.customerBirthday != null
                                            ? DateFormat('yyyy-MM-dd').format(item.customerBirthday!)
                                            : 'No birthday',
                                        width: _birthdayWidth,
                                      ),
                                      _buildDataCell(
                                        item.customerNationality ?? 'No nationality',
                                        width: _nationalityWidth,
                                      ),
                                      _buildDataCell(
                                        item.customerPhone ?? 'No phone',
                                        width: _phoneWidth,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                  getPage: (int page, int pageSize) async {
                    return await TaskService().getPage(
                      widget.projectId,
                      page,
                      pageSize,
                    );
                  },
                  getCount: () async {
                    return await TaskService().getCount(widget.projectId);
                  },
                  initialPage: 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDataCell(
      String text, {
        required double width,
        TextStyle? style,
      }) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildStatusCell(TaskRow row, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: FutureBuilder<List<ProjectTaskStatusRow>>(
        future: ProjectTaskStatusService().getStatusByProjectID(widget.projectId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final statuses = snapshot.data ?? [];
          if(statuses.isEmpty) {
            return const Text('No Statuses');
          }else{
            final status = statuses.firstWhere(
                  (s) => s.id == row.status,
              orElse: () => statuses.firstWhere(
                    (s) => s.forNullStatus,
                orElse: () => statuses.first,
              ),
            );
            return Text(status.status ?? 'No Status');
          }
        },
      ),
    );
  }

  Widget _buildAssigneeCell(TaskRow row, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: FutureBuilder<List<UserRow>>(
        future: UserService().getAllUsers(activated: false, isBanned: false),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          final user = users.firstWhere(
            (u) => u.id == row.assignee,
            orElse: () => users.first,
          );
          return Text(user.name ?? 'No Assignee');
        },
      ),
    );
  }

  Widget _formItem(ThemeData theme, FormRow form) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(form.name ?? 'Untitled Form', style: theme.textTheme.titleMedium),
                Text('${form.description}'),]
          ),
        ],
      ),
    );
  }
}

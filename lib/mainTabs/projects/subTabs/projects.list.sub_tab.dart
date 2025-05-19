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
import 'package:sgm/widgets/task/dialog/update_task_status_dialog.dart';

class ProjectsListSubTab extends StatefulWidget {
  static const String title = 'List';
  const ProjectsListSubTab({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectsListSubTab> createState() => _ProjectsListSubTabState();
}

abstract class ProjectsListSubTabState extends State<ProjectsListSubTab> {
  Future<void> reloadAPI();
  Future<void> reloadForms();
}

class _ProjectsListSubTabState extends ProjectsListSubTabState {
  ProjectRow? project;
  final _paginatedDataKey = GlobalKey<PaginatedDataState>();
  final _userService = UserService();
  final _statusService = ProjectTaskStatusService();
  final _formService = FormService();
  Map<String, UserRow> _assigneeCache = {};
  Map<String, ProjectTaskStatusRow> _statusCache = {};
  List<FormRow> _forms = [];
  bool _isLoadingForms = true;

  // Define consistent column widths as constants
  static const double _titleWidth = 220.0;
  static const double _statusWidth = 160.0;
  static const double _dueDateWidth = 180.0;
  static const double _assigneeWidth = 180.0;
  static const double _birthdayWidth = 180.0;
  static const double _nationalityWidth = 180.0;
  static const double _phoneWidth = 180.0;

  @override
  void initState() {
    super.initState();
    _loadCaches();
    _loadForms();
  }

  Future<void> _loadCaches() async {
    if (!mounted) return;

    try {
      // Load all users for assignee mapping
      final users = await _userService.getAllUsers(
        activated: false,
        isBanned: false,
      );
      _assigneeCache = {for (var user in users) user.id: user};

      // Load all statuses for the project
      final statuses = await _statusService.getStatusByProjectID(
        widget.projectId,
      );
      _statusCache = {for (var status in statuses) status.id: status};

      // map current project status to the status cache
      if (project != null) {
        project = project!.copyWith(
          status: _statusCache[project!.status]?.status,
        );
      }

      if (mounted) {}
    } catch (e) {
      debugPrint('Error loading caches: $e');
      if (mounted) {}
    }
  }

  Future<void> _loadForms() async {
    if (!mounted) return;
    try {
      final forms = await _formService.getFormsByProject(widget.projectId);
      if (mounted) {
        setState(() {
          _forms = forms;
          _isLoadingForms = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading forms: $e');
      if (mounted) {
        setState(() {
          _isLoadingForms = false;
        });
      }
    }
  }

  @override
  Future<void> reloadAPI() async {
    debugPrint("Reloading API");
    if (!mounted) return;

    try {
      final value = await ProjectService().getFromId(widget.projectId);
      if (!mounted) return;

      setState(() {
        project = value;
      });

      // Refresh the task list
      final paginatedState = _paginatedDataKey.currentState;
      if (paginatedState != null) {
        await paginatedState.refresh();
      }
    } catch (e) {
      debugPrint("Error reloading API: $e");
    }
  }

  @override
  Future<void> reloadForms() async {
    if (!mounted) return;
    setState(() => _isLoadingForms = true);
    await _loadForms();
  }

  String _getAssigneeName(String? assigneeId) {
    if (assigneeId == null) return '';
    return _assigneeCache[assigneeId]?.name ?? 'Unknown';
  }

  String _getStatusName(TaskRow? row) {
    if (row == null) return '';
    return _statusCache[row.status]?.status ?? row.status ?? 'Unknown';
  }

  // Get status color based on status ID
  Color _getStatusColor(String? statusId) {
    return Colors.green;
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
        // Combined scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Forms section
                if (_isLoadingForms)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_forms.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'No forms for this project.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Text(
                          'Forms',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                    final tableWidth =
                        _titleWidth +
                        _statusWidth +
                        _dueDateWidth +
                        _assigneeWidth +
                        _birthdayWidth +
                        _nationalityWidth +
                        _phoneWidth;

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
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                border: Border(
                                  bottom: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildHeaderCell("Title", width: _titleWidth),
                                  _buildHeaderCell(
                                    "Status",
                                    width: _statusWidth,
                                  ),
                                  _buildHeaderCell(
                                    "Due Date",
                                    width: _dueDateWidth,
                                  ),
                                  _buildHeaderCell(
                                    "Assignee",
                                    width: _assigneeWidth,
                                  ),
                                  _buildHeaderCell(
                                    "Birthday",
                                    width: _birthdayWidth,
                                  ),
                                  _buildHeaderCell(
                                    "Nationality",
                                    width: _nationalityWidth,
                                  ),
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
                                        item.title ?? "",
                                        width: _titleWidth,
                                      ),
                                      _buildStatusCell(
                                        item,
                                        width: _statusWidth,
                                      ),
                                      _buildDataCell(
                                        item.dateDue != null
                                            ? _formatDateTime(item.dateDue!)
                                            : "No Due Date",
                                        width: _dueDateWidth,
                                        style:
                                            item.dateDue != null
                                                ? null
                                                : theme.textTheme.bodyMedium
                                                    ?.copyWith(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                      ),
                                      _buildDataCell(
                                        _getAssigneeName(item.assignee),
                                        width: _assigneeWidth,
                                      ),
                                      _buildDataCell(
                                        item.customerBirthday != null
                                            ? _formatDateOnly(
                                              item.customerBirthday!,
                                            )
                                            : "",
                                        width: _birthdayWidth,
                                      ),
                                      _buildDataCell(
                                        item.customerNationality ?? "",
                                        width: _nationalityWidth,
                                      ),
                                      _buildDataCell(
                                        item.customerPhone ?? "",
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
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder:
                (context) => UpdateTaskStatusDialog(
                  projectId: widget.projectId,
                  taskId: row.id,
                  currentStatus: row.status ?? '',
                  onStatusUpdated: reloadAPI,
                ),
          );
        },
        child: Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(row.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusName(row),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateOnly(DateTime dateTime) {
    // Convert UTC time to local time
    final localDateTime = dateTime.toLocal();

    // Format in "Month 12, 2020" format
    final formattedDate = DateFormat('MMMM d, yyyy').format(localDateTime);

    return formattedDate;
  }

  String _formatDateTime(DateTime dateTime) {
    // Convert UTC time to local time
    final localDateTime = dateTime.toLocal();

    // Format in "Month 12, 2020 11:11" format with military time
    final formattedDate = DateFormat(
      'MMMM d, yyyy HH:mm',
    ).format(localDateTime);

    return formattedDate;
  }

  Widget _formItem(ThemeData theme, FormRow form) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.description, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(form.name ?? 'Untitled Form', style: theme.textTheme.titleMedium),
                Text('${form.description}'),],
          ),
        ],
      ),
    );
  }
}

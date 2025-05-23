import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/widgets/paginated_data.dart';
import 'package:sgm/widgets/task/taskview/task.view.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<TaskListView> createState() => TaskListViewState();
}

class TaskListViewState extends State<TaskListView> {
  // Column widths
  final double _titleWidth = 200.0;
  final double _statusWidth = 120.0;
  final double _dueDateWidth = 120.0;
  final double _assigneeWidth = 150.0;
  final double _birthdayWidth = 120.0;
  final double _nationalityWidth = 120.0;
  final double _phoneWidth = 120.0;
  
  final _paginatedDataKey = GlobalKey<PaginatedDataState>();

  Future<void> refresh() async {
    final paginatedState = _paginatedDataKey.currentState;
    if (paginatedState != null) {
      await paginatedState.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return PaginatedData(
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
        future: ProjectTaskStatusService().getStatusByProjectID(
          widget.projectId,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          final statuses = snapshot.data ?? [];
          if (statuses.isEmpty) {
            return const Text('No Statuses');
          } else {
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
            return const Center(child: CircularProgressIndicator());
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
} 
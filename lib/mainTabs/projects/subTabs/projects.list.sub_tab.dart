import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/widgets/paginated_data.dart';
import 'package:sgm/widgets/task/task.view.dart';

class ProjectsListSubTab extends StatefulWidget {
  static const String title = 'List';
  const ProjectsListSubTab({super.key, required this.projectId});
  final String projectId;

  @override
  State<ProjectsListSubTab> createState() => _ProjectsListSubTabState();
}

class _ProjectsListSubTabState extends State<ProjectsListSubTab> {
  ProjectRow? get project => ProjectService().getFromCache(widget.projectId);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (project != null) return;
      await ProjectService().getFromId(widget.projectId);
      setState(() {});
    });
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerHigh,
          child: Text("List by Creation Date"),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: SingleChildScrollView(
            child: PaginatedData(
              builder: (context, data, isLoading) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                            _buildHeaderCell("Title", width: 220),
                            _buildHeaderCell("Status", width: 160),
                            _buildHeaderCell("Due Date", width: 180),
                            _buildHeaderCell("Assignee", width: 180),
                            _buildHeaderCell("Birthday", width: 180),
                            _buildHeaderCell("Nationality", width: 180),
                            _buildHeaderCell("Phone", width: 180),
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
                                _buildDataCell(item.title ?? "", width: 220),
                                _buildDataCell(item.status ?? "", width: 160),
                                _buildDataCell(
                                  item.dateDue != null
                                      ? _formatDateTime(item.dateDue!)
                                      : "No Due Date",
                                  width: 180,
                                  style:
                                      item.dateDue != null
                                          ? null
                                          : theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                ),
                                _buildDataCell(item.assignee ?? "", width: 180),
                                _buildDataCell(
                                  item.customerBirthday != null
                                      ? _formatDateOnly(item.customerBirthday!)
                                      : "",
                                  width: 180,
                                ),
                                _buildDataCell(
                                  item.customerNationality ?? "",
                                  width: 180,
                                ),
                                _buildDataCell(
                                  item.customerPhone ?? "",
                                  width: 180,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
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
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
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
}

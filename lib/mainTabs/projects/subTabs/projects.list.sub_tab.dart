import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/widgets/paginated_data.dart';

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
                  child: Table(
                    border: TableBorder.symmetric(
                      inside: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    defaultColumnWidth: IntrinsicColumnWidth(),
                    children: <TableRow>[
                      TableRow(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Title")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Status")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Due Date")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Assignee")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Birthday")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Nationality")),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TableCell(child: Text("Phone")),
                          ),
                        ],
                      ),
                      ...List.generate(data.length, (index) {
                        final item = data[index] as TaskRow;
                        return TableRow(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text(item.title ?? ""),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Text("Sample Task"),
                            ),
                          ],
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
}

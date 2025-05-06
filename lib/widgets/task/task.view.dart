import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/services/project.service.dart';

/// A full screen dialog
class TaskView extends StatelessWidget {
  const TaskView({super.key, required this.task});

  final TaskRow task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project =
        task.project != null
            ? ProjectService().getFromCache(task.project!)
            : null;
    return Material(
      child: Theme(
        data: theme,
        child: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0, 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.0),
                            Text(
                              task.title ?? "No title",
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(project?.title ?? "No project"),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

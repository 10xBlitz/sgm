import 'package:flutter/material.dart';
import 'package:sgm/models/task_user_answer.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/utils/loading_utils.dart';
import 'package:sgm/widgets/task/tabs/appointment_details.task.view.tab.dart';

import '../../../repository/task_repository.dart';
import 'task.additional.info.dart';
import 'task.customer_detail.dart';

/// A full screen dialog
class TaskView extends StatefulWidget {
  const TaskView({super.key, required this.task});

  final TaskRow task;

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  List<TaskUserAnswer>? _answers;
  UserRow? _assignee;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAssignee();
      _loadAnswers();
    });
  }

  _loadAnswers() async {
    if (widget.task.form == null) {
      return;
    }
    try {
      LoadingUtils.showLoading();
      var answers = await TaskRepository().getAnswersForTask(formId: widget.task.form!, taskId: widget.task.id);
      if (mounted) {
        setState(() {
          _answers = answers;
        });
      }
    } finally {
      LoadingUtils.dismissLoading();
    }
  }

  Future<void> _loadAssignee() async {
    if (widget.task.assignee == null) {
      return;
    }
    final assignee = await UserService().getById(widget.task.assignee!);

    if (mounted) {
      setState(() {
        _assignee = assignee;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project =
        widget.task.project != null
            ? ProjectService().getFromCache(widget.task.project!)
            : null;
    return Material(
      child: Theme(
        data: theme,
        child: Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SafeArea(
            bottom: false,
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
                              widget.task.title ?? "No title",
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

                // Add tabs
                Expanded(
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: [
                            Tab(text: 'Customer Details (Form)'),
                            Tab(text: 'Procedure Info & Billing'),
                            Tab(text: 'Appointment Details'),
                            Tab(text: 'Additional Info'),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              TaskCustomerDetail(
                                task: widget.task,
                                answers: _answers,
                              ),
                              Center(child: Text('Content for Tab 2')),
                              AppointmentDetailsTaskViewTab(task: widget.task),
                              TaskAdditionalInfo(
                                task: widget.task,
                                assignee: _assignee,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

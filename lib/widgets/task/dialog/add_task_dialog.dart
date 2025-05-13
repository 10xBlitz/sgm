import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/services/project_task_status.service.dart';

class AddTaskArgs {
  final String title;
  final String? assigneeId;
  final DateTime? dueDate;
  final String? statusId;

  const AddTaskArgs({required this.title, this.assigneeId, this.dueDate, this.statusId});
}

class AddTaskDialog extends StatefulWidget {
  final String projectTitle;
  final String projectId;
  final void Function(AddTaskArgs args)? onAddTask;
  final Future<void> Function()? onTaskAdded;

  const AddTaskDialog({
    super.key, 
    required this.projectTitle, 
    required this.projectId, 
    this.onAddTask,
    this.onTaskAdded,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  String taskTitle = '';
  String? selectedAssignee;
  String? selectedStatus;
  DateTime? dueDate;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  List<UserRow> _assignees = [];
  List<ProjectTaskStatusRow> _statuses = [];
  bool _isLoading = true;
  final _userService = UserService();
  final _statusService = ProjectTaskStatusService();

  @override
  void initState() {
    super.initState();
    debugPrint('Initializing AddTaskDialog ${widget.projectId}');
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await _userService.getAllUsers(activated: false, isBanned: false);
      final statuses = await _statusService.getStatusByProjectID(widget.projectId);
      setState(() {
        _assignees = users;
        _statuses = statuses;
        _isLoading = false;
      });

      debugPrint('Initializing _loadData statues ${statuses.map((toElement) => toElement.status).toList()}');
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false), child: child!);
        },
      );
      if (time != null) {
        setState(() {
          dueDate = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          if (_isSubmitted) {
            _formKey.currentState!.validate();
          }
        });
      }
    }
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _isSubmitted = true;
    });
    
    if (_formKey.currentState!.validate()) {
      if (widget.onAddTask != null) {
        final args = AddTaskArgs(
          title: taskTitle,
          assigneeId: selectedAssignee,
          dueDate: dueDate,
          statusId: selectedStatus,
        );
        widget.onAddTask!(args);
        
        // Reload project details after adding task
        if (widget.onTaskAdded != null) {
          await widget.onTaskAdded!();
        }
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _isSubmitted ? AutovalidateMode.always : AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.projectTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Title...',
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Task title must be at least 3 characters';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    taskTitle = val;
                    if (_isSubmitted) {
                      _formKey.currentState!.validate();
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('statussesaaa ${_statuses.map((status) => status.status).toList()}'),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedStatus,
                  hint: const Text('Select status'),
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      selectedStatus = val;
                      if (_isSubmitted) {
                        _formKey.currentState!.validate();
                      }
                    });
                  },
                  items:
                      _statuses
                          .map(
                            (status) =>
                                DropdownMenuItem(value: status.id, child: Text(status.status ?? 'Unknown Status')),
                          )
                          .toList(),
                ),
              const SizedBox(height: 24),
              Text('Assignee', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedAssignee,
                  hint: const Text('Select assignee'),
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an assignee';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() {
                      selectedAssignee = val;
                      if (_isSubmitted) {
                        _formKey.currentState!.validate();
                      }
                    });
                  },
                  items:
                      _assignees
                          .map(
                            (user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.name ?? user.email ?? 'Unknown User'),
                            ),
                          )
                          .toList(),
                ),
              const SizedBox(height: 24),
              Text('Due Date', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              FormField<DateTime>(
                validator: (value) {
                  if (dueDate == null) {
                    return 'Please select a due date';
                  }
                  return null;
                },
                builder: (FormFieldState<DateTime> state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: state.hasError ? Colors.red : Colors.grey,
                              width: state.hasError ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dueDate == null
                                    ? 'Select due date'
                                    : DateFormat('MMM dd, yyyy - hh:mm a').format(dueDate!),
                                style: TextStyle(color: dueDate == null ? Colors.grey : Colors.black87),
                              ),
                              Icon(Icons.calendar_today, color: state.hasError ? Colors.red : Colors.grey),
                            ],
                          ),
                        ),
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1B06B),
                    // gold color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _validateAndSubmit,
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

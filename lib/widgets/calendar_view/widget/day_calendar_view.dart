import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:intl/intl.dart';
import 'package:sgm/widgets/calendar_view/widget/day_calendar_controller.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/widgets/task/taskview/task.view.dart';

class DayCalendarView extends StatefulWidget {
  /// The ID of the project to display tasks for
  final String? projectId;

  /// The initial date to display
  final DateTime initialDate;
  final Map<DateTime, List<TaskRow>>? tasksByDay;

  const DayCalendarView({super.key, this.projectId, required this.initialDate, this.tasksByDay});

  @override
  State<DayCalendarView> createState() => _DayCalendarViewState();
}

class _DayCalendarViewState extends State<DayCalendarView> {
  late final DayCalendarViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DayCalendarViewController(
      projectId: widget.projectId,
      initialDate: widget.initialDate,
      tasksByDay: widget.tasksByDay,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<DayCalendarViewController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: _buildAppBar(controller),
            body: controller.isLoading ? const Center(child: CircularProgressIndicator()) : _buildBody(controller),
          );
        },
      ),
    );
  }

  // Build the app bar with navigation controls
  AppBar _buildAppBar(DayCalendarViewController controller) {
    final isToday = controller.isSameDay(controller.selectedDate, DateTime.now());
    final _ = Theme.of(context);

    return AppBar(
      backgroundColor: const Color(0xFFF1E6CF),
      elevation: 0,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(controller.selectedDate),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            isToday
                ? 'Today, ${DateFormat('EEEE d').format(controller.selectedDate)}'
                : DateFormat('EEEE, MMMM d').format(controller.selectedDate),
            style: TextStyle(fontSize: 14, color: isToday ? Colors.green.shade700 : Colors.black54),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Previous day button
        Visibility(
          visible: false,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black87),
            tooltip: 'Previous day',
            onPressed: () => controller.previousDay(),
          ),
        ),
        // Next day button
        Visibility(
          visible: false,
          child: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87),
            tooltip: 'Next day',
            onPressed: () => controller.nextDay(),
          ),
        ),
        // Today button
        Visibility(
          visible: false,
          child: IconButton(
            icon: const Icon(Icons.today, color: Colors.black87),
            tooltip: 'Go to today',
            onPressed: () => controller.goToToday(),
          ),
        ),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black87),
          tooltip: 'Refresh tasks',
          onPressed: () => controller.refreshTasks(),
        ),
      ],
    );
  }

  // Build the main body of the view
  Widget _buildBody(DayCalendarViewController controller) {
    return Column(
      children: [
        // Date navigation bar

        // Task list
        Expanded(child: _buildTaskList(controller)),
      ],
    );
  }


  // ignore: unused_element
  Widget _buildDateNavigator(DayCalendarViewController controller) {
    final today = DateTime.now();
    final selectedDate = controller.selectedDate;

    // Generate 7 days (3 before selected, selected, 3 after)
    final dates = List.generate(
      7,
      (index) => DateTime(selectedDate.year, selectedDate.month, selectedDate.day - 3 + index),
    );

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFFF1E6CF),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = controller.isSameDay(date, selectedDate);
          final isToday = controller.isSameDay(date, today);
          return GestureDetector(
            onTap: () => controller.navigateToDay(date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? const Color(0xFFD2B771)
                        : isToday
                        ? Colors.white
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected ? Border.all(color: const Color(0xFFD2B771), width: 2) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date)[0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected || isToday ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected
                              ? Colors.white
                              : isToday
                              ? const Color(0xFFD2B771)
                              : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected || isToday ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Build a task list for the selected day
  Widget _buildTaskList(DayCalendarViewController controller) {
    final tasks = controller.tasksForSelectedDay;

    if (tasks.isEmpty) {
      return _buildEmptyState(controller);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header showing task count
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tasks for ${DateFormat('MMMM d').format(controller.selectedDate)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFD2B771), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  '${tasks.length} ${tasks.length == 1 ? 'Task' : 'Tasks'}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),

        // Task list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(task, controller);
            },
          ),
        ),
      ],
    );
  }

  // Build empty state when no tasks
  Widget _buildEmptyState(DayCalendarViewController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'No tasks for ${DateFormat('MMMM d').format(controller.selectedDate)}',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text('Tasks with due dates will appear here', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => controller.refreshTasks(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD2B771),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Tasks', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Build a task card with status badge and timing info
  Widget _buildTaskCard(TaskRow task, DayCalendarViewController controller) {
    // Check for other tasks at the same time
    int tasksAtSameTime = 0;
    bool hasTimeSlotDuplicates = false;

    if (task.dateDue != null) {
      final String timeSlot = DateFormat('HH:mm').format(task.dateDue!);

      // Count how many tasks share this time slot
      for (final otherTask in controller.tasksForSelectedDay) {
        if (otherTask.dateDue != null && DateFormat('HH:mm').format(otherTask.dateDue!) == timeSlot) {
          tasksAtSameTime++;
        }
      }

      hasTimeSlotDuplicates = tasksAtSameTime > 1;
    }

    // Generate additional text for tasks with the same time slot
    final String timeSlotInfo = hasTimeSlotDuplicates ? " (1 of $tasksAtSameTime)" : "";

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasTimeSlotDuplicates ? Colors.amber : Colors.grey,
          width: hasTimeSlotDuplicates ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show TaskView dialog when a task is tapped
          showTaskView(task);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with title and time
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Task icon - shows different icon if there are duplicates
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasTimeSlotDuplicates ? Colors.amber.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      hasTimeSlotDuplicates ? Icons.access_time : Icons.assignment,
                      color: hasTimeSlotDuplicates ? Colors.amber.shade800 : Colors.grey.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${task.title ?? 'Untitled Task'}$timeSlotInfo",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        ),
                        if (task.description != null && task.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              task.description!,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Due time display
                  if (task.dateDue != null)
                    GestureDetector(
                      onTap: () {
                        // Open task view when time badge is tapped
                        showTaskView(task);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: hasTimeSlotDuplicates ? Colors.red.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: hasTimeSlotDuplicates ? Colors.red.shade300 : Colors.grey.shade300),
                        ),
                        child: Text(
                          DateFormat('HH:mm').format(task.dateDue!),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: hasTimeSlotDuplicates ? Colors.red.shade700 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Footer with status and metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  if (task.status != null) _buildStatusBadge(task, controller),

                  // Task ID (mainly for debugging)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build status badge with project task status
  Widget _buildStatusBadge(TaskRow task, DayCalendarViewController controller) {
    return FutureBuilder<List<ProjectTaskStatusRow>>(
      future: task.status != null ? ProjectTaskStatusService().getStatusByProjectID(widget.projectId ?? '') : null,
      builder: (context, snapshot) {
        // Show loading indicator while fetching statuses
        if(!snapshot.hasData ) {
          return const Text('');
        }
        if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatusBadgeContent(
            controller.getStatusColor(task.status),
            controller.getStatusName(task.status),
            task,
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
        }

        final statuses = snapshot.data ?? [];
        if (statuses.isEmpty) {
          return const Text('No Statuses');
        }

        // Find the correct status using exact TaskListView logic
        final status = statuses.firstWhere(
          (s) => s.id == task.status,
          orElse: () => statuses.firstWhere((s) => s.forNullStatus, orElse: () => statuses.first),
        );

        return _buildStatusBadgeContent(controller.getStatusColor(task.status), status.status ?? 'No Status', task);
      },
    );
  }

  // Build the actual status badge UI
  Widget _buildStatusBadgeContent(Color color, String statusName, TaskRow task) {
    return GestureDetector(
      onTap: () {
        // Open task view when status badge is tapped
        showTaskView(task);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 10, color: Colors.white),
            const SizedBox(width: 4),
            Text(statusName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // Helper method to show task view
  void showTaskView(TaskRow task) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return TaskView(task: task);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }
}

// Math utility for min function
class Math {
  static int min(int a, int b) => a < b ? a : b;
}

import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class DayCalendarViewController extends ChangeNotifier {
  /// The ID of the project to display tasks for
  final String? projectId;

  /// The initial date to display
  final DateTime initialDate;

  /// Optional pre-loaded tasks mapped by day
  final Map<DateTime, List<TaskRow>>? tasksByDay;

  /// Controller for calendar events
  late EventsController eventsController;

  /// The current date being viewed
  DateTime _selectedDate;

  /// The tasks for the selected day
  List<TaskRow> _tasksForSelectedDay = [];

  /// Loading state for async operations
  bool _isLoading = false;

  /// Cache of project task statuses
  Map<String, ProjectTaskStatusRow> _statusCache = {};

  /// Creates a new day calendar view controller
  DayCalendarViewController({this.projectId, required this.initialDate, this.tasksByDay})
    : _selectedDate = initialDate {
    eventsController = EventsController();
    eventsController.updateFocusedDay(_selectedDate);

    // Load statuses for the project
    if (projectId != null) {
      _loadStatusCache();
    }

    // Load tasks for the selected day
    if (tasksByDay != null) {
      loadTasksFromMap();
    } else {
      loadTasksForDay();
    }
  }

  /// The currently selected date
  DateTime get selectedDate => _selectedDate;

  /// The tasks for the selected day
  List<TaskRow> get tasksForSelectedDay => _tasksForSelectedDay;

  /// Current loading state
  bool get isLoading => _isLoading;

  /// Sets a new selected date and loads tasks for it
  Future<void> navigateToDay(DateTime date) async {
    _selectedDate = date;
    _tasksForSelectedDay = [];
    _isLoading = true;
    notifyListeners();

    // Set the focused day in the events controller
    eventsController.updateFocusedDay(_selectedDate);

    // Load tasks for the new day
    if (tasksByDay != null) {
      await loadTasksFromMap();
    } else {
      await loadTasksForDay();
    }
  }

  /// Navigate to the previous day
  Future<void> previousDay() async {
    await navigateToDay(_selectedDate.subtract(const Duration(days: 1)));
  }

  /// Navigate to the next day
  Future<void> nextDay() async {
    await navigateToDay(_selectedDate.add(const Duration(days: 1)));
  }

  /// Navigate to today
  Future<void> goToToday() async {
    await navigateToDay(DateTime.now());
  }

  /// Load tasks from the provided tasksByDay map
  Future<void> loadTasksFromMap() async {
    if (tasksByDay == null) {
      MyLogger.d("No tasksByDay map provided");
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      MyLogger.d("Loading tasks from map for date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");

      // Find tasks for the selected day
      final Map<String, List<TaskRow>> tasksByIdAndDate = {};

      // Normalize selected date to midnight
      final normalizedSelectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

      // Check all entries in the map
      tasksByDay!.forEach((date, tasks) {
        final normalizedDate = DateTime(date.year, date.month, date.day);

        // Check if this date matches our selected day
        bool dateMatches = normalizedDate.isAtSameMomentAs(normalizedSelectedDate) || isSameDay(date, _selectedDate);

        if (dateMatches) {
          MyLogger.d("Found ${tasks.length} tasks for ${DateFormat('yyyy-MM-dd').format(date)}");

          // Group tasks by ID and date
          for (final task in tasks) {
            if (task.dateDue != null) {
              final String timeKey = DateFormat('HH:mm').format(task.dateDue!);
              final String groupKey = "${task.id}_$timeKey";

              if (!tasksByIdAndDate.containsKey(groupKey)) {
                tasksByIdAndDate[groupKey] = [];
              }

              tasksByIdAndDate[groupKey]!.add(task);
            } else {
              // For tasks without dates, just use the ID
              final String groupKey = "${task.id}_nodate";

              if (!tasksByIdAndDate.containsKey(groupKey)) {
                tasksByIdAndDate[groupKey] = [];
              }

              tasksByIdAndDate[groupKey]!.add(task);
            }
          }
        }
      });

      // Create a flat list of tasks, taking the first task from each group
      final List<TaskRow> uniqueTasks = [];
      tasksByIdAndDate.forEach((key, tasks) {
        uniqueTasks.add(tasks.first);
      });

      // Update our list of tasks
      _tasksForSelectedDay = uniqueTasks;

      // Sort tasks by time
      _tasksForSelectedDay.sort((a, b) {
        if (a.dateDue == null) return 1;
        if (b.dateDue == null) return -1;
        return a.dateDue!.compareTo(b.dateDue!);
      });

      // Update events
      _updateEventsFromTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      MyLogger.d("Error loading tasks from map: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Loads tasks for the selected day from the service
  Future<void> loadTasksForDay() async {
    if (projectId == null) {
      _tasksForSelectedDay = [];
      _isLoading = false;
      notifyListeners();
      MyLogger.d("No project ID provided, cannot load tasks");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      MyLogger.d("Loading tasks for date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");

      // Use the API to load tasks specifically for this day
      final tasks = await TaskService().getTasksByDay(projectId!, _selectedDate);

      if (tasks.isEmpty) {
        MyLogger.d("No tasks returned from API for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
      }

      // Deduplicate tasks by ID
      final Map<String, TaskRow> uniqueTasks = {};
      for (var task in tasks) {
        uniqueTasks[task.id] = task;
      }

      // Update our list of tasks
      _tasksForSelectedDay = uniqueTasks.values.toList();

      // Sort tasks by time
      _tasksForSelectedDay.sort((a, b) {
        if (a.dateDue == null) return 1;
        if (b.dateDue == null) return -1;
        return a.dateDue!.compareTo(b.dateDue!);
      });

      // Update events
      _updateEventsFromTasks();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      MyLogger.d("Error loading tasks for day: $e");
      _tasksForSelectedDay = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the events controller with the tasks for the selected day
  void _updateEventsFromTasks() {
    // Reset the events controller
    eventsController = EventsController();
    eventsController.updateFocusedDay(_selectedDate);

    MyLogger.d("Creating events for ${_tasksForSelectedDay.length} tasks");

    // Create events from tasks
    final List<Event> events = [];

    // Map to track tasks with the same time slot
    final Map<String, int> timeSlotCounts = {};

    for (var task in _tasksForSelectedDay) {
      if (task.dateDue != null) {
        // Create a time slot key for this task
        final timeKey = DateFormat('HH:mm').format(task.dateDue!);

        // Count how many tasks are in this time slot
        timeSlotCounts[timeKey] = (timeSlotCounts[timeKey] ?? 0) + 1;

        // Normalize the time to the selected date to ensure it appears on the correct day
        final normalizedDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          task.dateDue!.hour,
          task.dateDue!.minute,
        );

        // Create start and end times for the event
        final startTime = normalizedDateTime;
        final endTime = startTime.add(const Duration(hours: 1)); // Default 1 hour duration

        // Create a task event
        final taskEvent = Event(
          startTime: startTime,
          endTime: endTime,
          title: task.title ?? "Untitled Task",
          description: "${task.description ?? ''}\nStatus: ${getStatusName(task.status)}",
          color: getStatusColor(task.status),
          textColor: Colors.white,
        );

        events.add(taskEvent);
      }
    }

    // Add a test event only if there are no real events
    if (events.isEmpty) {
      final now = DateTime.now();
      final testTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, now.hour, now.minute);

      final testEvent = Event(
        startTime: testTime,
        endTime: testTime.add(const Duration(hours: 1)),
        title: "Test Event",
        description: "This is a test event to verify the calendar is working",
        color: Colors.grey.shade400,
        textColor: Colors.white,
      );
      events.add(testEvent);
    }

    // Update the controller with the new events
    eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(events);
    });
  }

  /// Load and cache all status definitions for the project
  Future<void> _loadStatusCache() async {
    if (projectId == null) return;

    try {
      MyLogger.d('Loading statuses for project $projectId');
      final statuses = await ProjectTaskStatusService().getStatusByProjectID(projectId!);

      // Create a map of status ID to status object
      _statusCache = {for (var status in statuses) status.id: status};

      // Force refresh UI after loading statuses
      notifyListeners();

      MyLogger.d('Loaded ${_statusCache.length} statuses for project $projectId');
    } catch (e) {
      MyLogger.d('Error loading status cache: $e');
    }
  }

  /// Get the status name from a status ID using the same logic as TaskListView
  String getStatusName(String? statusId) {
    // If no status cache or no project ID, return the raw status
    if (_statusCache.isEmpty || projectId == null) {
      return statusId ?? 'No Status';
    }

    try {
      // Get cached statuses
      final statuses = _statusCache.values.toList();

      if (statuses.isEmpty) {
        return 'No Statuses';
      } else {
        // Follow same logic as TaskListView's _buildStatusCell
        final status = statuses.firstWhere(
          (s) => s.id == statusId,
          orElse: () => statuses.firstWhere((s) => s.forNullStatus, orElse: () => statuses.first),
        );
        return status.status ?? 'No Status';
      }
    } catch (e) {
      MyLogger.d('Error getting status name: $e');
      return statusId ?? 'No Status';
    }
  }

  /// Get color based on task status
  Color getStatusColor(String? statusId) {
    return Colors.green;
  }

  /// Helper function to check if two dates are the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Manual refresh of tasks and status cache
  Future<void> refreshTasks() async {
    if (projectId != null) {
      await _loadStatusCache();
    }

    if (tasksByDay != null) {
      await loadTasksFromMap();
    } else {
      await loadTasksForDay();
    }
  }

  @override
  void dispose() {
    eventsController.dispose();
    super.dispose();
  }
}

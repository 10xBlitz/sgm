import 'package:flutter/material.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:intl/intl.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:sgm/widgets/calendar_view/widget/day_calendar_controller.dart';

/// Configuration for the calendar view
class CalendarConfig {
  static const taskColor = Color(0xFFBEDAB7);
  static const dateRange = 365 * 5; // 5 years before and after
}

/// Controller for the calendar view that manages state and data
///
/// This controller handles:
/// - Loading tasks for a specific project
/// - Managing calendar navigation (previous/next month, today)
/// - Tracking the current month and selected date
/// - Organizing tasks by day for display
/// - Managing calendar events for the view
class CalendarViewController extends ChangeNotifier {
  /// The ID of the project to display tasks for
  final String? projectId;

  /// The initial date to display when the calendar is first shown
  final DateTime initialDate;

  /// The earliest date that can be displayed in the calendar
  final DateTime firstDate;

  /// The latest date that can be displayed in the calendar
  final DateTime lastDate;

  /// Controller for calendar events
  late EventsController eventsController;

  /// Creates a new calendar view controller
  CalendarViewController({
    this.projectId,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  }) {
    _selectedDate = initialDate;
    _currentMonth = DateTime(initialDate.year, initialDate.month);
    eventsController = EventsController();
    _generateDaysForMonth();
    loadTasks();
  }

  /// The currently selected date (day)
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  /// The current month being viewed (first day of month)
  late DateTime _currentMonth;

  DateTime get currentMonth => _currentMonth;

  /// Loading state for async operations
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// List of days in the current month view (including padding days)
  List<DateTime> _daysInMonth = [];

  List<DateTime> get daysInMonth => _daysInMonth;

  /// Map of day to tasks for that day
  /// Key: DateTime normalized to midnight
  /// Value: List of tasks for that day
  final Map<DateTime, List<TaskRow>> _tasksByDay = {};

  Map<DateTime, List<TaskRow>> get tasksByDay => _tasksByDay;

  /// Tasks grouped by month (for caching)
  /// Key: Month string (e.g. "2023-04")
  /// Value: List of tasks for that month
  final Map<String, List<TaskRow>> _tasksByMonth = {};

  /// Updates the selected date
  set selectedDate(DateTime date) {
    if (date.isBefore(firstDate) || date.isAfter(lastDate)) {
      throw ArgumentError('Selected date is out of range');
    }
    _selectedDate = date;
    notifyListeners();
  }

  /// Navigation methods
  void previousMonth() => _updateMonth(DateTime(_currentMonth.year, _currentMonth.month - 1));
  void nextMonth() => _updateMonth(DateTime(_currentMonth.year, _currentMonth.month + 1));
  void goToToday() {
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    selectedDate = DateTime.now();
    _generateDaysForMonth();
    loadTasks();
    notifyListeners();
  }

  /// Updates the current month and loads tasks for that month
  void updateMonth(DateTime month) {
    _updateMonth(DateTime(month.year, month.month));
  }

  void _updateMonth(DateTime newMonth) {
    _currentMonth = newMonth;
    _generateDaysForMonth();
    loadTasks();
    notifyListeners();
  }

  /// Generates the days to display for the current month
  /// This includes padding days from previous and next months
  void _generateDaysForMonth() {
    _daysInMonth = [];

    // Find the first day of the month
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);

    // Find what day of the week the first day is (0 is Sunday, 1 is Monday, etc.)
    int firstWeekdayOfMonth = firstDayOfMonth.weekday % 7; // Adjust to 0-based for Sunday start

    // Find the last day of the month
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);

    // Calculate padding days from previous month
    final daysFromPreviousMonth = firstWeekdayOfMonth;
    final previousMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    final lastDayOfPreviousMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);

    // Add days from previous month as padding
    for (int i = 0; i < daysFromPreviousMonth; i++) {
      _daysInMonth.add(
        DateTime(previousMonth.year, previousMonth.month, lastDayOfPreviousMonth.day - daysFromPreviousMonth + i + 1),
      );
    }

    // Add all days in current month
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      _daysInMonth.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    // Add days from next month to fill out the grid (to make 6 rows)
    final remainingDays = 42 - _daysInMonth.length; // 6 rows * 7 days
    final nextMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);

    for (int i = 1; i <= remainingDays; i++) {
      _daysInMonth.add(DateTime(nextMonth.year, nextMonth.month, i));
    }
  }

  /// Loads tasks for the current month from the service
  Future<void> loadTasks() async {
    if (projectId == null) {
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final monthRange = _getMonthDateRange();
      final tasksByMonth = await _fetchTasksForMonth(monthRange);
      _processTasks(tasksByMonth);
      _syncTasksWithEvents();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      MyLogger.d('Error loading tasks: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  ({DateTime start, DateTime end}) _getMonthDateRange() {
    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final end = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    return (start: start, end: end);
  }

  Future<Map<String, List<TaskRow>>> _fetchTasksForMonth(({DateTime start, DateTime end}) range) async {
    MyLogger.d('Query month: ${DateFormat('MMMM yyyy').format(_currentMonth)}');
    MyLogger.d('First day of month: ${range.start}');
    MyLogger.d('Last day of month: ${range.end} (${range.end.day} days)');

    return await TaskService().getTasksByMonth(
      projectId!,
      startDate: range.start,
      endDate: range.end,
    );
  }

  void _processTasks(Map<String, List<TaskRow>> tasksByMonth) {
    _tasksByMonth.clear();
    _tasksByMonth.addAll(tasksByMonth);

    _tasksByDay.clear();
    final tasksByDayDeduped = _deduplicateTasks(tasksByMonth);
    _convertToTasksByDay(tasksByDayDeduped);
    _logTaskStats(tasksByMonth);
  }

  Map<DateTime, Map<String, TaskRow>> _deduplicateTasks(Map<String, List<TaskRow>> tasksByMonth) {
    final tasksByDayDeduped = <DateTime, Map<String, TaskRow>>{};

    for (final monthTasks in tasksByMonth.values) {
      for (final task in monthTasks) {
        if (task.dateDue != null) {
          final date = DateTime(task.dateDue!.year, task.dateDue!.month, task.dateDue!.day);
          tasksByDayDeduped.putIfAbsent(date, () => {});
          tasksByDayDeduped[date]![task.id] = task;
        }
      }
    }

    return tasksByDayDeduped;
  }

  void _convertToTasksByDay(Map<DateTime, Map<String, TaskRow>> tasksByDayDeduped) {
    tasksByDayDeduped.forEach((date, tasksMap) {
      _tasksByDay[date] = tasksMap.values.toList();
    });
  }

  void _logTaskStats(Map<String, List<TaskRow>> tasksByMonth) {
    int totalTasksFromAPI = 0;
    for (final tasks in tasksByMonth.values) {
      totalTasksFromAPI += tasks.length;
    }

    int totalDays = _tasksByDay.length;
    int totalTasks = 0;
    _tasksByDay.forEach((date, tasks) {
      totalTasks += tasks.length;
      MyLogger.d('DEBUG: Day ${DateFormat('yyyy-MM-dd').format(date)} has ${tasks.length} unique tasks');
    });

    MyLogger.d(
      'DEBUG: After deduplication, loaded $totalTasks tasks across $totalDays days (reduced from $totalTasksFromAPI)',
    );
  }

  /// Synchronizes tasks with the events controller
  void _syncTasksWithEvents() {
    MyLogger.d('DEBUG: Syncing ${_tasksByDay.length} days of tasks with events controller');
    eventsController = EventsController();

    final uniqueEvents = _createUniqueEvents();
    _addEventsToController(uniqueEvents);
    eventsController.updateFocusedDay(_currentMonth);
  }

  Map<String, Event> _createUniqueEvents() {
    final uniqueEvents = <String, Event>{};
    final taskIdCounts = <String, int>{};

    _tasksByDay.forEach((date, tasks) {
      for (var task in tasks) {
        taskIdCounts[task.id] = (taskIdCounts[task.id] ?? 0) + 1;
        final eventKey = "${task.id}_${DateFormat('yyyy-MM-dd').format(date)}";

        if (!uniqueEvents.containsKey(eventKey)) {
          uniqueEvents[eventKey] = Event(
            startTime: date,
            endTime: date.add(const Duration(hours: 1)),
            title: task.title ?? 'Untitled Task',
            description: task.description,
            color: getStatusColor(task.status),
          );
        }
      }
    });

    _logDuplicateTasks(taskIdCounts);
    return uniqueEvents;
  }

  void _logDuplicateTasks(Map<String, int> taskIdCounts) {
    final duplicateIds = taskIdCounts.entries.where((e) => e.value > 1).map((e) => e.key).toList();
    if (duplicateIds.isNotEmpty) {
      MyLogger.d('DEBUG: Found ${duplicateIds.length} task IDs that appear in multiple days:');
      for (var id in duplicateIds) {
        MyLogger.d('DEBUG:   Task ID $id appears ${taskIdCounts[id]} times');
      }
    }
  }

  void _addEventsToController(Map<String, Event> uniqueEvents) {
    final events = uniqueEvents.values.toList();
    MyLogger.d('DEBUG: Adding ${events.length} unique events to the events controller');
    eventsController.updateCalendarData((calendarData) {
      calendarData.addEvents(events);
    });
  }

  /// Get color based on task status
  /// Returns a consistent light green color for all statuses to match the design
  Color getStatusColor(String? status) {
    // Use light green for all statuses to match the screenshot
    return const Color(0xFFBEDAB7);
  }

  /// Loads tasks for a specific day from the service
  ///
  /// This method uses a specialized API to get tasks for exactly one day,
  /// which is more precise than filtering from the monthly task data.
  Future<List<TaskRow>> loadTasksForDay(DateTime date) async {
    if (projectId == null) {
      return [];
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Normalize the date to midnight
      final normalizedDate = DateTime(date.year, date.month, date.day);

      MyLogger.d('Loading tasks for day: ${DateFormat('yyyy-MM-dd').format(normalizedDate)}');

      // Get tasks for this specific day using the new API
      final tasks = await TaskService().getTasksByDay(projectId!, normalizedDate);

      MyLogger.d('Found ${tasks.length} tasks for day ${DateFormat('yyyy-MM-dd').format(normalizedDate)}');

      // Deduplicate tasks by ID
      final Map<String, TaskRow> uniqueTasks = {};
      for (var task in tasks) {
        uniqueTasks[task.id] = task;
      }

      final uniqueTasksList = uniqueTasks.values.toList();
      MyLogger.d('After deduplication: ${uniqueTasksList.length} unique tasks');

      // Add these tasks to our tasksByDay map
      if (uniqueTasksList.isNotEmpty) {
        _tasksByDay[normalizedDate] = uniqueTasksList;

        // Also update the monthly data cache
        final monthKey = '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}';
        if (!_tasksByMonth.containsKey(monthKey)) {
          _tasksByMonth[monthKey] = [];
        }

        // Create a set of existing task IDs in the monthly cache
        final existingTaskIds = _tasksByMonth[monthKey]!.map((task) => task.id).toSet();

        // Add any tasks that aren't already in the monthly cache
        for (final task in uniqueTasksList) {
          if (!existingTaskIds.contains(task.id)) {
            _tasksByMonth[monthKey]!.add(task);
          }
        }
      }

      _isLoading = false;
      notifyListeners();

      return uniqueTasksList;
    } catch (e) {
      MyLogger.d('Error loading tasks for day: $e');
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  /// Creates a new day calendar controller instance with the data from this controller
  ///
  /// This allows creating a day view with pre-loaded task data for better performance
  /// and to avoid duplicate API calls when navigating between calendar and day views.
  DayCalendarViewController createDayController(DateTime initialDate) {
    MyLogger.d('Creating day controller for date: ${DateFormat('yyyy-MM-dd').format(initialDate)}');
    
    // Create a new controller with the current project ID and task data
    return DayCalendarViewController(
      projectId: projectId,
      initialDate: initialDate,
      tasksByDay: tasksByDay,
    );
  }

  @override
  void dispose() {
    eventsController.dispose();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

/// Service class for handling task-related operations with Supabase.
class TaskService {
  // Singleton instance
  static final TaskService _instance = TaskService._internal();

  // Factory constructor to return the singleton instance
  factory TaskService() => _instance;

  // Private constructor
  TaskService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for task objects
  final Map<String, TaskRow> _cache = {};

  /// Creates a new task in the database.
  Future<TaskRow?> createTask({
    required String title,
    String? project,
    String? description,
    String? status,
    String? assignee,
    String? customerName,
    String? customerNationality,
    DateTime? customerBirthday,
    String? customerCountryResidence,
    String? customerPhone,
    String? customerGender,
    DateTime? dateDue,
    String? form,
    String? createdBy,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        TaskRow.field.title: title,
        TaskRow.field.project: project,
        TaskRow.field.description: description,
        TaskRow.field.status: status ?? 'New',
        TaskRow.field.assignee: assignee,
        TaskRow.field.customerName: customerName,
        TaskRow.field.customerNationality: customerNationality,
        if (customerBirthday != null)
          TaskRow.field.customerBirthday: customerBirthday.toIso8601String(),
        TaskRow.field.customerCountryResidence: customerCountryResidence,
        TaskRow.field.customerPhone: customerPhone,
        TaskRow.field.customerGender: customerGender,
        if (dateDue != null) TaskRow.field.dateDue: dateDue.toIso8601String(),
        TaskRow.field.form: form,
        TaskRow.field.createdBy: createdBy,
        TaskRow.field.createdAt: now.toIso8601String(),
        TaskRow.field.sysCreatedAt: now.toIso8601String(),
        TaskRow.field.lastStatusUpdate: now.toIso8601String(),
        TaskRow.field.attachmentProcessed: false,
      };

      final response =
          await _supabase.from('task').insert(data).select().single();

      final task = TaskRow.fromJson(response);
      _cache[task.id] = task;
      return task;
    } catch (error) {
      debugPrint('Error creating task: $error');
      return null;
    }
  }

  /// Gets a task by its ID.
  Future<TaskRow?> getFromId(String id, {bool cached = true}) async {
    if (cached && _cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final response =
          await _supabase
              .from('task')
              .select()
              .eq(TaskRow.field.id, id)
              .single();

      final task = TaskRow.fromJson(response);
      _cache[id] = task;
      return task;
    } catch (error) {
      debugPrint('Error fetching task by ID: $error');
      return null;
    }
  }

  /// Gets all tasks for a specific project.
  Future<List<TaskRow>> getAllTasks({
    String? project,
    String? status,
    String? assignee,
  }) async {
    try {
      var query = _supabase.from('task').select();

      if (project != null) {
        query = query.eq(TaskRow.field.project, project);
      }

      if (status != null) {
        query = query.eq(TaskRow.field.status, status);
      }

      if (assignee != null) {
        query = query.eq(TaskRow.field.assignee, assignee);
      }

      final response = await query.order(
        TaskRow.field.createdAt,
        ascending: false,
      );

      final tasks =
          response.map<TaskRow>((dynamic data) {
            try {
              if (data is! Map<String, dynamic>) {
                final convertedData = Map<String, dynamic>.from(data as Map);
                final task = TaskRow.fromJson(convertedData);
                _cache[task.id] = task;
                return task;
              }

              final task = TaskRow.fromJson(data);
              _cache[task.id] = task;
              return task;
            } catch (e) {
              debugPrint('Error converting task data: $e');
              debugPrint('Problematic data: $data');
              rethrow;
            }
          }).toList();

      return tasks;
    } catch (error) {
      debugPrint('Error fetching tasks: $error');
      return [];
    }
  }

  /// Gets a paginated list of tasks for a project.
  Future<List<TaskRow>> getPage(
    String projectId,
    int page,
    int pageSize,
  ) async {
    final startIndex = (page - 1) * pageSize;

    try {
      final response = await _supabase
          .from('task')
          .select()
          .eq(TaskRow.field.project, projectId)
          .order(TaskRow.field.createdAt, ascending: false)
          .range(startIndex, startIndex + pageSize - 1);

      final tasks =
          response.map<TaskRow>((dynamic data) {
            try {
              if (data is! Map<String, dynamic>) {
                final convertedData = Map<String, dynamic>.from(data as Map);
                final task = TaskRow.fromJson(convertedData);
                _cache[task.id] = task;
                return task;
              }

              final task = TaskRow.fromJson(data);
              _cache[task.id] = task;
              return task;
            } catch (e) {
              debugPrint('Error converting task data: $e');
              debugPrint('Problematic data: $data');
              rethrow;
            }
          }).toList();

      return tasks;
    } catch (error) {
      debugPrint('Error fetching paginated tasks: $error');
      return [];
    }
  }

  /// Gets the count of tasks
  Future<int> getCount(String projectId) async {
    final response = await _supabase
        .from('task')
        .select()
        .eq(TaskRow.field.project, projectId)
        .count(CountOption.exact);

    return response.count;
  }

  /// Updates an existing task in the database.
  Future<TaskRow?> updateTask({
    required String id,
    String? title,
    String? description,
    String? status,
    String? assignee,
    String? customerName,
    String? customerNationality,
    DateTime? customerBirthday,
    String? customerCountryResidence,
    String? customerPhone,
    String? customerGender,
    DateTime? dateDue,
    String? form,
    bool? attachmentProcessed,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Only include fields that are provided
      if (title != null) data[TaskRow.field.title] = title;
      if (description != null) data[TaskRow.field.description] = description;
      if (status != null) {
        data[TaskRow.field.status] = status;
        data[TaskRow.field.lastStatusUpdate] = DateTime.now().toIso8601String();
      }
      if (assignee != null) data[TaskRow.field.assignee] = assignee;
      if (customerName != null) data[TaskRow.field.customerName] = customerName;
      if (customerNationality != null) {
        data[TaskRow.field.customerNationality] = customerNationality;
      }
      if (customerBirthday != null) {
        data[TaskRow.field.customerBirthday] =
            customerBirthday.toIso8601String();
      }
      if (customerCountryResidence != null) {
        data[TaskRow.field.customerCountryResidence] = customerCountryResidence;
      }
      if (customerPhone != null) {
        data[TaskRow.field.customerPhone] = customerPhone;
      }
      if (customerGender != null) {
        data[TaskRow.field.customerGender] = customerGender;
      }
      if (dateDue != null) {
        data[TaskRow.field.dateDue] = dateDue.toIso8601String();
      }
      if (form != null) data[TaskRow.field.form] = form;
      if (attachmentProcessed != null) {
        data[TaskRow.field.attachmentProcessed] = attachmentProcessed;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingTask = await getFromId(id);
        return existingTask;
      }

      final response =
          await _supabase
              .from('task')
              .update(data)
              .eq(TaskRow.field.id, id)
              .select()
              .single();

      final task = TaskRow.fromJson(response);
      _cache[id] = task;
      return task;
    } catch (error) {
      debugPrint('Error updating task: $error');
      return null;
    }
  }

  /// Deletes a task from the database.
  Future<bool> deleteTask(String id) async {
    try {
      await _supabase.from('task').delete().eq(TaskRow.field.id, id);

      _cache.remove(id);
      return true;
    } catch (error) {
      debugPrint('Error deleting task: $error');
      return false;
    }
  }

  /// Gets tasks by status.
  Future<List<TaskRow>> getTasksByStatus(String status) async {
    return getAllTasks(status: status);
  }

  /// Gets tasks assigned to a specific user.
  Future<List<TaskRow>> getTasksForUser(String userId) async {
    return getAllTasks(assignee: userId);
  }

  /// Searches tasks by title and description.
  Future<List<TaskRow>> searchTasks(String query) async {
    try {
      final response = await _supabase
          .from('task')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order(TaskRow.field.createdAt, ascending: false);

      final tasks =
          response.map<TaskRow>((data) {
            final task = TaskRow.fromJson(data);
            _cache[task.id] = task;
            return task;
          }).toList();

      return tasks;
    } catch (error) {
      debugPrint('Error searching tasks: $error');
      return [];
    }
  }

  /// Gets the count of tasks by status for a specific project.
  Future<Map<String, int>> getTaskCountByStatus(String projectId) async {
    try {
      final response = await _supabase
          .from('task')
          .select('status')
          .eq(TaskRow.field.project, projectId);

      final Map<String, int> statusCount = {};
      for (final data in response) {
        final status = data['status'] as String? ?? 'Unknown';
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      return statusCount;
    } catch (error) {
      debugPrint('Error getting task count by status: $error');
      return {};
    }
  }

  /// Gets tasks grouped by month for the calendar view.
  /// 
  /// Returns a map with keys in the format 'yyyy-MM' and values as lists of tasks.
  Future<Map<String, List<TaskRow>>> getTasksByMonth(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Set default dates if not provided
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 180));
      final end = endDate ?? DateTime.now().add(const Duration(days: 180));
      
      // Format dates for the query
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      
      debugPrint('DEBUG/API: Getting tasks by month for project $projectId, date range: ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}');
      
      var query = _supabase
          .from('task')
          .select()
          .eq(TaskRow.field.project, projectId)
          .not(TaskRow.field.dateDue, 'is', null);
      
      // Add date range filter
      query = query.gte(TaskRow.field.dateDue, startStr);
      query = query.lte(TaskRow.field.dateDue, endStr);
      
      final response = await query.order(TaskRow.field.dateDue);
      
      debugPrint('DEBUG/API: Raw response contains ${response.length} task records');
      
      // Track task IDs for debugging
      final Set<String> taskIds = {};
      final Map<String, int> taskIdCounts = {};
      
      // Group tasks by month
      final Map<String, List<TaskRow>> tasksByMonth = {};
      
      for (final data in response) {
        final task = TaskRow.fromJson(data);
        
        // Count task IDs for duplication detection
        taskIdCounts[task.id] = (taskIdCounts[task.id] ?? 0) + 1;
        taskIds.add(task.id);
        
        if (task.dateDue != null) {
          // Create key in format 'yyyy-MM'
          final monthKey = '${task.dateDue!.year}-${task.dateDue!.month.toString().padLeft(2, '0')}';
          
          if (!tasksByMonth.containsKey(monthKey)) {
            tasksByMonth[monthKey] = [];
          }
          
          tasksByMonth[monthKey]!.add(task);
          _cache[task.id] = task;
        }
      }
      
      // Log detailed duplication info
      final List<String> duplicateIds = taskIdCounts.entries
          .where((entry) => entry.value > 1)
          .map((entry) => entry.key)
          .toList();
      
      debugPrint('DEBUG/API: Found ${taskIds.length} unique task IDs out of ${response.length} total tasks');
      debugPrint('DEBUG/API: ${duplicateIds.length} task IDs appear multiple times in the API response');
      
      for (var id in duplicateIds) {
        debugPrint('DEBUG/API: Task ID $id appears ${taskIdCounts[id]} times in the API response');
      }
      
      return tasksByMonth;
    } catch (error) {
      debugPrint('Error getting tasks by month: $error');
      return {};
    }
  }

  /// Gets tasks for a specific day.
  ///
  /// This method queries tasks that have a due date on the specified day.
  /// It uses a more precise date range filter to ensure only tasks for the exact day are returned.
  Future<List<TaskRow>> getTasksByDay(
    String projectId, 
    DateTime date,
  ) async {
    try {
      debugPrint('Fetching tasks for day: ${DateFormat('yyyy-MM-dd').format(date)}');

      // Normalize the date to the start of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final startOfDayStr = startOfDay.toIso8601String();
      
      // Calculate end of day (23:59:59.999)
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
      final endOfDayStr = endOfDay.toIso8601String();
      
      debugPrint('Date range: $startOfDayStr to $endOfDayStr');
      
      // Query tasks with due dates on this specific day
      final response = await _supabase
          .from('task')
          .select()
          .eq(TaskRow.field.project, projectId)
          .not(TaskRow.field.dateDue, 'is', null)
          .gte(TaskRow.field.dateDue, startOfDayStr)
          .lte(TaskRow.field.dateDue, endOfDayStr)
          .order(TaskRow.field.dateDue);
      
      debugPrint('Found ${response.length} raw task records for this day');
      
      // Use a map to deduplicate tasks by ID
      final Map<String, TaskRow> uniqueTasks = {};
      
      // Convert response to TaskRow objects and deduplicate
      for (final data in response) {
        final task = TaskRow.fromJson(data);
        uniqueTasks[task.id] = task;
        _cache[task.id] = task;
      }
      
      final tasks = uniqueTasks.values.toList();
      debugPrint('After deduplication: ${tasks.length} unique tasks');
      
      // Also add the day to the diagnostics
      for (final task in tasks) {
        debugPrint('Task ${task.id}: ${task.title}, Due: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dateDue!)}');
      }
      
      return tasks;
    } catch (error) {
      debugPrint('Error getting tasks by day: $error');
      return [];
    }
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

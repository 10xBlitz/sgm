import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_general_expense.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_summary.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling task appointment summary CRUD operations
class TaskAppointmentSummaryService {
  // Singleton instance
  static final TaskAppointmentSummaryService _instance =
      TaskAppointmentSummaryService._internal();

  // Factory constructor to return the singleton instance
  factory TaskAppointmentSummaryService() => _instance;

  // Private constructor
  TaskAppointmentSummaryService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for task appointment summary objects
  final Map<dynamic, dynamic> _cache = {};

  // Cache for task appointment per task
  final Map<dynamic, dynamic> _taskAppointmentCache = {};

  /// Creates a new task appointment summary
  Future<TaskAppointmentSummaryRow?> createTaskAppointmentSummary({
    required String taskAppointmentId,
    required String taskId,
    double? generalDeposit,
    double? generalDiscountRate,
    double? generalDiscountAmount,
    DateTime? dueDate,
    String? notes,
    required String addedBy,
    double? generalRefund,
    List<TaskAppointmentGeneralExpenseRow>? generalExpenses,
    List<Map<String, dynamic>>? procedureSummaries,
  }) async {
    try {
      // Format the JSON fields
      final Map<String, dynamic>? formattedGeneralExpenses =
          generalExpenses != null
              ? {'items': generalExpenses.map((e) => e.toJson()).toList()}
              : null;

      final Map<String, dynamic>? formattedProcedureSummaries =
          procedureSummaries != null ? {'items': procedureSummaries} : null;

      // Calculate total expense amount if general expenses are provided
      final double? totalGeneralExpenseAmount = generalExpenses?.fold<double>(
        0,
        (prev, expense) => prev + expense.amount,
      );

      final now = DateTime.now();
      final data = {
        TaskAppointmentSummaryRow.field.taskAppointmentId: taskAppointmentId,
        TaskAppointmentSummaryRow.field.taskId: taskId,
        TaskAppointmentSummaryRow.field.addedBy: addedBy,
        TaskAppointmentSummaryRow.field.taskAppointmentCreatedAt:
            now.toIso8601String(),

        if (generalDeposit != null)
          TaskAppointmentSummaryRow.field.generalDeposit: generalDeposit,
        if (generalDiscountRate != null)
          TaskAppointmentSummaryRow.field.generalDiscountRate:
              generalDiscountRate,
        if (generalDiscountAmount != null)
          TaskAppointmentSummaryRow.field.generalDiscountAmount:
              generalDiscountAmount,
        if (dueDate != null)
          TaskAppointmentSummaryRow.field.dueDate: dueDate.toIso8601String(),
        if (notes != null) TaskAppointmentSummaryRow.field.notes: notes,
        if (generalRefund != null)
          TaskAppointmentSummaryRow.field.generalRefund: generalRefund,
        if (formattedGeneralExpenses != null)
          TaskAppointmentSummaryRow.field.generalExpenses:
              formattedGeneralExpenses,
        if (totalGeneralExpenseAmount != null)
          TaskAppointmentSummaryRow.field.totalGeneralExpenseAmount:
              totalGeneralExpenseAmount,
        if (formattedProcedureSummaries != null)
          TaskAppointmentSummaryRow.field.procedureSummaries:
              formattedProcedureSummaries,
      };

      final response =
          await _supabase
              .from(TaskAppointmentSummaryRow.table)
              .insert(data)
              .select()
              .single();

      final summary = TaskAppointmentSummaryRow.fromJson(response);
      if (summary.taskAppointmentId != null) {
        _cache[summary.taskAppointmentId!] = summary;
      }

      return summary;
    } catch (error) {
      debugPrint('Error creating task appointment summary: $error');
      return null;
    }
  }

  /// Gets a task appointment summary by its ID
  Future<TaskAppointmentSummaryRow?> getFromId(
    String taskAppointmentId, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _cache.containsKey(taskAppointmentId)) {
      return _cache[taskAppointmentId];
    }

    try {
      final response =
          await _supabase
              .from(TaskAppointmentSummaryRow.table)
              .select()
              .eq(
                TaskAppointmentSummaryRow.field.taskAppointmentId,
                taskAppointmentId,
              )
              .single();

      final summary = TaskAppointmentSummaryRow.fromJson(response);
      _cache[taskAppointmentId] = summary;
      return summary;
    } catch (error) {
      debugPrint('Error fetching task appointment summary: $error');
      return null;
    }
  }

  /// Gets all task appointment summaries for a task
  Future<List<TaskAppointmentSummaryRow>> getByTaskId(
    String taskId, {
    bool cached = true,
  }) async {
    if (cached && _taskAppointmentCache.containsKey(taskId)) {
      return _taskAppointmentCache[taskId]!;
    }
    try {
      final response = await _supabase
          .from(TaskAppointmentSummaryRow.table)
          .select()
          .eq(TaskAppointmentSummaryRow.field.taskId, taskId)
          .order(
            TaskAppointmentSummaryRow.field.taskAppointmentCreatedAt,
            ascending: false,
          );

      final summaries =
          response.map<TaskAppointmentSummaryRow>((data) {
            final summary = TaskAppointmentSummaryRow.fromJson(data);
            if (summary.taskAppointmentId != null) {
              _cache[summary.taskAppointmentId!] = summary;
            }
            return summary;
          }).toList();

      _taskAppointmentCache[taskId] = summaries;

      return summaries;
    } catch (error) {
      debugPrint('Error fetching task appointment summaries: $error');
      return [];
    }
  }

  List<TaskAppointmentSummaryRow>? getByTaskIdCache(String taskId) {
    return _taskAppointmentCache[taskId];
  }

  /// Updates an existing task appointment summary
  Future<TaskAppointmentSummaryRow?> updateTaskAppointmentSummary({
    required String taskAppointmentId,
    double? generalDeposit,
    double? generalDiscountRate,
    double? generalDiscountAmount,
    DateTime? dueDate,
    String? notes,
    double? generalRefund,
    List<TaskAppointmentGeneralExpenseRow>? generalExpenses,
    List<Map<String, dynamic>>? procedureSummaries,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (generalDeposit != null) {
        data[TaskAppointmentSummaryRow.field.generalDeposit] = generalDeposit;
      }
      if (generalDiscountRate != null) {
        data[TaskAppointmentSummaryRow.field.generalDiscountRate] =
            generalDiscountRate;
      }
      if (generalDiscountAmount != null) {
        data[TaskAppointmentSummaryRow.field.generalDiscountAmount] =
            generalDiscountAmount;
      }
      if (dueDate != null) {
        data[TaskAppointmentSummaryRow.field.dueDate] =
            dueDate.toIso8601String();
      }
      if (notes != null) {
        data[TaskAppointmentSummaryRow.field.notes] = notes;
      }
      if (generalRefund != null) {
        data[TaskAppointmentSummaryRow.field.generalRefund] = generalRefund;
      }

      // Handle general expenses
      if (generalExpenses != null) {
        final formattedExpenses = {
          'items': generalExpenses.map((e) => e.toJson()).toList(),
        };
        data[TaskAppointmentSummaryRow.field.generalExpenses] =
            formattedExpenses;

        // Also update total expenses
        final totalExpense = generalExpenses.fold<double>(
          0,
          (prev, expense) => prev + expense.amount,
        );
        data[TaskAppointmentSummaryRow.field.totalGeneralExpenseAmount] =
            totalExpense;
      }

      // Handle procedure summaries
      if (procedureSummaries != null) {
        final formattedProcedures = {'items': procedureSummaries};
        data[TaskAppointmentSummaryRow.field.procedureSummaries] =
            formattedProcedures;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingSummary = await getFromId(taskAppointmentId);
        return existingSummary;
      }

      final response =
          await _supabase
              .from(TaskAppointmentSummaryRow.table)
              .update(data)
              .eq(
                TaskAppointmentSummaryRow.field.taskAppointmentId,
                taskAppointmentId,
              )
              .select()
              .single();

      final summary = TaskAppointmentSummaryRow.fromJson(response);
      if (summary.taskAppointmentId != null) {
        _cache[summary.taskAppointmentId!] = summary;
      }
      return summary;
    } catch (error) {
      debugPrint('Error updating task appointment summary: $error');
      return null;
    }
  }

  /// Deletes a task appointment summary
  Future<bool> deleteTaskAppointmentSummary(String taskAppointmentId) async {
    try {
      await _supabase
          .from(TaskAppointmentSummaryRow.table)
          .delete()
          .eq(
            TaskAppointmentSummaryRow.field.taskAppointmentId,
            taskAppointmentId,
          );

      _cache.remove(taskAppointmentId);
      return true;
    } catch (error) {
      debugPrint('Error deleting task appointment summary: $error');
      return false;
    }
  }

  /// Gets procedure summaries from a task appointment summary
  List<Map<String, dynamic>> getProcedureSummaries(
    TaskAppointmentSummaryRow summary,
  ) {
    if (summary.procedureSummaries == null) {
      return [];
    }

    try {
      final List<Map<String, dynamic>> result = [];

      if (summary.procedureSummaries is Map) {
        final procedureSummariesMap = summary.procedureSummaries as Map;
        if (procedureSummariesMap.containsKey('items')) {
          final items = procedureSummariesMap['items'] as List?;
          if (items != null) {
            for (final item in items) {
              if (item is Map) {
                result.add(Map<String, dynamic>.from(item));
              }
            }
          }
        }
      } else if (summary.procedureSummaries is List) {
        for (final item in summary.procedureSummaries as List) {
          if (item is Map) {
            result.add(Map<String, dynamic>.from(item));
          }
        }
      }

      return result;
    } catch (error) {
      debugPrint('Error parsing procedure summaries: $error');
      return [];
    }
  }

  /// Gets general expenses from a task appointment summary
  List<TaskAppointmentGeneralExpenseRow> getGeneralExpenses(
    TaskAppointmentSummaryRow summary,
  ) {
    if (summary.generalExpenses == null) {
      return [];
    }

    try {
      final List<TaskAppointmentGeneralExpenseRow> result = [];

      if (summary.generalExpenses is Map) {
        final expensesMap = summary.generalExpenses as Map;
        if (expensesMap.containsKey('items')) {
          final items = expensesMap['items'] as List?;
          if (items != null) {
            for (final item in items) {
              if (item is Map) {
                // Convert to a format compatible with TaskAppointmentGeneralExpenseRow constructor
                final convertedData = Map<String, dynamic>.from(item);

                // Generate a UUID if ID is missing
                if (convertedData['id'] == null) {
                  convertedData['id'] =
                      DateTime.now().millisecondsSinceEpoch.toString();
                }

                // Ensure required fields exist
                if (convertedData['amount'] == null) {
                  convertedData['amount'] = 0.0;
                }

                if (convertedData['created_at'] == null) {
                  convertedData['created_at'] =
                      DateTime.now().toIso8601String();
                }

                result.add(
                  TaskAppointmentGeneralExpenseRow.fromJson(convertedData),
                );
              }
            }
          }
        }
      }

      return result;
    } catch (error) {
      debugPrint('Error parsing general expenses: $error');
      return [];
    }
  }

  /// Updates procedure summaries for a task appointment summary
  Future<TaskAppointmentSummaryRow?> updateProcedureSummaries({
    required String taskAppointmentId,
    required List<Map<String, dynamic>> procedureSummaries,
  }) async {
    return updateTaskAppointmentSummary(
      taskAppointmentId: taskAppointmentId,
      procedureSummaries: procedureSummaries,
    );
  }

  /// Updates general expenses for a task appointment summary
  Future<TaskAppointmentSummaryRow?> updateGeneralExpenses({
    required String taskAppointmentId,
    required List<TaskAppointmentGeneralExpenseRow> generalExpenses,
  }) async {
    return updateTaskAppointmentSummary(
      taskAppointmentId: taskAppointmentId,
      generalExpenses: generalExpenses,
    );
  }

  /// Returns a cached task appointment summary if available
  TaskAppointmentSummaryRow? getFromCache(String taskAppointmentId) {
    return _cache[taskAppointmentId];
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

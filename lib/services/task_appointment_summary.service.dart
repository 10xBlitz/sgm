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

  /// Updates the underlying task appointment row since task_appointment_summary is a view
  Future<TaskAppointmentSummaryRow?> updateTaskAppointmentRow({
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
      // Prepare data for the task_appointment table
      final data = <String, dynamic>{};

      if (generalDeposit != null) {
        data['general_deposit'] = generalDeposit;
      }
      if (generalDiscountRate != null) {
        data['general_discount_rate'] = generalDiscountRate;
      }
      if (generalDiscountAmount != null) {
        data['general_discount_amount'] = generalDiscountAmount;
      }
      if (dueDate != null) {
        data['due_date'] = dueDate.toIso8601String();
      }
      if (notes != null) {
        data['notes'] = notes;
      }
      if (generalRefund != null) {
        data['general_refund'] = generalRefund;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingSummary = await getFromId(taskAppointmentId);
        return existingSummary;
      }

      // Update the task_appointment table directly
      await _supabase
          .from('task_appointment')
          .update(data)
          .eq('id', taskAppointmentId);

      // Handle general expenses if provided (stored in a separate table or JSON field)
      if (generalExpenses != null) {
        await _updateTaskAppointmentExpenses(
          taskAppointmentId,
          generalExpenses,
        );
      }

      // Handle procedure summaries if provided (stored in a separate table)
      if (procedureSummaries != null) {
        await _updateTaskAppointmentProcedures(
          taskAppointmentId,
          procedureSummaries,
        );
      }

      // After updating, fetch the updated summary view to return current data
      return await getFromId(taskAppointmentId, cached: false);
    } catch (error) {
      debugPrint('Error updating task appointment: $error');
      return null;
    }
  }

  /// Helper method to update task appointment expenses
  Future<void> _updateTaskAppointmentExpenses(
    String taskAppointmentId,
    List<TaskAppointmentGeneralExpenseRow> expenses,
  ) async {
    try {
      // Calculate total expense amount
      final totalExpense = expenses.fold<double>(
        0,
        (prev, expense) => prev + expense.amount,
      );

      // Update the total expense amount in the appointment
      await _supabase
          .from('task_appointment')
          .update({'total_general_expense_amount': totalExpense})
          .eq('id', taskAppointmentId);

      // For each expense, create/update in the expenses table
      for (final expense in expenses) {
        if (expense.id.startsWith('new-')) {
          // New expense to create
          final expenseData = expense.toJson();
          expenseData.remove('id'); // Remove temporary ID
          expenseData['appointment'] = taskAppointmentId; // Link to appointment

          await _supabase
              .from('task_appointment_general_expense')
              .insert(expenseData);
        } else {
          // Existing expense to update
          await _supabase
              .from('task_appointment_general_expense')
              .update(expense.toJson())
              .eq('id', expense.id);
        }
      }
    } catch (error) {
      debugPrint('Error updating task appointment expenses: $error');
    }
  }

  /// Helper method to update task appointment procedures
  Future<void> _updateTaskAppointmentProcedures(
    String taskAppointmentId,
    List<Map<String, dynamic>> procedures,
  ) async {
    try {
      // Update procedure data in the appropriate table or JSON field
      // This implementation depends on how procedures are stored in your database

      // Example approach: Store as JSON in a dedicated field
      await _supabase
          .from('task_appointment_procedure')
          .upsert(
            procedures
                .map(
                  (procedure) => {
                    ...procedure,
                    'appointment_id': taskAppointmentId,
                  },
                )
                .toList(),
            onConflict: 'id',
          );
    } catch (error) {
      debugPrint('Error updating task appointment procedures: $error');
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
    return updateTaskAppointmentRow(
      taskAppointmentId: taskAppointmentId,
      procedureSummaries: procedureSummaries,
    );
  }

  /// Updates general expenses for a task appointment summary
  Future<TaskAppointmentSummaryRow?> updateGeneralExpenses({
    required String taskAppointmentId,
    required List<TaskAppointmentGeneralExpenseRow> generalExpenses,
  }) async {
    return updateTaskAppointmentRow(
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

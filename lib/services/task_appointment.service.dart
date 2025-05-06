import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for handling task appointment CRUD operations
class TaskAppointmentService {
  // Singleton instance
  static final TaskAppointmentService _instance =
      TaskAppointmentService._internal();

  // Factory constructor to return the singleton instance
  factory TaskAppointmentService() => _instance;

  // Private constructor
  TaskAppointmentService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for task appointment objects
  final Map<dynamic, dynamic> _cache = {};

  /// Creates a new task appointment
  Future<TaskAppointmentRow?> createTaskAppointment({
    required String task,
    required double generalDeposit,
    double? generalDiscountRate,
    double? generalDiscountAmount,
    DateTime? dueDate,
    String? notes,
    String? addedBy,
    double? generalRefund,
    String? assignedClinic,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        TaskAppointmentRow.field.task: task,
        TaskAppointmentRow.field.generalDeposit: generalDeposit,
        TaskAppointmentRow.field.createdAt: now.toUtc().toIso8601String(),

        if (generalDiscountRate != null)
          TaskAppointmentRow.field.generalDiscountRate: generalDiscountRate,
        if (generalDiscountAmount != null)
          TaskAppointmentRow.field.generalDiscountAmount: generalDiscountAmount,
        if (dueDate != null)
          TaskAppointmentRow.field.dueDate: dueDate.toUtc().toIso8601String(),
        if (notes != null) TaskAppointmentRow.field.notes: notes,
        if (addedBy != null) TaskAppointmentRow.field.addedBy: addedBy,
        if (generalRefund != null)
          TaskAppointmentRow.field.generalRefund: generalRefund,
        if (assignedClinic != null)
          TaskAppointmentRow.field.assignedClinic: assignedClinic,
      };

      final response =
          await _supabase
              .from(TaskAppointmentRow.table)
              .insert(data)
              .select()
              .single();

      final appointment = TaskAppointmentRow.fromJson(response);
      _cache[appointment.id] = appointment;

      return appointment;
    } catch (error) {
      debugPrint('Error creating task appointment: $error');
      return null;
    }
  }

  /// Gets a task appointment by its ID
  Future<TaskAppointmentRow?> getFromId(String id, {bool cached = true}) async {
    // Return from cache if available and allowed
    if (cached && _cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final response =
          await _supabase
              .from(TaskAppointmentRow.table)
              .select()
              .eq(TaskAppointmentRow.field.id, id)
              .single();

      final appointment = TaskAppointmentRow.fromJson(response);
      _cache[id] = appointment;
      return appointment;
    } catch (error) {
      debugPrint('Error fetching task appointment: $error');
      return null;
    }
  }

  /// Gets all task appointments for a task
  Future<List<TaskAppointmentRow>> getByTaskId(
    String taskId, {
    bool cached = true,
  }) async {
    try {
      final response = await _supabase
          .from(TaskAppointmentRow.table)
          .select()
          .eq(TaskAppointmentRow.field.task, taskId)
          .order(TaskAppointmentRow.field.createdAt, ascending: false);

      final appointments =
          response.map<TaskAppointmentRow>((data) {
            final appointment = TaskAppointmentRow.fromJson(data);
            _cache[appointment.id] = appointment;
            return appointment;
          }).toList();

      return appointments;
    } catch (error) {
      debugPrint('Error fetching task appointments: $error');
      return [];
    }
  }

  /// Gets all task appointments for a clinic
  Future<List<TaskAppointmentRow>> getByClinicId(
    String clinicId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from(TaskAppointmentRow.table)
          .select()
          .eq(TaskAppointmentRow.field.assignedClinic, clinicId);

      if (startDate != null) {
        query = query.gte(
          TaskAppointmentRow.field.dueDate,
          startDate.toUtc().toIso8601String(),
        );
      }

      if (endDate != null) {
        query = query.lte(
          TaskAppointmentRow.field.dueDate,
          endDate.toUtc().toIso8601String(),
        );
      }

      final response = await query.order(
        TaskAppointmentRow.field.dueDate,
        ascending: false,
      );

      final appointments =
          response.map<TaskAppointmentRow>((data) {
            final appointment = TaskAppointmentRow.fromJson(data);
            _cache[appointment.id] = appointment;
            return appointment;
          }).toList();

      return appointments;
    } catch (error) {
      debugPrint('Error fetching clinic appointments: $error');
      return [];
    }
  }

  /// Updates an existing task appointment
  Future<TaskAppointmentRow?> updateTaskAppointment({
    required String id,
    double? generalDeposit,
    double? generalDiscountRate,
    double? generalDiscountAmount,
    DateTime? dueDate,
    String? notes,
    String? addedBy,
    double? generalRefund,
    String? assignedClinic,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (generalDeposit != null) {
        data[TaskAppointmentRow.field.generalDeposit] = generalDeposit;
      }

      if (generalDiscountRate != null) {
        data[TaskAppointmentRow.field.generalDiscountRate] =
            generalDiscountRate;
      }

      if (generalDiscountAmount != null) {
        data[TaskAppointmentRow.field.generalDiscountAmount] =
            generalDiscountAmount;
      }

      if (dueDate != null) {
        data[TaskAppointmentRow.field.dueDate] =
            dueDate.toUtc().toIso8601String();
      }

      if (notes != null) {
        data[TaskAppointmentRow.field.notes] = notes;
      }

      if (addedBy != null) {
        data[TaskAppointmentRow.field.addedBy] = addedBy;
      }

      if (generalRefund != null) {
        data[TaskAppointmentRow.field.generalRefund] = generalRefund;
      }

      if (assignedClinic != null) {
        data[TaskAppointmentRow.field.assignedClinic] = assignedClinic;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingAppointment = await getFromId(id);
        return existingAppointment;
      }

      final response =
          await _supabase
              .from(TaskAppointmentRow.table)
              .update(data)
              .eq(TaskAppointmentRow.field.id, id)
              .select()
              .single();

      final appointment = TaskAppointmentRow.fromJson(response);
      _cache[id] = appointment;
      return appointment;
    } catch (error) {
      debugPrint('Error updating task appointment: $error');
      return null;
    }
  }

  /// Deletes a task appointment
  Future<bool> deleteTaskAppointment(String id) async {
    try {
      await _supabase
          .from(TaskAppointmentRow.table)
          .delete()
          .eq(TaskAppointmentRow.field.id, id);

      _cache.remove(id);
      return true;
    } catch (error) {
      debugPrint('Error deleting task appointment: $error');
      return false;
    }
  }

  /// Searches for task appointments by date range
  Future<List<TaskAppointmentRow>> searchByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from(TaskAppointmentRow.table)
          .select()
          .gte(
            TaskAppointmentRow.field.dueDate,
            startDate.toUtc().toIso8601String(),
          )
          .lte(
            TaskAppointmentRow.field.dueDate,
            endDate.toUtc().toIso8601String(),
          )
          .order(TaskAppointmentRow.field.dueDate);

      final appointments =
          response.map<TaskAppointmentRow>((data) {
            final appointment = TaskAppointmentRow.fromJson(data);
            _cache[appointment.id] = appointment;
            return appointment;
          }).toList();

      return appointments;
    } catch (error) {
      debugPrint('Error searching appointments by date range: $error');
      return [];
    }
  }

  /// Returns a cached task appointment if available
  TaskAppointmentRow? getFromCache(String id) {
    return _cache[id];
  }

  /// Returns cached task appointments for a task if available
  List<TaskAppointmentRow> getByTaskIdCache(String taskId) {
    final appointments = <TaskAppointmentRow>[];

    _cache.forEach((key, value) {
      if (value is TaskAppointmentRow && value.task == taskId) {
        appointments.add(value);
      }
    });

    return appointments;
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

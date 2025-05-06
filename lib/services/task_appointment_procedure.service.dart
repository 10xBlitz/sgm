import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_procedure.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling task appointment procedure CRUD operations
class TaskAppointmentProcedureService {
  // Singleton instance
  static final TaskAppointmentProcedureService _instance =
      TaskAppointmentProcedureService._internal();

  // Factory constructor to return the singleton instance
  factory TaskAppointmentProcedureService() => _instance;

  // Private constructor
  TaskAppointmentProcedureService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for task appointment procedure objects
  final Map<String, TaskAppointmentProcedureRow> _cache = {};

  // Cache for appointment procedures
  final Map<String, List<TaskAppointmentProcedureRow>> _appointmentCache = {};

  /// Creates a new task appointment procedure
  Future<TaskAppointmentProcedureRow?> createProcedure({
    required String appointment,
    String? procedure,
    String? procedureName,
    required double procedurePrice,
    required double procedureCommission,
    double? discountRate,
    required double discountAmount,
    String? createdBy,
    String? clinic,
    double? refundAmount,
    DateTime? paidOn,
    double? commissionEnteredByUser,
    double? originalProcedurePrice,
    String? notes,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        TaskAppointmentProcedureRow.field.appointment: appointment,
        TaskAppointmentProcedureRow.field.procedurePrice: procedurePrice,
        TaskAppointmentProcedureRow.field.procedureCommission:
            procedureCommission,
        TaskAppointmentProcedureRow.field.discountAmount: discountAmount,
        TaskAppointmentProcedureRow.field.createdAt:
            now.toUtc().toIso8601String(),

        if (procedure != null)
          TaskAppointmentProcedureRow.field.procedure: procedure,
        if (procedureName != null)
          TaskAppointmentProcedureRow.field.procedureName: procedureName,
        if (discountRate != null)
          TaskAppointmentProcedureRow.field.discountRate: discountRate,
        if (createdBy != null)
          TaskAppointmentProcedureRow.field.createdBy: createdBy,
        if (clinic != null) TaskAppointmentProcedureRow.field.clinic: clinic,
        if (refundAmount != null)
          TaskAppointmentProcedureRow.field.refundAmount: refundAmount,
        if (paidOn != null)
          TaskAppointmentProcedureRow.field.paidOn:
              paidOn.toUtc().toIso8601String(),
        if (commissionEnteredByUser != null)
          TaskAppointmentProcedureRow.field.commissionEnteredByUser:
              commissionEnteredByUser,
        if (originalProcedurePrice != null)
          TaskAppointmentProcedureRow.field.originalProcedurePrice:
              originalProcedurePrice,
        if (notes != null) TaskAppointmentProcedureRow.field.notes: notes,
      };

      final response =
          await _supabase
              .from(TaskAppointmentProcedureRow.table)
              .insert(data)
              .select()
              .single();

      final procedureRow = TaskAppointmentProcedureRow.fromJson(response);
      _cache[procedureRow.id] = procedureRow;

      // Update appointment cache
      if (_appointmentCache.containsKey(appointment)) {
        _appointmentCache[appointment]!.add(procedureRow);
      }

      return procedureRow;
    } catch (error) {
      debugPrint('Error creating task appointment procedure: $error');
      return null;
    }
  }

  /// Gets a task appointment procedure by its ID
  Future<TaskAppointmentProcedureRow?> getFromId(
    String id, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final response =
          await _supabase
              .from(TaskAppointmentProcedureRow.table)
              .select()
              .eq(TaskAppointmentProcedureRow.field.id, id)
              .single();

      final procedureRow = TaskAppointmentProcedureRow.fromJson(response);
      _cache[id] = procedureRow;
      return procedureRow;
    } catch (error) {
      debugPrint('Error fetching task appointment procedure: $error');
      return null;
    }
  }

  /// Gets all procedures for an appointment
  Future<List<TaskAppointmentProcedureRow>> getByAppointmentId(
    String appointmentId, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _appointmentCache.containsKey(appointmentId)) {
      return _appointmentCache[appointmentId]!;
    }

    try {
      final response = await _supabase
          .from(TaskAppointmentProcedureRow.table)
          .select()
          .eq(TaskAppointmentProcedureRow.field.appointment, appointmentId)
          .order(TaskAppointmentProcedureRow.field.createdAt, ascending: false);

      final procedures =
          response.map<TaskAppointmentProcedureRow>((data) {
            final proc = TaskAppointmentProcedureRow.fromJson(data);
            _cache[proc.id] = proc;
            return proc;
          }).toList();

      _appointmentCache[appointmentId] = procedures;
      return procedures;
    } catch (error) {
      debugPrint('Error fetching procedures for appointment: $error');
      return [];
    }
  }

  /// Gets all procedures for a clinic
  Future<List<TaskAppointmentProcedureRow>> getByClinicId(
    String clinicId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from(TaskAppointmentProcedureRow.table)
          .select()
          .eq(TaskAppointmentProcedureRow.field.clinic, clinicId);

      if (startDate != null) {
        query = query.gte(
          TaskAppointmentProcedureRow.field.createdAt,
          startDate.toUtc().toIso8601String(),
        );
      }

      if (endDate != null) {
        query = query.lte(
          TaskAppointmentProcedureRow.field.createdAt,
          endDate.toUtc().toIso8601String(),
        );
      }

      final response = await query.order(
        TaskAppointmentProcedureRow.field.createdAt,
        ascending: false,
      );

      final procedures =
          response.map<TaskAppointmentProcedureRow>((data) {
            final proc = TaskAppointmentProcedureRow.fromJson(data);
            _cache[proc.id] = proc;
            return proc;
          }).toList();

      return procedures;
    } catch (error) {
      debugPrint('Error fetching procedures for clinic: $error');
      return [];
    }
  }

  /// Updates an existing task appointment procedure
  Future<TaskAppointmentProcedureRow?> updateProcedure({
    required String id,
    String? procedure,
    String? procedureName,
    double? procedurePrice,
    double? procedureCommission,
    double? discountRate,
    double? discountAmount,
    String? clinic,
    double? refundAmount,
    DateTime? paidOn,
    double? commissionEnteredByUser,
    double? originalProcedurePrice,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (procedure != null) {
        data[TaskAppointmentProcedureRow.field.procedure] = procedure;
      }

      if (procedureName != null) {
        data[TaskAppointmentProcedureRow.field.procedureName] = procedureName;
      }

      if (procedurePrice != null) {
        data[TaskAppointmentProcedureRow.field.procedurePrice] = procedurePrice;
      }

      if (procedureCommission != null) {
        data[TaskAppointmentProcedureRow.field.procedureCommission] =
            procedureCommission;
      }

      if (discountRate != null) {
        data[TaskAppointmentProcedureRow.field.discountRate] = discountRate;
      }

      if (discountAmount != null) {
        data[TaskAppointmentProcedureRow.field.discountAmount] = discountAmount;
      }

      if (clinic != null) {
        data[TaskAppointmentProcedureRow.field.clinic] = clinic;
      }

      if (refundAmount != null) {
        data[TaskAppointmentProcedureRow.field.refundAmount] = refundAmount;
      }

      if (paidOn != null) {
        data[TaskAppointmentProcedureRow.field.paidOn] =
            paidOn.toUtc().toIso8601String();
      }

      if (commissionEnteredByUser != null) {
        data[TaskAppointmentProcedureRow.field.commissionEnteredByUser] =
            commissionEnteredByUser;
      }

      if (originalProcedurePrice != null) {
        data[TaskAppointmentProcedureRow.field.originalProcedurePrice] =
            originalProcedurePrice;
      }

      if (notes != null) {
        data[TaskAppointmentProcedureRow.field.notes] = notes;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingProcedure = await getFromId(id);
        return existingProcedure;
      }

      final response =
          await _supabase
              .from(TaskAppointmentProcedureRow.table)
              .update(data)
              .eq(TaskAppointmentProcedureRow.field.id, id)
              .select()
              .single();

      final procedureRow = TaskAppointmentProcedureRow.fromJson(response);
      _cache[id] = procedureRow;

      // Update appointment cache
      if (_appointmentCache.containsKey(procedureRow.appointment)) {
        final index = _appointmentCache[procedureRow.appointment]!.indexWhere(
          (p) => p.id == id,
        );
        if (index >= 0) {
          _appointmentCache[procedureRow.appointment]![index] = procedureRow;
        }
      }

      return procedureRow;
    } catch (error) {
      debugPrint('Error updating task appointment procedure: $error');
      return null;
    }
  }

  /// Updates the paid status of a procedure
  Future<TaskAppointmentProcedureRow?> markAsPaid({
    required String id,
    required DateTime paidOn,
  }) async {
    return updateProcedure(id: id, paidOn: paidOn);
  }

  /// Deletes a task appointment procedure
  Future<bool> deleteProcedure(String id) async {
    try {
      // Get procedure first for cache management
      final procedure = await getFromId(id);

      await _supabase
          .from(TaskAppointmentProcedureRow.table)
          .delete()
          .eq(TaskAppointmentProcedureRow.field.id, id);

      // Update caches
      _cache.remove(id);

      if (procedure != null &&
          _appointmentCache.containsKey(procedure.appointment)) {
        _appointmentCache[procedure.appointment] =
            _appointmentCache[procedure.appointment]!
                .where((p) => p.id != id)
                .toList();
      }

      return true;
    } catch (error) {
      debugPrint('Error deleting task appointment procedure: $error');
      return false;
    }
  }

  /// Gets the total procedure amount for an appointment
  Future<double> getTotalProcedureAmount(String appointmentId) async {
    final procedures = await getByAppointmentId(appointmentId);
    return procedures.fold<double>(
      0,
      (total, proc) => total + proc.procedurePrice - proc.discountAmount,
    );
  }

  /// Gets the total commission amount for an appointment
  Future<double> getTotalCommissionAmount(String appointmentId) async {
    final procedures = await getByAppointmentId(appointmentId);
    return procedures.fold<double>(
      0,
      (total, proc) => total + proc.procedureCommission,
    );
  }

  /// Returns cached procedures for an appointment if available
  List<TaskAppointmentProcedureRow>? getByAppointmentIdCache(
    String appointmentId,
  ) {
    return _appointmentCache[appointmentId];
  }

  /// Returns a cached procedure if available
  TaskAppointmentProcedureRow? getFromCache(String id) {
    return _cache[id];
  }

  /// Clears all caches
  void clearCache() {
    _cache.clear();
    _appointmentCache.clear();
  }

  /// Clears cache for a specific appointment
  void clearAppointmentCache(String appointmentId) {
    _appointmentCache.remove(appointmentId);
    // Also clear individual procedures from this appointment
    _cache.removeWhere((key, value) => value.appointment == appointmentId);
  }
}

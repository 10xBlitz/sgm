import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class ProjectTaskStatusService {
  // Singleton instance
  static final ProjectTaskStatusService _instance = ProjectTaskStatusService._internal();

  // Factory constructor to return the singleton instance
  factory ProjectTaskStatusService() => _instance;

  // Private constructor
  ProjectTaskStatusService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Explicitly typed cache
  //
  /// Map&lt;String, dynamic&gt; is having error
  /// Need to make issue in Flutter
  final Map _cache = {};

  List<ProjectTaskStatusRow>? _clinicsCache;

  Future<List<ProjectTaskStatusRow>> getStatusByProjectID(String projectId) async {
    try {
      final response = await _supabase
          .from(ProjectTaskStatusRow.table)
          .select()
          .eq(ProjectTaskStatusRow.field.project, projectId)
          .order(ProjectTaskStatusRow.field.order);

      final statuses = (response as List)
          .map((json) => ProjectTaskStatusRow.fromJson(json))
          .toList();
      return statuses;
    } catch (e) {
      throw Exception('Failed to fetch project task statuses: $e');
    }
  }

  /// Creates a new status for a project
  Future<ProjectTaskStatusRow> createNewStatus(String projectId) async {
    try {
      // Get the highest order number
      final existingStatuses = await getStatusByProjectID(projectId);
      final highestOrder = existingStatuses.isEmpty 
          ? 0 
          : existingStatuses.map((s) => s.order ?? 0).reduce((a, b) => a > b ? a : b);

      final now = DateTime.now();
      final data = {
        ProjectTaskStatusRow.field.status: 'new',
        ProjectTaskStatusRow.field.order: highestOrder + 1,
        ProjectTaskStatusRow.field.project: projectId,
        ProjectTaskStatusRow.field.forNullStatus: false,
        ProjectTaskStatusRow.field.createdAt: now.toIso8601String(),
        ProjectTaskStatusRow.field.sysCreatedAt: now.toIso8601String(),
      };

      final response = await _supabase
          .from(ProjectTaskStatusRow.table)
          .insert(data)
          .select()
          .single();

      return ProjectTaskStatusRow.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create new status: $e');
    }
  }

  /// Gets the "new" status for a project or creates it if it doesn't exist
  Future<ProjectTaskStatusRow> getOrCreateNewStatus(String projectId) async {
    try {
      // Try to get existing "new" status
      final response = await _supabase
          .from(ProjectTaskStatusRow.table)
          .select()
          .eq(ProjectTaskStatusRow.field.project, projectId)
          .eq(ProjectTaskStatusRow.field.status, 'new')
          .maybeSingle();

      if (response != null) {
        return ProjectTaskStatusRow.fromJson(response);
      }

      // If no "new" status exists, create one
      return createNewStatus(projectId);
    } catch (e) {
      throw Exception('Failed to get or create new status: $e');
    }
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}
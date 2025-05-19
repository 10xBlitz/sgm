import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectTaskStatusService {
  // Singleton instance
  static final ProjectTaskStatusService _instance =
      ProjectTaskStatusService._internal();

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

  List<ProjectTaskStatusRow>? clinicsCache;

  Future<List<ProjectTaskStatusRow>> getStatusByProjectID(
    String projectId,
  ) async {
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

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

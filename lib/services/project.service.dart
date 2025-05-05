import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling project-related operations with Supabase.
class ProjectService {
  // Singleton instance
  static final ProjectService _instance = ProjectService._internal();

  // Factory constructor to return the singleton instance
  factory ProjectService() => _instance;

  // Private constructor
  ProjectService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Explicitly typed cache
  //
  /// Map&lt;String, dynamic&gt; is having error
  /// Need to make issue in Flutter
  final Map _cache = {};

  /// Creates a new project in the database.
  Future<ProjectRow?> createProject({
    required String title,
    required String description,
    String? status,
    required bool isClinic,
    String? area,
    required String createdBy,
  }) async {
    try {
      final data = {
        ProjectRow.field.title: title,
        ProjectRow.field.description: description,
        ProjectRow.field.status: status ?? 'New',
        ProjectRow.field.isClinic: isClinic,
        ProjectRow.field.createdBy: createdBy,
        ProjectRow.field.area: area,
        ProjectRow.field.canChooseOtherClinic: !isClinic, // Default logic
      };

      final response =
          await _supabase.from('project').insert(data).select().single();

      final project = ProjectRow.fromJson(response);
      _cache[project.id] = data;
      return project;
    } catch (error) {
      debugPrint('Error creating project: $error');
      return null;
    }
  }

  /// Gets a project by its ID.
  Future<ProjectRow?> getFromId(String id, {bool cached = true}) async {
    if (cached && _cache[id] != null) {
      return ProjectRow.fromJson(_cache[id]!);
    }
    try {
      final response =
          await _supabase
              .from('project')
              .select()
              .eq(ProjectRow.field.id, id)
              .single();
      final project = ProjectRow.fromJson(response);
      _cache[id] = response;
      return project;
    } catch (error) {
      debugPrint('Error fetching project by ID: $error');
      return null;
    }
  }

  ProjectRow? getFromCache(String id) {
    return _cache[id] != null ? ProjectRow.fromJson(_cache[id]!) : null;
  }

  /// Gets all projects with optional filtering by isClinic.
  Future<List<ProjectRow>> getAllProjects({bool? isClinic}) async {
    try {
      var query = _supabase.from('project').select();

      if (isClinic != null) {
        query = query.eq(ProjectRow.field.isClinic, isClinic);
      }

      final response = await query.order(
        ProjectRow.field.createdAt,
        ascending: false,
      );

      final projects =
          response.map<ProjectRow>((Map<String, dynamic> data) {
            try {
              final project = ProjectRow.fromJson(data);
              _cache[project.id] = Map<String, dynamic>.from(data);
              return project;
            } catch (e) {
              debugPrint('Error converting project data: $e');
              debugPrint('Problematic data: $data');
              rethrow;
            }
          }).toList();

      return projects;
    } catch (error) {
      debugPrint('Error fetching projects (getAllProjects): $error');
      return [];
    }
  }

  /// Updates an existing project in the database.
  Future<ProjectRow?> updateProject({
    required String id,
    String? title,
    String? description,
    String? status,
    bool? isClinic,
    String? area,
    bool? canChooseOtherClinic,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Only include fields that are provided
      if (title != null) data[ProjectRow.field.title] = title;
      if (description != null) data[ProjectRow.field.description] = description;
      if (status != null) data[ProjectRow.field.status] = status;
      if (isClinic != null) data[ProjectRow.field.isClinic] = isClinic;
      if (area != null) data[ProjectRow.field.area] = area;
      if (canChooseOtherClinic != null) {
        data[ProjectRow.field.canChooseOtherClinic] = canChooseOtherClinic;
      }

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingProject = await getFromId(id);
        return existingProject;
      }
      final response =
          await _supabase
              .from('project')
              .update(data)
              .eq(ProjectRow.field.id, id)
              .select()
              .single();

      final project = ProjectRow.fromJson(response);
      _cache[id] = Map<String, dynamic>.from(response);

      return project;
    } catch (error) {
      debugPrint('Error updating project: $error');
      return null;
    }
  }

  /// Deletes a project from the database.
  Future<bool> deleteProject(String id) async {
    try {
      await _supabase.from('project').delete().eq(ProjectRow.field.id, id);
      _cache.remove(id);
      return true;
    } catch (error) {
      debugPrint('Error deleting project: $error');
      return false;
    }
  }

  /// Searches projects by title and description.
  Future<List<ProjectRow>> searchProjects(String query) async {
    try {
      final response = await _supabase
          .from('project')
          .select()
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order(ProjectRow.field.createdAt, ascending: false);

      final projects =
          response.map<ProjectRow>((data) {
            final project = ProjectRow.fromJson(data);
            _cache[project.id] = data;
            return project;
          }).toList();

      return projects;
    } catch (error) {
      debugPrint('Error searching projects: $error');
      return [];
    }
  }

  /// Clears the cache
  void clearCache() {
    _cache.clear();
  }
}

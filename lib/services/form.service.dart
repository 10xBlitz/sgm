import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/form.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling form-related operations with Supabase.
class FormService {
  // Singleton instance
  static final FormService _instance = FormService._internal();

  // Factory constructor to return the singleton instance
  factory FormService() => _instance;

  // Private constructor
  FormService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  /// Creates a new form in the database.
  Future<FormRow?> createForm({
    required String name,
    String? linkedProject,
    String? url,
    String? description,
    String? createdBy,
    String? redirectLinkAfterFillout,
    String? customFormName,
    String? previewImage,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        FormRow.field.name: name,
        FormRow.field.linkedProject: linkedProject,
        FormRow.field.url: url,
        FormRow.field.description: description,
        FormRow.field.createdAt: now.toIso8601String(),
        FormRow.field.updatedAt: now.toIso8601String(),
        FormRow.field.createdBy: createdBy,
        FormRow.field.redirectLinkAfterFillout: redirectLinkAfterFillout,
        FormRow.field.customFormName: customFormName,
        FormRow.field.previewImage: previewImage,
      };

      final response =
          await _supabase.from(FormRow.table).insert(data).select().single();
      return FormRow.fromJson(response);
    } catch (error) {
      debugPrint('Error creating form: $error');
      return null;
    }
  }

  /// Gets all forms for a specific project.
  Future<List<FormRow>> getFormsByProject(String projectId) async {
    try {
      final response = await _supabase
          .from(FormRow.table)
          .select()
          .eq(FormRow.field.linkedProject, projectId)
          .order(FormRow.field.createdAt, ascending: false);
      return response.map<FormRow>((f) => FormRow.fromJson(f)).toList();
    } catch (e) {
      debugPrint('Error fetching forms for project: $e');
      return [];
    }
  }

  /// Gets a single form by its ID.
  Future<FormRow?> getForm(String id) async {
    try {
      final response =
          await _supabase
              .from(FormRow.table)
              .select()
              .eq(FormRow.field.id, id)
              .single();
      return FormRow.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching form by ID: $e');
      return null;
    }
  }
}

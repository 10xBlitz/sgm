import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/task_form_response.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskFormService {
  static final TaskFormService _instance = TaskFormService._internal();

  factory TaskFormService() => _instance;

  TaskFormService._internal();

  final _supabase = Supabase.instance.client;

  /// Creates a single task form response in the database.
  Future<TaskFormResponseRow?> createResponse({
    required String taskId,
    required String questionId,
    String? answer,
    List<String>? images,
    List<String>? checkedBox,
    String? sysNotes,
    String? questionText,
    bool photoConverted = false,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        TaskFormResponseRow.field.task: taskId,
        TaskFormResponseRow.field.question: questionId,
        TaskFormResponseRow.field.answer: answer,
        TaskFormResponseRow.field.images: images,
        TaskFormResponseRow.field.checkedBox: checkedBox,
        TaskFormResponseRow.field.sysNotes: sysNotes,
        TaskFormResponseRow.field.questionText: questionText,
        TaskFormResponseRow.field.photoConverted: photoConverted,
        TaskFormResponseRow.field.createdAt: now.toIso8601String(),
      };
      final response =
          await _supabase
              .from(TaskFormResponseRow.table)
              .insert(data)
              .select()
              .single();
      return TaskFormResponseRow.fromJson(response);
    } catch (error) {
      debugPrint('Error creating task form response: $error');
      return null;
    }
  }

  /// Fetches a single response for a given task and question.
  Future<TaskFormResponseRow?> fetchResponseForQuestion({
    required String taskId,
    required String questionId,
  }) async {
    try {
      final response =
          await _supabase
              .from(TaskFormResponseRow.table)
              .select()
              .eq(TaskFormResponseRow.field.task, taskId)
              .eq(TaskFormResponseRow.field.question, questionId)
              .limit(1)
              .maybeSingle();
      if (response == null) return null;
      return TaskFormResponseRow.fromJson(response);
    } catch (error) {
      debugPrint('Error fetching response for question: $error');
      return null;
    }
  }

  /// Fetches all responses for a given task.
  Future<List<TaskFormResponseRow>> fetchResponsesForTask(String taskId) async {
    try {
      final response = await _supabase
          .from(TaskFormResponseRow.table)
          .select()
          .eq(TaskFormResponseRow.field.task, taskId);
      return (response as List)
          .map((e) => TaskFormResponseRow.fromJson(e))
          .toList();
    } catch (error) {
      debugPrint('Error fetching responses for task: $error');
      return [];
    }
  }

  /// Fetches all responses for a given question and task.
  Future<List<TaskFormResponseRow>> fetchResponsesForQuestionAndTask({
    required String taskId,
    required String questionId,
  }) async {
    try {
      final response = await _supabase
          .from(TaskFormResponseRow.table)
          .select()
          .eq(TaskFormResponseRow.field.task, taskId)
          .eq(TaskFormResponseRow.field.question, questionId);
      return (response as List)
          .map((e) => TaskFormResponseRow.fromJson(e))
          .toList();
    } catch (error) {
      debugPrint('Error fetching responses for question and task: $error');
      return [];
    }
  }
}

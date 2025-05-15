import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/widgets/form/dialog/add_form_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormQuestionService {
  // Singleton instance
  static final FormQuestionService _instance = FormQuestionService._internal();
  factory FormQuestionService() => _instance;
  FormQuestionService._internal();

  final _supabase = Supabase.instance.client;

  /// Creates a single form question in the database.
  Future<FormQuestionRow?> createQuestion({
    required String formId,
    required String question,
    String? description,
    required QuestionType type,
    bool isRequired = false,
    int? order,
    List<String>? checkboxOptions,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        FormQuestionRow.field.form: formId,
        FormQuestionRow.field.question: question,
        FormQuestionRow.field.description: description,
        FormQuestionRow.field.type: _questionTypeToString(type),
        FormQuestionRow.field.isRequired: isRequired,
        FormQuestionRow.field.createdAt: now.toIso8601String(),
        FormQuestionRow.field.updatedAt: now.toIso8601String(),
        FormQuestionRow.field.order: order,
        FormQuestionRow.field.checkboxOptions: checkboxOptions,
      };
      final response = await _supabase.from(FormQuestionRow.table).insert(data).select().single();
      return FormQuestionRow.fromJson(response);
    } catch (error) {
      debugPrint('Error creating form question: $error');
      return null;
    }
  }

  /// Creates multiple form questions in the database.
  Future<List<FormQuestionRow>> createQuestions({
    required String formId,
    required List<Map<String, dynamic>> questions,
  }) async {
    final now = DateTime.now();
    final data = questions.map((q) {
      return {
        FormQuestionRow.field.form: formId,
        FormQuestionRow.field.question: q['question'],
        FormQuestionRow.field.description: q['description'],
        FormQuestionRow.field.type: _questionTypeToString(q['type']),
        FormQuestionRow.field.isRequired: q['isRequired'] ?? false,
        FormQuestionRow.field.createdAt: now.toIso8601String(),
        FormQuestionRow.field.updatedAt: now.toIso8601String(),
        FormQuestionRow.field.order: q['order'],
        FormQuestionRow.field.checkboxOptions: q['checkboxOptions'],
      };
    }).toList();
    try {
      final response = await _supabase.from(FormQuestionRow.table).insert(data).select();
      return (response as List).map((e) => FormQuestionRow.fromJson(e)).toList();
    } catch (error) {
      debugPrint('Error creating form questions: $error');
      return [];
    }
  }

  String _questionTypeToString(QuestionType type) {
    switch (type) {
      case QuestionType.text:
        return 'text';
      case QuestionType.checkbox:
        return 'checkbox';
      case QuestionType.attachment:
        return 'attachment';
    }
  }
} 
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

  // get task anwser and question from task
  // Future<List<dynamic>> getTaskQuestion(String taskId) async {
  //
  // }
} 
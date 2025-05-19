import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_form_response.row.dart';

class TaskUserAnswer {
  final FormQuestionRow question;
  final TaskFormResponseRow? response;

  TaskUserAnswer({required this.question, this.response});

  String? get textAnswer => response?.answer;
  List<String>? get checkboxAnswers => response?.checkedBox;
  List<String>? get attachments => response?.images;

  String get type => question.type ?? 'text';
} 
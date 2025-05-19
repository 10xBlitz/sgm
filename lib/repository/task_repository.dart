import 'package:sgm/row_row_row_generated/tables/form_question.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_form_response.row.dart';
import 'package:sgm/models/task_user_answer.dart';
import 'package:sgm/services/form_question.service.dart';
import 'package:sgm/services/task_form_response.service.dart';

class TaskRepository {
  // singleton
  static final TaskRepository _instance = TaskRepository._internal();

  factory TaskRepository() {
    return _instance;
  }

  TaskRepository._internal();

  Future<List<TaskUserAnswer>> getAnswersForTask({
    required String formId,
    required String taskId,
  }) async {
    final questions = await _fetchQuestionsByForm(formId);
    final List<TaskUserAnswer> result = [];
    for (final question in questions) {
      final response = await _fetchResponseForQuestion(taskId, question.id);
      result.add(TaskUserAnswer(question: question, response: response));
    }
    result;
    // order by date
    result.sort((b, a) {
      final dateA = a.response?.createdAt ?? DateTime.now();
      final dateB = b.response?.createdAt ?? DateTime.now();
      return dateB.compareTo(dateA);
    });
    return result;
  }

  Future<List<FormQuestionRow>> _fetchQuestionsByForm(String formId) async {
    return FormQuestionService().fetchQuestionsByForm(formId);
  }

  Future<TaskFormResponseRow?> _fetchResponseForQuestion(
    String taskId,
    String questionId,
  ) async {
    final response = await TaskFormService().fetchResponsesForQuestionAndTask(
      taskId: taskId,
      questionId: questionId,
    );
    return response.isNotEmpty ? response.first : null;
  }
}

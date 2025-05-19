import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:intl/intl.dart';
import 'package:sgm/models/task_user_answer.dart';

class TaskCustomerDetail extends StatelessWidget {
  const TaskCustomerDetail({super.key, required this.task, this.answers});

  final TaskRow task;
  final List<TaskUserAnswer>? answers;

  @override
  Widget build(BuildContext context) {
    MyLogger.d('TaskCustomerDetail Task ID: \u001b[33m${task.id}\u001b[0m');
    return Card(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.customerName ?? '-', style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD1B36A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomerStaticDetails(task: task),
            const SizedBox(height: 16),
            if (task.form != null) CustomerDynamicAnswers(answers: answers),
          ],
        ),
      ),
    );
  }
}

class CustomerStaticDetails extends StatelessWidget {
  const CustomerStaticDetails({super.key, required this.task});

  final TaskRow task;

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailItem(label: 'Name', value: task.customerName),
        _DetailItem(label: 'DOB', value: _formatDate(task.customerBirthday)),
        _DetailItem(label: 'Gender', value: task.customerGender),
        _DetailItem(label: 'Nationality', value: task.customerNationality),
        _DetailItem(label: 'Country of residence', value: task.customerCountryResidence),
        _DetailItem(label: 'Phone number', value: task.customerPhone),
      ],
    );
  }
}

class CustomerDynamicAnswers extends StatelessWidget {
  const CustomerDynamicAnswers({super.key, required this.answers});

  final List<TaskUserAnswer>? answers;

  @override
  Widget build(BuildContext context) {
    if (answers == null || answers!.isEmpty) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: answers!.map((answer) => CustomerAnswerItem(answer: answer)).toList(),
    );
  }
}

class CustomerAnswerItem extends StatelessWidget {
  const CustomerAnswerItem({super.key, required this.answer});

  final TaskUserAnswer answer;

  @override
  Widget build(BuildContext context) {
    final type = answer.type;
    final questionText = answer.question.question ?? '-';
    Widget answerWidget;
    switch (type) {
      case 'text':
        answerWidget = _TextAnswerWidget(text: answer.textAnswer);
        break;
      case 'checkbox':
        answerWidget = _CheckboxAnswerWidget(
          options: answer.question.checkboxOptions ?? [],
          checked: answer.checkboxAnswers ?? [],
        );
        break;
      case 'attachment':
        answerWidget = _AttachmentAnswerWidget(images: answer.attachments ?? []);
        break;
      default:
        answerWidget = _DefaultAnswerWidget();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(questionText, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey, fontSize: 15)),
          const SizedBox(height: 2),
          answerWidget,
        ],
      ),
    );
  }
}

class _TextAnswerWidget extends StatelessWidget {
  const _TextAnswerWidget({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Text(text ?? '-', style: const TextStyle(fontSize: 16));
  }
}

class _CheckboxAnswerWidget extends StatelessWidget {
  const _CheckboxAnswerWidget({required this.options, required this.checked});

  final List<String> options;
  final List<String> checked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          options
              .map(
                (opt) => Row(
                  children: [
                    Icon(
                      checked.contains(opt) ? Icons.check_box : Icons.check_box_outline_blank,
                      color: checked.contains(opt) ? const Color(0xFFD1B36A) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(opt, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              )
              .toList(),
    );
  }
}

class _AttachmentAnswerWidget extends StatelessWidget {
  const _AttachmentAnswerWidget({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children:
          images
              .map(
                (imgUrl) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _DefaultAnswerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('-', style: TextStyle(fontSize: 16));
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blueGrey, fontSize: 15)),
          const SizedBox(height: 2),
          Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black, fontSize: 16)),
        ],
      ),
    );
  }
}

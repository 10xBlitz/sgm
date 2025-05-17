import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';

class TaskAdditionalInfo extends StatelessWidget {
  const TaskAdditionalInfo({super.key, required this.task, this.assignee});

  final TaskRow task;
  final UserRow? assignee;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.title ?? '-', style: Theme.of(context).textTheme.titleLarge),
                // You can add an Edit button here if needed, similar to TaskCustomerDetail
              ],
            ),
            const SizedBox(height: 16),
            _DetailItem(label: 'Task title', value: task.title),
            _DetailItem(label: 'Assignee', value: assignee?.name ?? '-'),
          ],
        ),
      ),
    );
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

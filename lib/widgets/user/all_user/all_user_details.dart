import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/quill_editor/quill_editor.dart';

class AllUserDetails extends StatelessWidget {
  final UserWithProjectsRow user;
  const AllUserDetails({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final details = user.details;

    if (details == null || (details is List && details.isEmpty)) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'No additional details available',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: WYSIWYGEditor(
              width: MediaQuery.of(context).size.width - 32,
              height: 400,
              contentJsonString: details,
              onSaveClicked: (content) async {
                // Handle save action
                _handleSave(content);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave(String content) {
    debugPrint('Saving content: $content');
    UserService().updateUserDetails(user.id!, content);
  }
}

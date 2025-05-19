import 'package:flutter/material.dart';
import 'package:sgm/widgets/item/item_projects.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectsListAllTab extends StatefulWidget {
  const ProjectsListAllTab({super.key, this.onTapProject});

  final Future<void> Function(ProjectRow)? onTapProject;

  @override
  State<ProjectsListAllTab> createState() => _ProjectsListAllTabState();
}

class _ProjectsListAllTabState extends State<ProjectsListAllTab> {
  // Supabase auth id

  final String supabaseAuthId =
      Supabase.instance.client.auth.currentUser?.id ?? '';

  final ProjectService projectService = ProjectService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (supabaseAuthId.isEmpty) {
      return Center(
        child: Text(
          'User not authenticated',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      );
    }

    return FutureBuilder<List<ProjectRow>>(
      future: projectService.getAllProjects(isClinic: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading projects: ${snapshot.error}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Text(
              'No projects found',
              style: theme.textTheme.titleMedium,
            ),
          );
        }

        return ListView.separated(
          itemCount: projects.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final project = projects[index];
            return ItemProject(item: project, onTap: () => widget.onTapProject?.call(project), theme: theme);
          },
        );
      },
    );
  }
}

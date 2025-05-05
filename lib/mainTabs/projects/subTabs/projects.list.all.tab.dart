import 'package:flutter/material.dart';
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
      future: projectService.getAllProjects(),
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
            return InkWell(
              onTap: () => widget.onTapProject?.call(project),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title ?? 'Untitled Project',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.description ?? 'No description available',
                            style: theme.textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  project.status ?? 'No Status',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(project.createdAt),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

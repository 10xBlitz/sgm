import 'package:flutter/material.dart';
import 'package:sgm/widgets/item/item_projects.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClinicsListAllTab extends StatefulWidget {
  const ClinicsListAllTab({super.key, this.onTapClinic});

  /// Callback when a clinic is tapped. The navigation extras include:
  /// - 'project': The ID of the selected clinic
  /// - 'currentTab': The tab to display (ClinicsTab.tabTitle)
  /// - 'subTab': The sub-tab to display (defaults to ClinicsListSubTab.title)
  final Future<void> Function(ProjectRow)? onTapClinic;

  @override
  State<ClinicsListAllTab> createState() => _ClinicsListAllTabState();
}

class _ClinicsListAllTabState extends State<ClinicsListAllTab> {
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
      future: projectService.getAllClinic(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading clinics: ${snapshot.error}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final clinics = snapshot.data ?? [];

        if (clinics.isEmpty) {
          return Center(
            child: Text('No clinics found', style: theme.textTheme.titleMedium),
          );
        }

        return ListView.separated(
          itemCount: clinics.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final clinic = clinics[index];
            return ItemProject(
              item: clinic,
              onTap: () => widget.onTapClinic?.call(clinic),
              theme: theme,
            );
          },
        );
      },
    );
  }
}

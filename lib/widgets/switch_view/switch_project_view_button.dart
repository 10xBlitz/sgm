import 'package:flutter/material.dart';
import 'package:sgm/utils/enum/project_view_type.dart';

class ProjectViewOption {
  final ProjectViewType viewType;
  final bool enabled;

  const ProjectViewOption({required this.viewType, this.enabled = true});
}

class SwitchProjectViewButton extends StatelessWidget {
  final ProjectViewType currentView;
  final Function(ProjectViewType) onViewChanged;
  final bool showListView;
  final bool showBoardView;
  final bool showCalendarView;
  final bool showDetailsView;
  final bool showAssignedUsersView;

  const SwitchProjectViewButton({
    super.key,
    required this.currentView,
    required this.onViewChanged,
    this.showListView = true,
    this.showBoardView = true,
    this.showCalendarView = true,
    this.showDetailsView = true,
    this.showAssignedUsersView = true,
  });

  List<ProjectViewOption> get _viewOptions => [
    ProjectViewOption(viewType: ProjectViewType.list, enabled: showListView),
    ProjectViewOption(viewType: ProjectViewType.board, enabled: showBoardView),
    ProjectViewOption(viewType: ProjectViewType.calendar, enabled: showCalendarView),
    ProjectViewOption(viewType: ProjectViewType.details, enabled: showDetailsView),
    ProjectViewOption(viewType: ProjectViewType.assignedUsers, enabled: showAssignedUsersView),
  ];

  void showChangeViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Change View',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF5F6368)),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              if (_viewOptions.any((option) => option.enabled)) ...[
                ..._viewOptions
                    .where((option) => option.enabled)
                    .map((option) => _buildViewOption(context, option.viewType)),
              ],
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewOption(BuildContext context, ProjectViewType viewType) {
    return InkWell(
      onTap: () {
        onViewChanged(viewType);
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: currentView == viewType ? const Color(0xFFD9C89E) : const Color(0xFFD9C89E),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Text(
            "${currentView == viewType ? '✅ ' : ' '}${viewType.label}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showChangeViewDialog(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD9C89E),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'Change View\n(${currentView.label})',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}

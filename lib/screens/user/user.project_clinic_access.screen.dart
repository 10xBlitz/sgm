import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/project_with_members.row.dart';
import 'package:sgm/screens/user/user.project_clinic_access_add.screen.dart';
import 'package:sgm/services/project.service.dart';

class UserProjectClinicAccess extends StatefulWidget {
  static const routeName = "/projects";
  const UserProjectClinicAccess({super.key});

  @override
  State<UserProjectClinicAccess> createState() =>
      _UserProjectClinicAccessState();
}

class _UserProjectClinicAccessState extends State<UserProjectClinicAccess> {
  final ProjectService _projectService = ProjectService();
  bool _isLoading = true;
  List<ProjectWithMembersRow> _projects = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Always load fresh data to ensure we have the latest
      final projects = await _projectService.getAllProjectsWithMembers(
        cached: false,
      );
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load projects: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleProjectUpdated(ProjectWithMembersRow updatedProject) {
    setState(() {
      // Find and replace the updated project in the list
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index >= 0) {
        _projects[index] = updatedProject;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const ProjectsLoadingView()
              : _errorMessage != null
              ? ProjectsErrorView(
                message: _errorMessage!,
                onRetry: _loadProjects,
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Clinic/Projects',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        ProjectsCountDisplay(count: _projects.length),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadProjects,
                      child: ProjectsListView(
                        projects: _projects,
                        onProjectUpdated: _handleProjectUpdated,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class ProjectsCountDisplay extends StatelessWidget {
  final int count;

  const ProjectsCountDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class ProjectsLoadingView extends StatelessWidget {
  const ProjectsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading projects...'),
        ],
      ),
    );
  }
}

class ProjectsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ProjectsErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text('Error', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class ProjectsListView extends StatefulWidget {
  final List<ProjectWithMembersRow> projects;
  final Function(ProjectWithMembersRow updatedProject)? onProjectUpdated;

  const ProjectsListView({
    super.key,
    required this.projects,
    this.onProjectUpdated,
  });

  @override
  State<ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<ProjectsListView> {
  late List<ProjectWithMembersRow> _projects;

  @override
  void initState() {
    super.initState();
    _projects = List.from(widget.projects);
  }

  @override
  void didUpdateWidget(ProjectsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.projects != oldWidget.projects) {
      _projects = List.from(widget.projects);
    }
  }

  void _handleProjectUpdate(ProjectWithMembersRow updatedProject) {
    setState(() {
      // Find and replace the updated project in the list
      final index = _projects.indexWhere((p) => p.id == updatedProject.id);
      if (index >= 0) {
        _projects[index] = updatedProject;
      }
    });

    // Notify parent if needed
    if (widget.onProjectUpdated != null) {
      widget.onProjectUpdated!(updatedProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final project = _projects[index];
        return ProjectListItem(
          index: index,
          project: project,
          onTap: () {},
          onProjectUpdated: _handleProjectUpdate,
        );
      },
    );
  }
}

// Update the ProjectListItem class to include navigation

class ProjectListItem extends StatelessWidget {
  final ProjectWithMembersRow project;
  final VoidCallback onTap;
  final int index;
  final Function(ProjectWithMembersRow updatedProject)? onProjectUpdated;

  const ProjectListItem({
    super.key,
    required this.project,
    required this.onTap,
    required this.index,
    this.onProjectUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProjectMembersScreen(
                  project: project,
                  onProjectUpdated: (updatedProject) {
                    // Update the local reference and notify parent if needed
                    if (onProjectUpdated != null) {
                      onProjectUpdated!(updatedProject);
                    }
                  },
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
          border: const Border(bottom: BorderSide(color: Colors.black12)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProjectInfo(project: project),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectInfo extends StatelessWidget {
  final ProjectWithMembersRow project;

  const ProjectInfo({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          project.title!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          project.area ?? 'Clinic',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        ProjectMemberAvatars(members: project.members!),
      ],
    );
  }
}

class ProjectMemberAvatars extends StatelessWidget {
  final List<Map<dynamic, dynamic>> members;
  final int maxToShow;
  final double overlap;

  const ProjectMemberAvatars({
    super.key,
    required this.members,
    this.maxToShow = 4,
    this.overlap = 16.0, // ↓ reduce overlap to increase spacing
  });

  @override
  Widget build(BuildContext context) {
    // Filter out any null entries that might have been introduced
    final validMembers =
        members
            .where((member) => member != null && member['id'] != null)
            .toList();

    final displayMembers = validMembers.take(maxToShow).toList();
    final remainingCount = validMembers.length - displayMembers.length;
    const double avatarDiameter = 32.0;
    final int visibleCount =
        displayMembers.length + (remainingCount > 0 ? 1 : 0);

    final totalWidth =
        visibleCount <= 1
            ? avatarDiameter
            : avatarDiameter + (visibleCount - 1) * (avatarDiameter - overlap);

    return SizedBox(
      height: avatarDiameter,
      width: totalWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * (avatarDiameter - overlap),
              child: MemberAvatar(member: displayMembers[i]),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayMembers.length * (avatarDiameter - overlap),
              child: CircleAvatar(
                radius: avatarDiameter / 2,
                backgroundColor: Colors.grey[300],
                child: Text(
                  '+$remainingCount',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MemberAvatar extends StatelessWidget {
  final Map<dynamic, dynamic> member;

  const MemberAvatar({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    // Try to get avatar from different possible field names
    final avatarUrl = member['avatarUrl'] ?? member['profile_image'];
    final name = member['name'] ?? '';

    return avatarUrl != null && avatarUrl.toString().isNotEmpty
        ? CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(avatarUrl.toString()),
          backgroundColor: Colors.grey[200],
        )
        : CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueGrey,
          child: Text(
            _getInitials(name),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}

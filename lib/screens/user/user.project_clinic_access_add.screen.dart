import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/project_with_members.row.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/widgets/user/project_clinic_access.dart/project_access.add_member.tab.dart';
import 'package:sgm/widgets/user/user.user_avatar.dart';

class ProjectMembersScreen extends StatefulWidget {
  static const routeName = "/project-members";
  final ProjectWithMembersRow project;
  final Function(ProjectWithMembersRow updatedProject)? onProjectUpdated;

  const ProjectMembersScreen({
    super.key,
    required this.project,
    this.onProjectUpdated,
  });

  @override
  State<ProjectMembersScreen> createState() => _ProjectMembersScreenState();
}

class _ProjectMembersScreenState extends State<ProjectMembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  late ProjectWithMembersRow _projectWithMembers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Create a copy of the project to avoid modifying the original
    _projectWithMembers = widget.project;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _notifyProjectUpdated() {
    if (widget.onProjectUpdated != null) {
      widget.onProjectUpdated!(_projectWithMembers);
    }
  }

  Future<void> _addMember(Map<String, dynamic> newMember) async {
    setState(() {
      if (_projectWithMembers.members == null) {
        _projectWithMembers = _projectWithMembers.copyWith(members: []);
      }

      // Add the new member to the members list
      final updatedMembers = List<Map<String, dynamic>>.from(
        _projectWithMembers.members ?? [],
      );

      // Check if member already exists to avoid duplicates
      if (!updatedMembers.any((member) => member['id'] == newMember['id'])) {
        updatedMembers.add(newMember);

        // Update the project with the new members list
        _projectWithMembers = _projectWithMembers.copyWith(
          members: updatedMembers,
          numberOfMembers: updatedMembers.length,
          memberIds: updatedMembers.map((m) => m['id'] as String).toList(),
        );

        // Notify parent of the update
        _notifyProjectUpdated();
      }
    });
  }

  Future<void> _removeMember(String userId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authUser = _authService.currentUser;
      if (authUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await _projectService.removeMemberFromProject(
        _projectWithMembers.id!,
        userId,
      );

      if (success) {
        setState(() {
          // Create a new list without the removed member
          final updatedMembers = List<Map<String, dynamic>>.from(
            _projectWithMembers.members ?? [],
          )..removeWhere((member) => member['id'] == userId);

          // Update the project with the new members list
          _projectWithMembers = _projectWithMembers.copyWith(
            members: updatedMembers,
            numberOfMembers: updatedMembers.length,
            memberIds: updatedMembers.map((m) => m['id'] as String).toList(),
          );

          // Notify parent of the update
          _notifyProjectUpdated();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to remove member: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_projectWithMembers.title ?? 'Project Members'),
        backgroundColor: const Color(0xFFCDAA6A),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, color: Colors.white),
            label: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Current Members'),
              Tab(text: 'Add Members'),
            ],
            labelColor: Colors.black,
            indicatorColor: const Color(0xFFCDAA6A),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CurrentMembersTab(
                  project: _projectWithMembers,
                  onRemoveMember: _removeMember,
                  isLoading: _isLoading,
                ),
                ProjectAccessAddMemberTab(
                  projectId: _projectWithMembers.id!,
                  currentMemberIds:
                      _projectWithMembers.members != null
                          ? _projectWithMembers.members!
                              .map((member) => member['id'] as String)
                              .toList()
                          : [],
                  onMemberAdded: (UserRow newUser) async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });

                      // Add the member via the service
                      final currentUser = _authService.currentUser;
                      if (currentUser == null) {
                        throw Exception('User not authenticated');
                      }

                      final success = await _projectService.addMemberToProject(
                        _projectWithMembers.id!,
                        newUser.id,
                        currentUser.id,
                      );

                      if (success) {
                        // Convert UserRow to member Map with proper avatar handling
                        final newMember = {
                          'id': newUser.id,
                          'name': newUser.name,
                          'email': newUser.email,
                          'avatarUrl': newUser.profileImage,
                          'profile_image': newUser.profileImage,
                        };

                        _addMember(newMember);

                        // Switch to the Current Members tab
                        _tabController.animateTo(0);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${newUser.name} added successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to add member: ${e.toString()}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CurrentMembersTab extends StatelessWidget {
  final ProjectWithMembersRow project;
  final Function(String) onRemoveMember;
  final bool isLoading;

  const CurrentMembersTab({
    super.key,
    required this.project,
    required this.onRemoveMember,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final members = project.members ?? [];

    if (members.isEmpty) {
      return const EmptyMembersView();
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            // This is a simple way to allow manual refresh
            // The actual refresh logic is in the parent widget
          },
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return MemberListItem(
                member: member,
                onRemove: () => onRemoveMember(member['id']),
              );
            },
          ),
        ),
        if (isLoading) const LoadingOverlay(),
      ],
    );
  }
}

class EmptyMembersView extends StatelessWidget {
  const EmptyMembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No members in this project',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add members from the "Add Members" tab',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class MemberListItem extends StatelessWidget {
  final Map<dynamic, dynamic> member;
  final VoidCallback onRemove;

  const MemberListItem({
    super.key,
    required this.member,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ListTile(
        leading: MemberAvatar(member: member),
        title: Text(
          member['name'] ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(member['email'] ?? ''),
        trailing: TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => ConfirmRemoveDialog(
                    memberName: member['name'] ?? 'this user',
                    onConfirm: onRemove,
                  ),
            );
          },
          child: const Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}

class ConfirmRemoveDialog extends StatelessWidget {
  final String memberName;
  final VoidCallback onConfirm;

  const ConfirmRemoveDialog({
    super.key,
    required this.memberName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove Member'),
      content: Text(
        'Are you sure you want to remove $memberName from this project?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: const Text('Remove', style: TextStyle(color: Colors.red)),
        ),
      ],
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
          backgroundImage: NetworkImage(avatarUrl.toString()),
          backgroundColor: Colors.grey[200],
        )
        : CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Text(
            _getInitials(name),
            style: const TextStyle(color: Colors.white),
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

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search users...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;

  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}

class NoUsersFoundView extends StatelessWidget {
  const NoUsersFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class UsersList extends StatelessWidget {
  final List<UserRow> users;
  final Function(UserRow) onAddUser;
  final bool isLoading;

  const UsersList({
    super.key,
    required this.users,
    required this.onAddUser,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];

            // Skip users that don't meet criteria
            if (user.rejectedAt != null && user.acceptedAt != null) {
              return const SizedBox.shrink();
            }
            if (user.isBanned != false) return const SizedBox.shrink();
            if (user.role == null) return const SizedBox.shrink();

            return UserListItem(user: user, onAdd: () => onAddUser(user));
          },
        ),
        if (isLoading) const LoadingOverlay(),
      ],
    );
  }
}

class UserListItem extends StatelessWidget {
  final UserRow user;
  final VoidCallback onAdd;

  const UserListItem({super.key, required this.user, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: ListTile(
        leading: UserUserAvatar(userRow: user),
        title: Text(
          user.name ?? 'Unknown User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email ?? ''),
        trailing: AddButton(onPressed: onAdd),
      ),
    );
  }
}

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCDAA6A),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text('Add'),
    );
  }
}

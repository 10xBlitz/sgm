import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/screens/user/user.project_clinic_access_add.screen.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/user.service.dart';

class ProjectAccessAddMemberTab extends StatefulWidget {
  final String projectId;
  final List<String> currentMemberIds;
  final Function(UserRow) onMemberAdded;

  const ProjectAccessAddMemberTab({
    super.key,
    required this.projectId,
    required this.currentMemberIds,
    required this.onMemberAdded,
  });

  @override
  State<ProjectAccessAddMemberTab> createState() =>
      _ProjectAccessAddMemberTabState();
}

class _ProjectAccessAddMemberTabState extends State<ProjectAccessAddMemberTab> {
  final UserService _userService = UserService();
  final ProjectService _projectService = ProjectService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();

  List<UserRow> _users = [];
  List<UserRow> _filteredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _userService.getAllUsers();

      // Filter out users that are already members
      final filteredUsers =
          users
              .where((user) => !widget.currentMemberIds.contains(user.id))
              .toList();

      setState(() {
        _users = filteredUsers;
        _filteredUsers = filteredUsers;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();

    setState(() {
      _filteredUsers =
          _users.where((user) {
            // First check if user is eligible
            if (widget.currentMemberIds.contains(user.id)) {
              return false;
            }

            final name = user.name?.toString().toLowerCase() ?? '';
            final email = user.email?.toString().toLowerCase() ?? '';
            return name.contains(lowercaseQuery) ||
                email.contains(lowercaseQuery);
          }).toList();
    });
  }

  Future<void> _addMember(UserRow user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await _projectService.addMemberToProject(
        widget.projectId,
        user.id,
        currentUser.id,
      );

      if (success) {
        // Call the callback to notify parent component
        widget.onMemberAdded(user);

        // Update local state to reflect changes
        setState(() {
          _users.removeWhere((u) => u.id == user.id);
          _filteredUsers.removeWhere((u) => u.id == user.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add member: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SearchField(
            controller: _searchController,
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? ErrorView(message: _errorMessage!)
                  : _users.isEmpty
                  ? const NoUsersFoundView()
                  : UsersList(
                    users: _filteredUsers,
                    onAddUser: _addMember,
                    isLoading: _isLoading,
                  ),
        ),
      ],
    );
  }
}

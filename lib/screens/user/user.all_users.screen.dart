import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/all_user/all_user_card.dart';
import 'package:sgm/widgets/user/user.role_dropdown.dart';
import 'package:sgm/widgets/user/user.user_search_field.dart';

class UserAllUserScreen extends StatefulWidget {
  const UserAllUserScreen({super.key, this.onSwitchTab});

  final VoidCallback? onSwitchTab;

  @override
  State<UserAllUserScreen> createState() => _UserAllUserScreenState();
}

class _UserAllUserScreenState extends State<UserAllUserScreen> {
  final UserService userService = UserService();
  bool _isLoading = true;
  List<UserWithProjectsRow> users = [];
  String _searchQuery = '';

  String? selectedRole;
  List<UserRoleRow> availableRoles = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
    loadUserRole();
  }

  void loadUserRole() async {
    availableRoles = await userService.fetchUserRolesWithCache();
  }

  Future<void> loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final finalUsers = await userService.getAllUsersWithProjectsCache(
      search: _searchQuery,
      role: selectedRole,
    );

    setState(() {
      users = finalUsers;
      _isLoading = false;
    });
  }

  // loadUserByRole
  Future<void> loadUsersByRole(String role) async {
    setState(() {
      _isLoading = true;
    });

    final finalUsers = await userService.getAllUsersWithProjectsCache(
      role: role,
      search: _searchQuery,
    );

    setState(() {
      users = finalUsers;
      _isLoading = false;
    });
  }

  // onUserRoleReset
  void onUserRoleReset() {
    setState(() {
      selectedRole = null;
    });

    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          UserUserSearchField(
            onSearch: (query) {
              _searchQuery = query;
              loadUsers();
            },
          ),
          const SizedBox(height: 16),
          UserRoleDropDown(
            selectedRole: selectedRole,
            availableRoles: availableRoles,
            showReset: selectedRole != null,
            onReset: onUserRoleReset,
            onChanged: (value) {
              setState(() {
                selectedRole = value;
              });

              loadUsersByRole(selectedRole!);
            },
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                child:
                    users.isEmpty
                        ? const EmptyUsersList()
                        : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];

                            if (user.isBanned != false ||
                                user.acceptedAt == null) {
                              return const SizedBox.shrink();
                            }
                            if (user.role == null) {
                              return const SizedBox.shrink();
                            }
                            return AllUserCard(
                              user: user,
                              availableRoles: availableRoles,
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}

class UserActions extends StatelessWidget {
  final UserWithProjectsRow user;

  const UserActions({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        // Handle menu selection
      },
      itemBuilder:
          (BuildContext context) => [
            const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
            const PopupMenuItem<String>(
              value: 'permissions',
              child: Text('Permissions'),
            ),
            const PopupMenuItem<String>(
              value: 'reset',
              child: Text('Reset Password'),
            ),
            PopupMenuItem<String>(
              value: 'ban',
              child: Text(user.isBanned == true ? 'Unban User' : 'Ban User'),
            ),
          ],
    );
  }
}

class EmptyUsersList extends StatelessWidget {
  const EmptyUsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.people_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/screens/user/user.all_users_details.screen.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/all_user/all_user_card.dart';
import 'package:sgm/widgets/user/all_user/all_user_empty.screen.dart';
import 'package:sgm/widgets/user/all_user/all_user_update_role_dialog.dart';
import 'package:sgm/widgets/user/user.role_dropdown.dart';
import 'package:sgm/widgets/user/user.user_search_field.dart';

class UserAllUserScreen extends StatefulWidget {
  const UserAllUserScreen({super.key});

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

  Future<void> _showUpdateRoleDialog(
    BuildContext context,
    UserWithProjectsRow user,
  ) async {
    String? newRole;

    await showDialog(
      context: context,
      builder:
          (context) => UpdateRoleDialog(
            user: user,
            availableRoles: availableRoles,
            onRoleSelected: (roleId) {
              newRole = roleId;
            },
          ),
    );

    // If role was selected and dialog was confirmed
    if (newRole != null) {
      await _updateUserRole(user.id!, newRole!);
    }
  }

  Future<void> _updateUserRole(String userId, String roleId) async {
    setState(() {
      _isLoading = true;
    });

    final success = await userService.updateUserRole(userId, roleId);

    if (success) {
      // Refresh the list to show updated data
      loadUsers();
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user role'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                        ? const AllUserEmptyScreen()
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
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UserAllUserDetailScreen(
                                          userId: user.id!,
                                        ),
                                  ),
                                );
                              },
                              child: AllUserCard(
                                user: user,
                                availableRoles: availableRoles,
                                onUpdateRole: (user) {
                                  debugPrint(
                                    'Updating role for user: ${user.id}',
                                  );
                                  _showUpdateRoleDialog(context, user);
                                },
                              ),
                            );
                          },
                        ),
              ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user_role.row.dart';
import 'package:sgm/row_row_row_generated/tables/user_with_projects.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/all_user/all_user_loading.dart';
import 'package:sgm/widgets/user/all_user/all_user_not_found.dart';
import 'package:sgm/widgets/user/all_user/all_user_profile_card.dart';

class UserAllUserDetailScreen extends StatefulWidget {
  static const routeName = "/user-detail";

  final String userId;

  const UserAllUserDetailScreen({super.key, required this.userId});

  @override
  State<UserAllUserDetailScreen> createState() =>
      _UserAllUserDetailScreenState();
}

class _UserAllUserDetailScreenState extends State<UserAllUserDetailScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  UserWithProjectsRow? _user;
  List<UserRoleRow> _availableRoles = [];

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadUserRoles();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    final user = await _userService.getUserWithProjectsById(widget.userId);

    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _loadUserRoles() async {
    final roles = await _userService.fetchUserRolesWithCache();
    setState(() {
      _availableRoles = roles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.name ?? "User Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const AllUserLoading()
                : _user == null
                ? const AllUserNotFound()
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AllUserProfileCard(
                        user: _user!,
                        availableRoles: _availableRoles,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
      ),
    );
  }
}

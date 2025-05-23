import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/user.row.dart';
import 'package:sgm/services/user.service.dart';
import 'package:sgm/widgets/user/user.request_card.dart';

class UserNewRequestScreen extends StatefulWidget {
  static const routeName = "/user/new-requests";
  const UserNewRequestScreen({super.key});

  @override
  State<UserNewRequestScreen> createState() => _UserNewRequestScreenState();
}

class _UserNewRequestScreenState extends State<UserNewRequestScreen> {
  final _userService = UserService();
  bool _isLoading = true;
  List<UserRow> _newUsers = [];

  @override
  void initState() {
    super.initState();
    loadNewUserRequests();
  }

  Future<void> loadNewUserRequests() async {
    setState(() {
      _isLoading = true;
    });

    final users = await _userService.getAllNewUserRequests();

    debugPrint('$users');
    setState(() {
      _newUsers = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _newUsers.isEmpty
                      ? const Center(child: Text("No new user requests"))
                      : ListView.builder(
                        itemCount: _newUsers.length,
                        itemBuilder: (context, index) {
                          return UserRequestCard(
                            user: _newUsers[index],
                            onRoleChanged: handleRoleChange,
                            onApproved: handleUserApproval,
                            onReject: handleUserRejection,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleRoleChange(String userId, String? role) async {
    // Update user role in database
    await _userService.updateUserRole(userId, role!);

    setState(() {});
    // Refresh the list
    loadNewUserRequests();
  }

  Future<void> handleUserApproval(String userId) async {
    // Approve user in database
    await _userService.approveUser(userId);

    setState(() {});
    // Refresh the list
    loadNewUserRequests();
  }

  Future<void> handleUserRejection(String userId) async {
    // Reject user in database
    await _userService.rejectUser(userId);

    setState(() {});
    // Refresh the list
    loadNewUserRequests();
  }
}

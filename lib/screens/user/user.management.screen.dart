import 'package:flutter/material.dart';
import 'package:sgm/screens/user/user.new_request.screen.dart';

class UserManagementScreen extends StatefulWidget {
  static const routeName = "/user-management";
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: "New User Requests"),
              Tab(text: "All Users"),
              Tab(text: "User Permissions"),
              Tab(text: "Clinic/Project Access"),
              Tab(text: "Terms and Conditions"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                UserNewRequestScreen(),
                AllUsersTab(),
                UserPermissionsTab(),
                ClinicProjectAccessTab(),
                TermsConditionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewUserRequestsTab extends StatelessWidget {
  const NewUserRequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New User Requests",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          UserRequestList(),
        ],
      ),
    );
  }
}

class AllUsersTab extends StatelessWidget {
  const AllUsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "All Users",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          UsersList(),
        ],
      ),
    );
  }
}

class UserPermissionsTab extends StatelessWidget {
  const UserPermissionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Permissions",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          PermissionsManager(),
        ],
      ),
    );
  }
}

class ClinicProjectAccessTab extends StatelessWidget {
  const ClinicProjectAccessTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Clinic/Project Access",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          AccessManager(),
        ],
      ),
    );
  }
}

class TermsConditionsTab extends StatelessWidget {
  const TermsConditionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Terms and Conditions",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TermsEditor(),
        ],
      ),
    );
  }
}

// Content widgets for each tab

class UserRequestList extends StatelessWidget {
  const UserRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(child: Text("New user requests will appear here")),
    );
  }
}

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(child: Text("List of all users will appear here")),
    );
  }
}

class PermissionsManager extends StatelessWidget {
  const PermissionsManager({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text("User permissions management interface will appear here"),
      ),
    );
  }
}

class AccessManager extends StatelessWidget {
  const AccessManager({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text("Clinic and project access controls will appear here"),
      ),
    );
  }
}

class TermsEditor extends StatelessWidget {
  const TermsEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Center(
        child: Text("Terms and conditions editor will appear here"),
      ),
    );
  }
}

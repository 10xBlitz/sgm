import 'package:flutter/material.dart';

class UserUserSearchField extends StatefulWidget {
  final Function(String) onSearch;

  const UserUserSearchField({super.key, required this.onSearch});

  @override
  State<UserUserSearchField> createState() => _UserUserSearchFieldState();
}

class _UserUserSearchFieldState extends State<UserUserSearchField> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search users by name or email',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            widget.onSearch('');
          },
        ),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: widget.onSearch,
      textInputAction: TextInputAction.search,
    );
  }
}

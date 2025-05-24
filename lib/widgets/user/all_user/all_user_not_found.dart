import 'package:flutter/material.dart';

class AllUserNotFound extends StatelessWidget {
  const AllUserNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'User not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

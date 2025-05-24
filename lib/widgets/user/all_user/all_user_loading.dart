import 'package:flutter/material.dart';

class AllUserLoading extends StatelessWidget {
  const AllUserLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading user details...'),
        ],
      ),
    );
  }
}

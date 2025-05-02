import 'package:flutter/material.dart';

class ClinicsTab extends StatelessWidget {
  static const String tabTitle = 'Clinics';
  const ClinicsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(tabTitle, style: TextStyle(fontSize: 24)));
  }
}

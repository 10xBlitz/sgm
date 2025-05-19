import 'package:flutter/material.dart';
import 'package:sgm/screens/procedures/procedures.add.screen.dart';
import 'package:sgm/screens/procedures/procedures.edit.screen.dart';
import 'package:sgm/screens/procedures/procedures.screen.dart';

class ProceduresTab extends StatefulWidget {
  static const String tabTitle = 'Procedures';
  const ProceduresTab({super.key, this.subTab});

  final String? subTab;

  @override
  State<ProceduresTab> createState() => _ProceduresTabState();
}

class _ProceduresTabState extends State<ProceduresTab> {
  String get subTab => widget.subTab ?? ProceduresTab.tabTitle;

  @override
  Widget build(BuildContext context) {
    return switch (subTab) {
      ProceduresTab.tabTitle => ProceduresScreen(),
      'Add' => const ProceduresAddScreen(),
      _ => Center(child: const Text('404 Not Found')),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/mainTabs/clinics/subTabs/clinics.list.all.tab.dart';
import 'package:sgm/mainTabs/clinics/subTabs/clinics.list.sub_tab.dart';
import 'package:sgm/screens/main.screen.dart';

class ClinicsTab extends StatefulWidget {
  static const String tabTitle = 'Clinics';
  const ClinicsTab({super.key, this.projectId, this.subTab, this.subTabKey});
  final String? projectId;
  final String? subTab;
  final Key? subTabKey;

  @override
  State<ClinicsTab> createState() => _ClinicsTabState();
}

class _ClinicsTabState extends State<ClinicsTab> {
  String get subTab => widget.subTab ?? ClinicsListSubTab.title;

  @override
  Widget build(BuildContext context) {
    if (widget.projectId == null) {
      return ClinicsListAllTab(
        onTapClinic: (clinic) async {
          context.pushReplacement(
            MainScreen.routeName,
            extra: {
              'project': clinic.id,
              'currentTab': ClinicsTab.tabTitle,
              'subTab': widget.subTab,
            },
          );
        },
      );
    }

    return switch (subTab) {
      ClinicsListSubTab.title => ClinicsListSubTab(
        key: widget.subTabKey,
        projectId: widget.projectId!,
      ),
      _ => const Center(
        child: Text('Default Screen', style: TextStyle(color: Colors.grey)),
      ),
    };
  }
}

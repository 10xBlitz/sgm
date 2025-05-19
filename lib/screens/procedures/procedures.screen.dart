import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/services/procedure.service.dart';

import 'package:sgm/widgets/procedures/procedure_filter.dart';

class ProceduresScreen extends StatefulWidget {
  static const routeName = "/procedures";
  const ProceduresScreen({super.key});

  @override
  State<ProceduresScreen> createState() => ProceduresScreenState();
}

class ProceduresScreenState extends State<ProceduresScreen> {
  bool showFilter = false;
  bool isLoading = true;

  List<ProcedureWithCategoryClinicAreaNamesRow> procedure = [];

  void toggleShowFilter() {
    setState(() {
      showFilter = !showFilter;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    loadProcedures();
  }

  Future<void> loadProcedures() async {
    setState(() {
      isLoading = true;
    });

    final ProcedureService procedureService = ProcedureService();
    final s = await procedureService.getProcedures(limit: 10);
    setState(() {
      procedure = s;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Procedures')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Add Procedure'),
                ),
                IconButton.filled(
                  onPressed: toggleShowFilter,
                  icon: Icon(
                    showFilter ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  ),
                ),
              ],
            ),
            if (showFilter) ProcedureFilter(),
            const SizedBox(height: 16),
            ...procedure.map((procedure) {
              return Text('${procedure.categoryName}');
            }),
          ],
        ),
      ),
    );
  }
}

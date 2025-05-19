import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/services/procedure.service.dart';

import 'package:sgm/widgets/procedures/procedure_filter.dart';
import 'package:sgm/widgets/procedures/procedure_item.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 14,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement add procedure functionality
                  },
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
            if (showFilter)
              const ProcedureFilter(), // Assuming ProcedureFilter has a const constructor
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : procedure.isEmpty
                      ? const Center(child: Text('No procedures found.'))
                      : ListView.builder(
                          itemCount: procedure.length,
                          itemBuilder: (BuildContext context, int index) {
                            final pro = procedure[index];
                            return ProcedureItem(
                              item: pro,
                              onTap: () {},
                              theme: Theme.of(context),
                            );
                          },
                        ),
            ),
            // add next page button
          ],
        ),
      ),
    );
  }
}

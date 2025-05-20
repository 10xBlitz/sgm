import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/screens/main.screen.dart';
import 'package:sgm/screens/procedures/procedures.add.screen.dart';
import 'package:sgm/screens/procedures/procedures.edit.screen.dart';
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
  List<String> selectedAreaIds = [];
  List<String> selectedClinicIds = [];
  List<String> selectedCategoryIds = [];

  int currentPage = 1;
  final int limit = 10;
  bool isEndReached = false;

  @override
  void initState() {
    super.initState();
    loadProcedures();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleShowFilter() {
    setState(() {
      showFilter = !showFilter;
    });
  }

  Future<void> loadProcedures() async {
    setState(() {
      isLoading = true;
    });

    final procedureService = ProcedureService();
    final result = await procedureService.getProcedures(
      offset: currentPage,
      limit: limit,
      areaIds: selectedAreaIds,
      clinicIds: selectedClinicIds,
      categoryIds: selectedCategoryIds,
    );

    setState(() {
      procedure = result;
      isLoading = false;
    });
  }

  void goToNextPage() {
    setState(() {
      currentPage += 1;
      isEndReached = false;
    });
    loadProcedures();
  }

  void goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage -= 1;
        isEndReached = false;
      });
      loadProcedures();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProceduresAddScreen(),
                      ),
                    );

                    debugPrint(result);
                    // If we got back with a result, reload procedures
                    if (result == true) {
                      loadProcedures();
                    }

                    setState(() {});
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
              ProcedureFilter(
                onFilterChanged: ({
                  required List<String> areaIds,
                  required List<String> clinicIds,
                  required List<String> categoryIds,
                }) {
                  setState(() {
                    selectedAreaIds = areaIds;
                    selectedClinicIds = clinicIds;
                    selectedCategoryIds = categoryIds;
                    currentPage = 1;
                  });
                  loadProcedures();
                },
              ),
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : procedure.isEmpty
                      ? const Center(child: Text('No procedures found.'))
                      : ListView.builder(
                        itemCount: procedure.length,
                        itemBuilder: (context, index) {
                          final pro = procedure[index];
                          return ProcedureItem(
                            item: pro,
                            onTap: () async {
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProceduresEditScreen(
                                        procedureId: pro.id!,
                                      ),
                                ),
                              );
                              debugPrint('resisasdadasd, $result');
                              // If we got back with a result, reload procedures
                              if (result == true) {
                                loadProcedures();
                              }
                            },
                            theme: Theme.of(context),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentPage > 1) ...{
                    ElevatedButton(
                      onPressed: goToPreviousPage,
                      child: const Text("Previous"),
                    ),
                  } else ...{
                    SizedBox(),
                  },
                  ElevatedButton(
                    onPressed: goToNextPage,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/procedure.row.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_procedure.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_summary.row.dart';
import 'package:sgm/services/procedure.service.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task_appointment.service.dart';

/// Fullscreen dialog for adding a procedure to a task appointment
class ProcedureAddDialog extends StatefulWidget {
  const ProcedureAddDialog({
    super.key,
    required this.appointmentSummary,

    this.initalClinic,
  });

  final TaskAppointmentSummaryRow appointmentSummary;
  final String? initalClinic;

  /// Shows the fullscreen dialog and returns the created procedure or null if canceled
  static Future<ProcedureRow?> show({
    required BuildContext context,
    required TaskAppointmentSummaryRow appointmentSummary,
    String? initalClinic,
  }) async {
    return Navigator.of(context).push<ProcedureRow?>(
      MaterialPageRoute<ProcedureRow?>(
        fullscreenDialog: true,
        builder:
            (context) => ProcedureAddDialog(
              appointmentSummary: appointmentSummary,
              initalClinic: initalClinic,
            ),
      ),
    );
  }

  @override
  State<ProcedureAddDialog> createState() => _ProcedureAddDialogState();
}

class _ProcedureAddDialogState extends State<ProcedureAddDialog> {
  // Selected values
  String? _selectedClinic;
  String? _selectedCategory;
  String _searchQuery = '';
  ProjectRow? projectOfTask;
  List<ProcedureWithCategoryClinicAreaNamesRow> _procedureResult = [];
  List<ProcedureWithCategoryClinicAreaNamesRow> _allProcedureInCategory = [];

  // Controllers
  final TextEditingController _searchController = TextEditingController();

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _selectedClinic = widget.initalClinic;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Procedure'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: FutureBuilder<ProjectRow?>(
        initialData: ProjectService().getFromCache(_selectedClinic ?? ''),
        future: ProjectService().getFromId(_selectedClinic ?? ''),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              (!snapshot.hasData || snapshot.data == null)) {
            return Center(child: CircularProgressIndicator());
          }
          final project = snapshot.data!;

          return FutureBuilder<TaskAppointmentRow?>(
            initialData: TaskAppointmentService().getFromCache(
              widget.appointmentSummary.taskAppointmentId ?? "",
            ),
            future: TaskAppointmentService().getFromId(
              widget.appointmentSummary.taskAppointmentId!,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  (!snapshot.hasData || snapshot.data == null)) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text('Appointment not found');
              }
              final appointment = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Clinic dropdown
                      if (project.canChooseOtherClinic) ...[
                        FutureBuilder<List<ProjectRow>>(
                          initialData: ProjectService().getAllClinicCache(),
                          future: ProjectService().getAllClinic(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return Center(
                                child: const CircularProgressIndicator(),
                              );
                            }
                            final clinics = snapshot.data ?? [];
                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Clinic',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedClinic,
                              onChanged: (value) {
                                setState(() {
                                  _selectedClinic = value;
                                });
                              },
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Select Clinic'),
                                ),
                                // Populate by clinics
                                ...clinics.map(
                                  (clinic) => DropdownMenuItem(
                                    value: clinic.id,
                                    child: Text(
                                      clinic.title ?? 'Unnamed Clinic',
                                    ),
                                  ),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a clinic';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Clinic', style: theme.textTheme.labelSmall),
                            Text(
                              project.title ?? 'Unnamed Project',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Category dropdown
                      if (_selectedClinic != null)
                        FutureBuilder<
                          List<ProcedureWithCategoryClinicAreaNamesRow>
                        >(
                          future: ProcedureService().getProceduresByClinic(
                            _selectedClinic!,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            final procedures = snapshot.data ?? [];
                            // Map the categories into{'id': id, 'name': category}, but unique in id
                            final categoriesMap =
                                <String, Map<String, String>>{};
                            for (var procedure in procedures) {
                              if (procedure.category != null &&
                                  procedure.categoryName != null) {
                                // Use category ID as key to ensure uniqueness
                                categoriesMap[procedure.category!] = {
                                  'id': procedure.category!,
                                  'name': procedure.categoryName!,
                                };
                              }
                            }
                            // Convert back to list after ensuring uniqueness
                            final categories = categoriesMap.values.toList();
                            return DropdownButtonFormField<String?>(
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              value: _selectedCategory,
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value;
                                  // filter by selected category
                                  // order by titleEng or titleKor

                                  _allProcedureInCategory =
                                      _procedureResult =
                                          procedures
                                              .where(
                                                (procedure) =>
                                                    procedure.category ==
                                                    value, // filter by selected category
                                              )
                                              .toList();
                                  _allProcedureInCategory.sort((a, b) {
                                    final titleA =
                                        a.titleEng ?? a.titleKor ?? '';
                                    final titleB =
                                        b.titleEng ?? b.titleKor ?? '';
                                    return titleA.compareTo(titleB);
                                  });
                                });
                              },
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(
                                    'Select Category',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                ),

                                ...categories.map(
                                  (category) => DropdownMenuItem(
                                    value: category['id'],
                                    child: Text(
                                      category['name'] ?? 'Unnamed Category',
                                    ),
                                  ),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 16),

                      // Procedure search field
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Procedure',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon:
                              _searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _procedureResult =
                                            _allProcedureInCategory;
                                      });
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          // filter based on the search query

                          setState(() {
                            _searchQuery = value;
                            _procedureResult =
                                _allProcedureInCategory
                                    .where(
                                      (procedure) =>
                                          procedure.titleEng
                                              ?.toLowerCase()
                                              .contains(
                                                _searchQuery.toLowerCase(),
                                              ) ??
                                          procedure.titleKor
                                              ?.toLowerCase()
                                              .contains(
                                                _searchQuery.toLowerCase(),
                                              ) ??
                                          false,
                                    )
                                    .toList();
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Procedure list (search results)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.dividerColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.separated(
                            itemCount: _procedureResult.length,
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder:
                                (context, index) => ListTile(
                                  title: Text(
                                    _procedureResult[index].titleEng ??
                                        _procedureResult[index].titleKor ??
                                        'Unnamed Procedure',
                                  ),
                                  subtitle: Text(
                                    (_procedureResult[index].totalPrice ?? 0)
                                        .toString(),
                                  ),
                                  onTap: () async {
                                    final procedure = await ProcedureService()
                                        .getFromId(_procedureResult[index].id!);
                                    // pop
                                    if (!context.mounted) return;
                                    Navigator.pop(context, procedure);
                                  },
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

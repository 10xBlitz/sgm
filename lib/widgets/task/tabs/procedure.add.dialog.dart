import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/project.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_procedure.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_summary.row.dart';
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
  static Future<TaskAppointmentSummaryRow?> show({
    required BuildContext context,
    required TaskAppointmentSummaryRow appointmentSummary,
    String? initalClinic,
  }) async {
    return Navigator.of(context).push<TaskAppointmentSummaryRow>(
      MaterialPageRoute<TaskAppointmentSummaryRow>(
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
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            // TODO: When category changes, update available procedures
                          });
                        },
                        items: const [
                          // TODO: Fetch categories based on selected clinic
                          DropdownMenuItem(
                            value: 'placeholder',
                            child: Text('Select Category'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
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
                                      });
                                      // TODO: Clear search results
                                    },
                                  )
                                  : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          // TODO: Filter procedures based on search query
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
                            itemCount:
                                10, // TODO: Replace with actual procedure count
                            separatorBuilder:
                                (context, index) => const Divider(height: 1),
                            itemBuilder:
                                (context, index) => ListTile(
                                  title: Text('Procedure ${index + 1}'),
                                  subtitle: Text(
                                    'Price: \$${(index + 1) * 100}',
                                  ),
                                  onTap: () {
                                    // TODO: Select this procedure and return it
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

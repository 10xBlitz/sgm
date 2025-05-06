import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/task.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_procedure_summary.row.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_summary.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task_appointment_summary.service.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsTaskViewTab extends StatelessWidget {
  const AppointmentDetailsTaskViewTab({super.key, required this.task});

  final TaskRow task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8.0, 16.0, 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Appointments',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        // button to download as CSV
                        FilledButton.icon(
                          onPressed: () {},
                          label: Text('Download CSV'),
                          icon: Icon(Icons.download),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  FutureBuilder<List<TaskAppointmentSummaryRow>>(
                    initialData: TaskAppointmentSummaryService()
                        .getByTaskIdCache(task.id),
                    future: TaskAppointmentSummaryService().getByTaskId(
                      task.id,
                      cached: false,
                    ),
                    builder: (context, snapshot) {
                      debugPrint("Data: ${snapshot.data}");
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          (!snapshot.hasData || snapshot.data!.isEmpty)) {
                        return CircularProgressIndicator();
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No appointments found.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      }
                      final appointments = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: appointments.length,
                        primary: false,

                        itemBuilder: (context, index) {
                          // map into list of procedure summaries
                          final procedureSummaries =
                              appointments[index].procedureSummaries
                                  ?.map(
                                    (json) =>
                                        TaskAppointmentProcedureSummaryRow.fromJson(
                                          json,
                                        ),
                                  )
                                  .toList() ??
                              [];
                          final procedures =
                              procedureSummaries
                                  .map((summary) => summary.procedureName ?? '')
                                  .toList();
                          final procedurePrices =
                              procedureSummaries
                                  .map(
                                    (summary) => summary.procedurePrice ?? 0.0,
                                  )
                                  .toList();
                          final clinics =
                              procedureSummaries
                                  .map(
                                    (summary) =>
                                        summary.appointedClinicId ??
                                        'Unknown Clinic',
                                  )
                                  .toSet()
                                  .toList();
                          return InkWell(
                            onTap: () {},
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                              ),
                              alignment: Alignment.topLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          appointments[index].dueDate != null
                                              ? _formatDateTime(
                                                appointments[index].dueDate!,
                                              )
                                              : 'No due date',
                                          style:
                                              appointments[index].dueDate !=
                                                      null
                                                  ? theme.textTheme.titleMedium
                                                  : theme.textTheme.titleMedium
                                                      ?.copyWith(
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .error,
                                                      ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(procedures.join(', ')),
                                        Text(
                                          NumberFormat.currency(
                                            locale: 'ko_KR',
                                            // symbol: '₩',
                                            symbol: '',
                                            decimalDigits: 0,
                                          ).format(
                                            procedurePrices.fold<double>(
                                              0,
                                              (sum, item) => sum + item,
                                            ),
                                          ),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color:
                                                    theme
                                                        .colorScheme
                                                        .onSecondaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),

                                        // Chips that shows Clinic name, future for each item
                                        Wrap(
                                          spacing: 8.0,
                                          children:
                                              clinics.map((clinicId) {
                                                return FutureBuilder(
                                                  initialData: ProjectService()
                                                      .getFromCache(clinicId),
                                                  future: ProjectService()
                                                      .getFromId(clinicId),
                                                  builder: (context, snapshot) {
                                                    if (snapshot.hasError) {
                                                      return Text(
                                                        'Error: ${snapshot.error}',
                                                      );
                                                    } else if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting &&
                                                        (!snapshot.hasData ||
                                                            snapshot.data ==
                                                                null)) {
                                                      return CircularProgressIndicator();
                                                    } else if (!snapshot
                                                            .hasData ||
                                                        snapshot.data == null) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16.0,
                                                            ),
                                                        child: Text(
                                                          'No appointments found.',
                                                          style: theme
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                        ),
                                                      );
                                                    }

                                                    final clinic =
                                                        snapshot.data!;

                                                    return Chip(
                                                      label: Text(
                                                        clinic.title ??
                                                            'No Clinic name',
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(height: 1),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Button to add a new appointment
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.icon(
              onPressed: () {
                // Logic to add a new appointment
              },
              icon: Icon(Icons.add),
              label: Text('Add Appointment'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('MMMM dd, yyyy (HH:mm)');
    return formatter.format(dateTime);
  }
}

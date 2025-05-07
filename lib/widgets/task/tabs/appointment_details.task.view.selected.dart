import 'package:flutter/material.dart';
import 'package:sgm/extensions/date.extension.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_summary.row.dart';
import 'package:sgm/services/project.service.dart';
import 'package:sgm/services/task.service.dart';
import 'package:sgm/services/task_appointment_procedure.service.dart';
import 'package:sgm/services/task_appointment_summary.service.dart';
import 'package:sgm/widgets/task/tabs/procedure.add.dialog.dart';
import 'package:sgm/widgets/task/tabs/procedure_item.dart';

class AppointmentDetailsTaskViewSelected extends StatefulWidget {
  const AppointmentDetailsTaskViewSelected({
    super.key,
    required this.taskAppointmentSummary,
    required this.onUpdate,
    required this.onClose,
  });

  final TaskAppointmentSummaryRow taskAppointmentSummary;
  final VoidCallback onUpdate;
  final VoidCallback onClose;

  @override
  State<AppointmentDetailsTaskViewSelected> createState() =>
      _AppointmentDetailsTaskViewSelectedState();
}

class _AppointmentDetailsTaskViewSelectedState
    extends State<AppointmentDetailsTaskViewSelected> {
  DateTime validity = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: widget.onClose,
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            label: Text(
              'To Appointments List',
              style: theme.textTheme.labelLarge,
            ),
          ),
          Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Schedule',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Show a date picker when it is tapped
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate:
                              widget.taskAppointmentSummary.dueDate ??
                              DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2201),
                        );

                        if (selectedDate != null) {
                          await TaskAppointmentSummaryService()
                              .updateTaskAppointmentRow(
                                taskAppointmentId:
                                    widget
                                        .taskAppointmentSummary
                                        .taskAppointmentId!,
                                dueDate: selectedDate,
                              );
                          widget.onUpdate();
                        }
                      },
                      label: Text(
                        widget.taskAppointmentSummary.dueDate
                                ?.formatToMilitaryString() ??
                            "No Schedule",
                        style:
                            widget.taskAppointmentSummary.dueDate == null
                                ? theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.error,
                                )
                                : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text("Procedures", style: theme.textTheme.labelLarge),
                        FutureBuilder(
                          key: ValueKey(
                            "procedures_future_builder_${validity.millisecondsSinceEpoch}",
                          ),
                          initialData: TaskAppointmentProcedureService()
                              .getByAppointmentIdCache(
                                widget
                                    .taskAppointmentSummary
                                    .taskAppointmentId!,
                              ),
                          future: TaskAppointmentProcedureService()
                              .getByAppointmentId(
                                widget
                                    .taskAppointmentSummary
                                    .taskAppointmentId!,
                                cached: false,
                              ),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                (!snapshot.hasData || snapshot.data!.isEmpty)) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Text('No Procedures Found');
                            }
                            final procedures = snapshot.data!;
                            // no null clinic Id
                            final clinicIds =
                                procedures
                                    .map((procedure) => procedure.clinic)
                                    .toSet()
                                    .toList();

                          

                            return ListView.builder(
                              shrinkWrap: true,
                              primary: false,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: clinicIds.length,
                              itemBuilder: (context, clinicIndex) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (clinicIds[clinicIndex] != null)
                                      Row(
                                        children: [
                                          FutureBuilder(
                                            initialData: ProjectService()
                                                .getFromCache(
                                                  clinicIds[clinicIndex]!,
                                                ),
                                            future: ProjectService().getFromId(
                                              clinicIds[clinicIndex]!,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasError) {
                                                return Text(
                                                  'Error: ${snapshot.error}',
                                                );
                                              }
                                              if (snapshot.connectionState ==
                                                      ConnectionState.waiting &&
                                                  !snapshot.hasData) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                              if (!snapshot.hasData) {
                                                return const Text(
                                                  'No clinic information available',
                                                );
                                              }
                                              return Text(
                                                snapshot.data?.title ??
                                                    'Unknown Clinic',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .outline,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              );
                                            },
                                          ),
                                          Expanded(
                                            child: Divider(
                                              height: 1,
                                              indent: 8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      primary: false,
                                      physics: NeverScrollableScrollPhysics(),
                                      separatorBuilder:
                                          (context, index) =>
                                              SizedBox(height: 12),
                                      itemCount: procedures.length,
                                      itemBuilder: (context, index) {
                                        return ProcedureItem(
                                          procedure: procedures[index],
                                          theme: theme,
                                          onDelete: (deletedProcedure) {
                                            // refresh snapshot
                                            setState(() {
                                              validity = DateTime.now();
                                            });
                                          },
                                          onUpdate: (updatedProcedure) {
                                            setState(() {
                                              validity = DateTime.now();
                                            });
                                          },
                                        );
                                      },
                                    ),

                                    SizedBox(height: 16),
                                    InkWell(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8.0,
                                            ),
                                            border: Border.all(
                                              color: theme.colorScheme.outline,
                                              width: 1.0,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Add Procedure',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onSurface,
                                                    ),
                                              ),
                                              Icon(Icons.add_chart_outlined),
                                            ],
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        final task = await TaskService()
                                            .getFromId(
                                              widget
                                                  .taskAppointmentSummary
                                                  .taskId!,
                                            );
                                        if (task == null) return;

                                        if (!context.mounted) return;
                                        final selectedProcedure =
                                            await ProcedureAddDialog.show(
                                              context: context,
                                              appointmentSummary:
                                                  widget.taskAppointmentSummary,
                                              initalClinic: task.project,
                                            );

                                        // insert and update procedure
                                        if (selectedProcedure == null) return;
                                        final tas =
                                            widget.taskAppointmentSummary;
                                        await TaskAppointmentProcedureService()
                                            .createProcedure(
                                              appointment:
                                                  tas.taskAppointmentId!,
                                              discountAmount: 0,
                                              // TODO CLINIC CONTINURE HERE
                                              clinic: ,
                                              procedure: selectedProcedure.id,
                                              procedureName:
                                                  selectedProcedure.titleEng ??
                                                  selectedProcedure.titleKor,
                                              procedurePrice:
                                                  selectedProcedure
                                                      .totalPrice ??
                                                  0,
                                              procedureCommission:
                                                  selectedProcedure
                                                      .commission ??
                                                  0,
                                            );
                                        if (!mounted) return;
                                        setState(() {
                                          validity = DateTime.now();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

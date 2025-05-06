import 'package:flutter/material.dart';
import 'package:sgm/extensions/responsive.extension.dart';
import 'package:sgm/row_row_row_generated/tables/task_appointment_procedure.row.dart';
import 'package:sgm/services/task_appointment_procedure.service.dart';
import 'package:sgm/widgets/confirm_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProcedureItem extends StatefulWidget {
  const ProcedureItem({
    super.key,
    required this.procedure,
    required this.theme,
    this.onDelete,
    this.onUpdate,
  });

  final TaskAppointmentProcedureRow procedure;
  final ThemeData theme;
  final void Function(TaskAppointmentProcedureRow deletedProcedure)? onDelete;
  final void Function(TaskAppointmentProcedureRow updatedProcedure)? onUpdate;

  @override
  State<ProcedureItem> createState() => _ProcedureItemState();
}

class _ProcedureItemState extends State<ProcedureItem> {
  Future<void> updatePaid(bool? value) async {
    if (value == false) {
      // confirm first before removing
      final confirmRemovePayment = await ConfirmDialog.show(
        context: context,
        title: 'Remove Payment',
        message: 'Are you sure you want to remove the payment?',
        confirmText: 'Yes',
        cancelText: 'No',
      );

      if (!confirmRemovePayment) return;
      await Supabase.instance.client
          .from(TaskAppointmentProcedureRow.table)
          .update({TaskAppointmentProcedureRow.field.paidOn: null})
          .eq(TaskAppointmentProcedureRow.field.id, widget.procedure.id);
      widget.onUpdate?.call(widget.procedure);

      return;
    }
    if (value == true) {
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (selectedDate == null) return;

      await TaskAppointmentProcedureService().updateProcedure(
        id: widget.procedure.id,
        paidOn: selectedDate.toUtc(),
      );
      widget.onUpdate?.call(widget.procedure);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).isPhone;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.procedure.procedureName ?? 'No procedure Name',
                style: widget.theme.textTheme.titleMedium,
              ),
              if (isPhone) Text(widget.procedure.notes ?? "No notes"),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!isPhone)
                          Text(widget.procedure.notes ?? "No notes"),
                        SizedBox(height: 8.0),
                        InkWell(
                          onTap: () async {
                            final confirmationResponse = await ConfirmDialog.show(
                              context: context,
                              title: 'Delete Procedure',
                              message:
                                  'Are you sure you want to delete this procedure? This action cannot be undone.',
                              confirmText: 'Delete',
                              cancelText: 'Cancel',
                            );

                            if (confirmationResponse) {
                              try {
                                final service =
                                    TaskAppointmentProcedureService();
                                final success = await service.deleteProcedure(
                                  widget.procedure.id,
                                );

                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Procedure deleted successfully',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  // Notify parent about the deletion if needed
                                  if (widget.onDelete != null) {
                                    widget.onDelete!(widget.procedure);
                                  }
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Failed to delete procedure',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error deleting procedure: ${e.toString()}',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                'Delete',
                                style: widget.theme.textTheme.bodyMedium
                                    ?.copyWith(
                                      color: widget.theme.colorScheme.error,
                                    ),
                              ),
                              Icon(
                                Icons.delete_forever,
                                color: widget.theme.colorScheme.error,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Procedure Price: ${widget.procedure.procedurePrice}',
                        style: widget.theme.textTheme.titleSmall,
                      ),
                      Text(
                        'Commission: ${widget.procedure.commissionEnteredByUser ?? widget.procedure.procedureCommission}',
                        style: widget.theme.textTheme.titleSmall?.copyWith(
                          color: widget.theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            await updatePaid(!(widget.procedure.paidOn != null));
          },
          child: Row(
            children: [
              Checkbox(
                value: widget.procedure.paidOn != null,
                onChanged: updatePaid,
              ),
              Text('Paid', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        Column(
          children: [
            // TODO expenses
          ],
        ),
      ],
    );
  }
}

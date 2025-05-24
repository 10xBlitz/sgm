// Add this class at the end of the file, after the _ProceduresEditScreenState class

import 'package:flutter/material.dart';
import 'package:sgm/services/procedure.service.dart';

class ProcedureDeleteButtonDialog extends StatefulWidget {
  final String procedureId;
  final String procedureName;
  final VoidCallback onDeleted;
  final bool isLoading;

  const ProcedureDeleteButtonDialog({
    super.key,
    required this.procedureId,
    required this.procedureName,
    required this.onDeleted,
    this.isLoading = false,
  });

  @override
  State<ProcedureDeleteButtonDialog> createState() =>
      _ProcedureDeleteButtonDialogState();
}

class _ProcedureDeleteButtonDialogState
    extends State<ProcedureDeleteButtonDialog> {
  bool isDeleting = false;
  final procedureService = ProcedureService();

  Future<void> deleteProcedure() async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to delete ${widget.procedureName}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final result = await procedureService.deleteProcedure(widget.procedureId);

      if (!mounted) return;

      if (result) {
        procedureService.clearCache();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procedure deleted successfully')),
        );

        widget.onDeleted();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete procedure')),
        );

        setState(() {
          isDeleting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting procedure: $e')));

      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: widget.isLoading || isDeleting ? null : deleteProcedure,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
      icon: Icon(Icons.delete),
    );
  }
}

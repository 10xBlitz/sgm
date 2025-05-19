import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/project_task_status.row.dart';
import 'package:sgm/services/project_task_status.service.dart';
import 'package:sgm/services/task.service.dart';

class UpdateTaskStatusDialog extends StatefulWidget {
  final String projectId;
  final String taskId;
  final String currentStatus;
  final Future<void> Function()? onStatusUpdated;

  const UpdateTaskStatusDialog({
    super.key,
    required this.projectId,
    required this.taskId,
    required this.currentStatus,
    this.onStatusUpdated,
  });

  @override
  State<UpdateTaskStatusDialog> createState() => _UpdateTaskStatusDialogState();
}

class _UpdateTaskStatusDialogState extends State<UpdateTaskStatusDialog> {
  String? selectedStatusId;
  List<ProjectTaskStatusRow> _statuses = [];
  bool _isLoading = true;
  final _statusService = ProjectTaskStatusService();

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    try {
      final statuses = await _statusService.getStatusByProjectID(widget.projectId);
      if (!mounted) return;
      
      // Find the current status ID
      final currentStatus = statuses.firstWhere(
        (status) => status.status == widget.currentStatus,
        orElse: () => statuses.first,
      );
      
      setState(() {
        _statuses = statuses;
        selectedStatusId = currentStatus.id;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    if (selectedStatusId == null) return;
    setState(() {
      _isLoading = true;
    });
    
    try {
      await TaskService().updateTask(
        id: widget.taskId,
        status: selectedStatusId,
      );
      
      if (!mounted) return;
      if (widget.onStatusUpdated != null) {
        await widget.onStatusUpdated!();
      }
      setState(() {
        _isLoading = false;
      });
      if(!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Update Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedStatusId,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                items: _statuses.map((status) => DropdownMenuItem(
                  value: status.id,
                  child: Text(status.status ?? 'Unknown Status'),
                ),).toList(),
                onChanged: (newStatusId) {
                  setState(() {
                    selectedStatusId = newStatusId;
                  });
                },
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD1B06B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _updateStatus,
                child: const Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
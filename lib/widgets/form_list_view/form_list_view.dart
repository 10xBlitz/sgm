import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/form.row.dart';
import 'package:sgm/screens/form/form_screen.dart';
import 'package:sgm/services/form.service.dart';
import 'package:sgm/utils/my_logger.dart';
import 'package:sgm/widgets/item/item_form.dart';

class FormListView extends StatefulWidget {
  const FormListView({
    super.key,
    required this.projectId,
    required this.onFormUpdated,
  });

  final String projectId;
  final Function() onFormUpdated;

  @override
  State<FormListView> createState() => FormListViewState();
}

class FormListViewState extends State<FormListView> {
  List<FormRow> _forms = [];
  bool _isLoadingForms = true;

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() {
      _isLoadingForms = true;
    });

    try {
      final forms = await FormService().getFormsByProject(widget.projectId);
      setState(() {
        _forms = forms;
        _isLoadingForms = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingForms = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading forms: $e')));
      }
    }
  }

  Future<void> reload() async {
    await _loadForms();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoadingForms) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_forms.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No forms for this project.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Forms',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ..._forms.map(
            (form) => ItemForm(
              theme: theme,
              form: form,
              onTap: () {
                MyLogger.d('Form tapped: ${widget.projectId}');
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) {
                          return FormScreen(
                            formId: form.id,
                            projectId: widget.projectId,
                          );
                        },
                      ),
                    )
                    .then((context) async {
                      await widget.onFormUpdated();
                    });
              },
            ),
          ),
          const Divider(height: 1),
        ],
      );
    }
  }
} 
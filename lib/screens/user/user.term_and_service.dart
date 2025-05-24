import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgm/row_row_row_generated/tables/terms_and_condition.row.dart';
import 'package:sgm/services/auth.service.dart';
import 'package:sgm/services/terms.service.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  static const routeName = "/terms-and-conditions";
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final _termsService = TermsService();

  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  bool _isLoading = true;
  TermsAndConditionRow? _terms;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadTerms() async {
    setState(() => _isLoading = true);
    try {
      final terms = await _termsService.getLatestTermsAndConditions();
      setState(() {
        _terms = terms;
        _contentController.text = terms.terms;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading terms: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTerms() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _termsService.updateTermsAndConditions(
        _terms!.id,
        _contentController.text,
      );

      _termsService.clearCache();
      await _loadTerms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terms updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating terms: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    spacing: 16,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terms and Condition'),
                      Text(
                        'Last Updated: ${DateFormat('MMM dd, yyyy').format(_terms!.createdAt!)}',
                      ),
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _contentController,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Terms content cannot be empty';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: "Edit Terms",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _saveTerms,
                          child: Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

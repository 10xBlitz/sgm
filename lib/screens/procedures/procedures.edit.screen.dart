import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:sgm/row_row_row_generated/tables/clinic_area_procedure_category_dropdown_entries.row.dart';
import 'package:sgm/services/procedure.service.dart';

class ProceduresEditScreen extends StatefulWidget {
  static const routeName = "/procedures/edit";
  final String procedureId;

  const ProceduresEditScreen({
    super.key,
    required this.procedureId,
  });

  @override
  State<ProceduresEditScreen> createState() => _ProceduresEditScreenState();
}

class _ProceduresEditScreenState extends State<ProceduresEditScreen> {
  final procedureService = ProcedureService();
  bool isLoading = true;
  bool isEditing = false;

  // Form controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final explanationController = TextEditingController();
  final totalPriceController = TextEditingController();
  final commissionController = TextEditingController();

  // Data
  ProcedureWithCategoryClinicAreaNamesRow? procedure;
  List<ClinicAreaProcedureCategoryDropdownEntriesRow> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    loadProcedure();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    explanationController.dispose();
    totalPriceController.dispose();
    commissionController.dispose();
    super.dispose();
  }

  Future<void> loadProcedure() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await procedureService.getFromId(widget.procedureId);

      if (result != null) {
        setState(() async {
          procedure = await getProcedureWithDetails(result.id);

          // Populate form fields
          titleController.text = procedure?.titleEng ?? '';
          descriptionController.text = procedure?.description ?? '';
          explanationController.text = procedure?.explanation ?? '';
          totalPriceController.text =
              procedure?.totalPrice?.toString() ?? '0.00';
          commissionController.text =
              procedure?.commission?.toString() ?? '0.00';
          selectedCategory = procedure?.category;

          isLoading = false;
        });

        await loadCategories();
      } else {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procedure not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading procedure: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<ProcedureWithCategoryClinicAreaNamesRow?> getProcedureWithDetails(
    String id,
  ) async {
    try {
      final procedure = await procedureService.getProcedureById(id);
      return procedure;
    } catch (e) {
      return null;
    }
  }

  Future<void> loadCategories() async {
    if (procedure?.clinicId == null) return;

    try {
      final entries = await procedureService
          .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueCategories =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (entry.clinicId == procedure?.clinicId &&
            entry.procedureCategoryId != null &&
            !uniqueCategories.containsKey(entry.procedureCategoryId)) {
          uniqueCategories[entry.procedureCategoryId!] = entry;
        }
      }

      setState(() {
        categories = uniqueCategories.values.toList();
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> updateProcedure() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await procedureService.updateProcedure(
        id: widget.procedureId,
        titleEng: titleController.text,
        description: descriptionController.text,
        explanation: explanationController.text,
        totalPrice: double.tryParse(totalPriceController.text) ?? 0.0,
        commission: double.tryParse(commissionController.text) ?? 0.0,
        category: selectedCategory ?? procedure?.category,
      );

      if (result != null) {
        setState(() {
          isEditing = false;
          procedure = result as ProcedureWithCategoryClinicAreaNamesRow?;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Procedure updated successfully')),
        );
      } else {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update procedure')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating procedure: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedure Details'),
        actions: [
          if (!isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            )
          else
            IconButton(
              onPressed: () {
                setState(() {
                  // Reset form fields to original values
                  titleController.text = procedure?.titleEng ?? '';
                  descriptionController.text = procedure?.description ?? '';
                  explanationController.text = procedure?.explanation ?? '';
                  totalPriceController.text =
                      procedure?.totalPrice?.toString() ?? '0.00';
                  commissionController.text =
                      procedure?.commission?.toString() ?? '0.00';
                  selectedCategory = procedure?.category;

                  isEditing = false;
                });
              },
              icon: const Icon(Icons.cancel),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: buildFormContent(),
                    ),
                  ),
                  if (isEditing) buildActionButton(),
                ],
              ),
            ),
    );
  }

  Widget buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFormField(
          label: 'Procedure Name',
          value: procedure?.titleEng ?? '',
          controller: titleController,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Description',
          value: procedure?.description ?? '',
          controller: descriptionController,
          maxLines: 3,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        buildFormField(
          label: 'Explanation',
          value: procedure?.explanation ?? '',
          controller: explanationController,
          maxLines: 3,
          enabled: isEditing,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: buildFormField(
                label: 'Total Price',
                value: procedure?.totalPrice?.toString() ?? '0.00',
                controller: totalPriceController,
                keyboardType: TextInputType.number,
                enabled: isEditing,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: buildFormField(
                label: 'Commission',
                value: procedure?.commission?.toString() ?? '0.00',
                controller: commissionController,
                keyboardType: TextInputType.number,
                enabled: isEditing,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Clinic',
          value: procedure?.clinicName ?? 'Unknown Clinic',
        ),
        const SizedBox(height: 16),
        if (isEditing && categories.isNotEmpty)
          buildCategoryDropdown()
        else
          buildInfoField(
            label: 'Category',
            value: procedure?.categoryName ?? 'Unknown Category',
          ),
        const SizedBox(height: 16),
        buildInfoField(
          label: 'Area',
          value: procedure?.clinicAreaName ?? 'Unknown Area',
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildFormField({
    required String label,
    required String value,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: value,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget buildInfoField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Widget buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              hint: const Text('Select Category'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category.procedureCategoryId,
                        child: Text(category.procedureCategoryName ??
                            'Unknown Category'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : updateProcedure,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4B978),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            'Update Procedure',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

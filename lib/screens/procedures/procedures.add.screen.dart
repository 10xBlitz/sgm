import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sgm/services/procedure.service.dart';
import 'package:sgm/row_row_row_generated/tables/clinic_area_procedure_category_dropdown_entries.row.dart';

class ProceduresAddScreen extends StatefulWidget {
  static const routeName = "/procedures/add";
  const ProceduresAddScreen({super.key});

  @override
  State<ProceduresAddScreen> createState() => _ProceduresAddScreenState();
}

class _ProceduresAddScreenState extends State<ProceduresAddScreen> {
  final procedureService = ProcedureService();
  bool isLoading = false;

  // Form controllers
  final englishNameController = TextEditingController();
  final koreanNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final explanationController = TextEditingController();
  final totalPriceController = TextEditingController();
  final commissionController = TextEditingController();
  final categoryNameController = TextEditingController();

  String? selectedClinic;
  String? selectedCategory;

  List<ClinicAreaProcedureCategoryDropdownEntriesRow> clinics = [];
  List<ClinicAreaProcedureCategoryDropdownEntriesRow> categories = [];

  @override
  void initState() {
    super.initState();
    loadClinics();
  }

  @override
  void dispose() {
    englishNameController.dispose();
    koreanNameController.dispose();
    descriptionController.dispose();
    explanationController.dispose();
    totalPriceController.dispose();
    commissionController.dispose();
    categoryNameController.dispose();
    super.dispose();
  }

  Future<void> loadClinics() async {
    try {
      setState(() {
        isLoading = true;
      });

      final entries = await procedureService
          .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueClinics =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (entry.clinicId != null &&
            !uniqueClinics.containsKey(entry.clinicId)) {
          uniqueClinics[entry.clinicId!] = entry;
        }
      }

      setState(() {
        clinics = uniqueClinics.values.toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading clinics: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadCategories(String clinicId) async {
    try {
      setState(() {
        isLoading = true;
      });

      final entries = await procedureService
          .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueCategories =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (entry.clinicId == clinicId &&
            entry.procedureCategoryId != null &&
            !uniqueCategories.containsKey(entry.procedureCategoryId)) {
          uniqueCategories[entry.procedureCategoryId!] = entry;
        }
      }

      setState(() {
        categories = uniqueCategories.values.toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createProcedure() async {
    if (englishNameController.text.isEmpty) {
      showSnackBar('Please enter a procedure name');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Convert string values to appropriate types
      double? totalPrice = double.tryParse(totalPriceController.text);
      double? commission = double.tryParse(commissionController.text);

      // Create procedure using the service
      final result = await procedureService.createProcedure(
        titleEng: englishNameController.text,
        titleKor: koreanNameController.text, // Same as English for now
        commission: commission ?? 0,
        totalPrice: totalPrice ?? 0,
        category: selectedCategory ?? '',
        description: descriptionController.text,
        explanation: explanationController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (result != null) {
        showSnackBar('Procedure created successfully');
        debugPrint('Created procedure: ${result.id} $result ');
        context.pop();
      } else {
        showSnackBar('Failed to create procedure');
      }
    } catch (e) {
      debugPrint('Error creating procedure: $e');
      setState(() {
        isLoading = false;
      });
      showSnackBar('Error: $e');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedure'),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFormField(
                label: 'English Procedure Name',
                hintText: 'Enter English Procedure Name...',
                controller: englishNameController,
              ),
              buildFormField(
                label: 'Korean Procedure Name',
                hintText: 'Enter Korean Procedure Name...',
                controller: koreanNameController,
              ),
              const SizedBox(height: 16),
              buildFormField(
                label: 'Description',
                hintText: 'Enter Description...',
                controller: descriptionController,
              ),
              const SizedBox(height: 16),
              buildFormField(
                label: 'Explanation',
                hintText: 'Enter Explanation...',
                controller: explanationController,
              ),
              const SizedBox(height: 16),
              buildFormField(
                label: 'Total Price',
                hintText: '0.00',
                controller: totalPriceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildFormField(
                label: 'Commission',
                hintText: '0.00',
                controller: commissionController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              buildDropdownField(
                label: 'Clinic',
                isLoading: isLoading,
                value: selectedClinic,
                items: clinics
                    .map((clinic) => DropdownMenuItem(
                          value: clinic.clinicId,
                          child: Text(clinic.clinicName ?? 'Unknown Clinic'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedClinic = value;
                    selectedCategory = null;
                  });
                  if (value != null) {
                    loadCategories(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Category',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'If no category is selected, it will create a new category.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (categories.isNotEmpty)
                buildDropdownField(
                  label: 'Category',
                  isLoading: isLoading,
                  value: selectedCategory,
                  items: categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.procedureCategoryId,
                          child: Text(
                            category.procedureCategoryName ??
                                'Unknown Category',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                )
              else
                buildFormField(
                  label: '',
                  showLabel: false,
                  hintText: 'Enter Category Name',
                  controller: categoryNameController,
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createProcedure,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4B978),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Create Procedure',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFormField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        if (showLabel) const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String label,
    required bool isLoading,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    bool showLabel = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        if (showLabel) const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              value: value,
              hint: const Text('Select...'),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: items,
              onChanged: isLoading ? null : onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}

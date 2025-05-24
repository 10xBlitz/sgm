import 'package:flutter/material.dart';
import 'package:sgm/services/procedure.service.dart';
import 'package:sgm/row_row_row_generated/tables/clinic_area_procedure_category_dropdown_entries.row.dart';
import 'package:sgm/widgets/procedures/procedure_dropdown_field.dart';
import 'package:sgm/widgets/procedures/procedure_form_field.dart';

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

      final entries =
          await procedureService
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

      final entries =
          await procedureService
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
        procedureService.clearCache();
        showSnackBar('Procedure created successfully');
        debugPrint('Created procedure: ${result.id} $result ');
        if (!mounted) return;
        Navigator.of(context).pop(true);
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procedure'),
        // actions: [
        //   IconButton(
        //     onPressed: () => context.pop(),
        //     icon: const Icon(Icons.close),
        //   ),
        // ],
        // automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProcedureFormField(
                label: 'English Procedure Name',
                hintText: 'Enter English Procedure Name...',
                controller: englishNameController,
              ),
              ProcedureFormField(
                label: 'Korean Procedure Name',
                hintText: 'Enter Korean Procedure Name...',
                controller: koreanNameController,
              ),
              const SizedBox(height: 16),
              ProcedureFormField(
                label: 'Description',
                hintText: 'Enter Description...',
                controller: descriptionController,
              ),
              const SizedBox(height: 16),
              ProcedureFormField(
                label: 'Explanation',
                hintText: 'Enter Explanation...',
                controller: explanationController,
              ),
              const SizedBox(height: 16),
              ProcedureFormField(
                label: 'Total Price',
                hintText: '0.00',
                controller: totalPriceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ProcedureFormField(
                label: 'Commission',
                hintText: '0.00',
                controller: commissionController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ProcedureDropdownField(
                label: 'Clinic',
                isLoading: isLoading,
                value: selectedClinic,
                items:
                    clinics
                        .map(
                          (clinic) => DropdownMenuItem(
                            value: clinic.clinicId,
                            child: Text(clinic.clinicName ?? 'Unknown Clinic'),
                          ),
                        )
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
              const Text('Category', style: TextStyle(fontSize: 16)),
              const Text(
                'If no category is selected, it will create a new category.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              if (categories.isNotEmpty)
                ProcedureDropdownField(
                  label: 'Category',
                  isLoading: isLoading,
                  value: selectedCategory,
                  items:
                      categories
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
                ProcedureFormField(
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
}

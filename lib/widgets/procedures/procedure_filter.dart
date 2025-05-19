import 'package:flutter/material.dart';
import 'package:sgm/row_row_row_generated/tables/clinic_area_procedure_category_dropdown_entries.row.dart';
import 'package:sgm/services/procedure.service.dart';

class ProcedureFilter extends StatefulWidget {
  const ProcedureFilter({super.key});

  @override
  State<ProcedureFilter> createState() => _ProcedureFilterState();
}

class _ProcedureFilterState extends State<ProcedureFilter> {
  // Data lists

  final procedureService = ProcedureService();
  bool isLoading = false;

  List<ClinicAreaProcedureCategoryDropdownEntriesRow> areas = [];
  List<ClinicAreaProcedureCategoryDropdownEntriesRow> clinics = [];
  List<ClinicAreaProcedureCategoryDropdownEntriesRow> categories = [];

  // Selected filters
  List<String> selectedAreaId = [];
  List<String> selectedClinicId = [];
  List<String> selectedCategoryId = [];

  @override
  void initState() {
    super.initState();
    loadAreas();
    loadClinics();
    loadCategories();
  }

  Future<void> loadAreas() async {
    try {
      final areasList = await procedureService.getUniqueClinicAreas();
      setState(() {
        areas = areasList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading areas: $e');
      rethrow;
    }
  }

  // load clinics
  Future<void> loadClinics() async {
    try {
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
      });
    } catch (e) {
      debugPrint('Error loading clinics: $e');
      rethrow;
    }
  }

  // load categories
  Future<void> loadCategories() async {
    try {
      final entries =
          await procedureService
              .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueCategories =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (entry.procedureCategoryId != null &&
            !uniqueCategories.containsKey(entry.procedureCategoryId)) {
          uniqueCategories[entry.procedureCategoryId!] = entry;
        }
      }

      setState(() {
        categories = uniqueCategories.values.toList();
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }

  Future<void> loadClinicsForArea(List<String> areas) async {
    try {
      final entries =
          await procedureService
              .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueClinics =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (areas.contains(entry.clinicAreaId) &&
            entry.clinicId != null &&
            !uniqueClinics.containsKey(entry.clinicId)) {
          uniqueClinics[entry.clinicId!] = entry;
        }
      }

      setState(() {
        clinics = uniqueClinics.values.toList();
        selectedClinicId = [];
        selectedCategoryId = [];
        categories = [];
      });
    } catch (e) {
      debugPrint('Error loading clinics: $e');
      rethrow;
    }
  }

  Future<void> loadCategoriesForClinic(List<String>? clinicIds) async {
    try {
      final entries =
          await procedureService
              .getClinicAreaProcedureCategoryDropdownEntries();
      final uniqueCategories =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};

      for (final entry in entries) {
        if (clinicIds?.contains(entry.clinicId) == true &&
            entry.procedureCategoryId != null &&
            !uniqueCategories.containsKey(entry.procedureCategoryId)) {
          uniqueCategories[entry.procedureCategoryId!] = entry;
        }
      }

      setState(() {
        categories = uniqueCategories.values.toList();
        selectedCategoryId = [];
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      rethrow;
    }
  }

  void onAreaSelected(String areaId) {
    setState(() {
      if (selectedAreaId.contains(areaId)) {
        selectedAreaId.remove(areaId);
      } else {
        selectedAreaId.add(areaId);
      }
    });

    if (selectedAreaId.isNotEmpty) {
      loadClinicsForArea(selectedAreaId);
    } else {
      loadClinics();
    }
  }

  void onClinicSelected(String clinicId) {
    setState(() {
      if (selectedClinicId.contains(clinicId)) {
        selectedClinicId.remove(clinicId);
      } else {
        selectedClinicId.add(clinicId);
      }
    });
    if (selectedClinicId.isNotEmpty) {
      loadCategoriesForClinic(selectedClinicId);
    } else {
      loadCategories();
    }
  }

  void onCategorySelected(String categoryId) {
    setState(() {
      if (selectedCategoryId.contains(categoryId)) {
        selectedCategoryId.remove(categoryId);
      } else {
        selectedCategoryId.add(categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Area'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showAreaSelectorDialog(context),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedAreaId.isEmpty
                              ? 'Select...'
                              : '${selectedAreaId.length} selected',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Clinics'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showClinicSelectorDialog(context),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Select...',
                          style: TextStyle(color: Colors.black87),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => _showCategorySelectorDialog(context),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedCategoryId.isEmpty
                              ? 'Select...'
                              : '${selectedCategoryId.length} selected',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClinicSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Clinics'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children:
                      clinics.map((clinic) {
                        final isSelected = selectedClinicId.contains(
                          clinic.clinicId,
                        );
                        return CheckboxListTile(
                          title: Text(clinic.clinicName ?? ''),
                          value: isSelected,
                          onChanged: (bool? checked) {
                            setState(() {
                              onClinicSelected(clinic.clinicId!);
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAreaSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        String localSearch = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final filteredAreas =
                areas.where((area) {
                  return area.areaName?.toLowerCase().contains(
                        localSearch.toLowerCase(),
                      ) ??
                      false;
                }).toList();

            return AlertDialog(
              title: const Text('Select Areas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search Field
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        localSearch = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Area List
                  SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView(
                      children:
                          filteredAreas.map((area) {
                            final isSelected = selectedAreaId.contains(
                              area.clinicAreaId,
                            );
                            return CheckboxListTile(
                              title: Text(area.areaName ?? ''),
                              value: isSelected,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (isSelected) {
                                    selectedAreaId.remove(area.clinicAreaId);
                                  } else {
                                    selectedAreaId.add(area.clinicAreaId!);
                                  }
                                });
                                // Also trigger clinic load
                                loadClinicsForArea(selectedAreaId);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCategorySelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        String localSearch = '';

        return StatefulBuilder(
          builder: (context, setState) {
            final filteredCategories =
                categories.where((category) {
                  return category.procedureCategoryName?.toLowerCase().contains(
                        localSearch.toLowerCase(),
                      ) ??
                      false;
                }).toList();

            return AlertDialog(
              title: const Text('Select Categories'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        localSearch = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Category list
                  SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: ListView(
                      children:
                          filteredCategories.map((category) {
                            final isSelected = selectedCategoryId.contains(
                              category.procedureCategoryId,
                            );
                            return CheckboxListTile(
                              title: Text(category.procedureCategoryName ?? ''),
                              value: isSelected,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (isSelected) {
                                    selectedCategoryId.remove(
                                      category.procedureCategoryId,
                                    );
                                  } else {
                                    selectedCategoryId.add(
                                      category.procedureCategoryId!,
                                    );
                                  }
                                });

                                // Optionally trigger something on change
                                // loadSomething(selectedCategoryId);
                              },
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

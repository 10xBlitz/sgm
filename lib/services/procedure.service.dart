import 'package:flutter/foundation.dart';
import 'package:sgm/row_row_row_generated/tables/clinic_area_procedure_category_dropdown_entries.row.dart';
import 'package:sgm/row_row_row_generated/tables/procedure.row.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_category.row.dart';
import 'package:sgm/row_row_row_generated/tables/procedure_with_category_clinic_area_names.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service class for handling procedure-related operations with Supabase.
class ProcedureService {
  // Singleton instance
  static final ProcedureService _instance = ProcedureService._internal();

  // Factory constructor to return the singleton instance
  factory ProcedureService() => _instance;

  // Private constructor
  ProcedureService._internal();

  // Reference to the Supabase client
  final _supabase = Supabase.instance.client;

  // Cache for procedure objects
  final Map<String, ProcedureRow> _cache = {};

  // Cache for procedures by category
  final Map<String, List<ProcedureRow>> _categoryCache = {};

  // Cache for procedures by clinic
  final Map<String, List<ProcedureRow>> _clinicCache = {};

  // Cache for procedure categories
  final Map<String, ProcedureCategoryRow> _categoriesCache = {};

  // Cache for procedure categories by clinic
  final Map<String, List<ProcedureCategoryRow>> _clinicCategoriesCache = {};

  /// Cache for clinic area procedure category dropdown entries
  final Map<String, List<ClinicAreaProcedureCategoryDropdownEntriesRow>>
      _dropdownEntriesCache = {};

  final Map<String, List<ProcedureWithCategoryClinicAreaNamesRow>>
      _proceduresViewCache = {};

  /// Creates a new procedure in the database.
  Future<ProcedureRow?> createProcedure({
    required String? titleEng,
    String? titleKor,
    required double? commission,
    required double? totalPrice,
    required String? category,
    String? description,
    String? explanation,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        ProcedureRow.field.createdAt: now.toIso8601String(),
        if (titleEng != null) ProcedureRow.field.titleEng: titleEng,
        if (titleKor != null) ProcedureRow.field.titleKor: titleKor,
        if (commission != null) ProcedureRow.field.commission: commission,
        if (totalPrice != null) ProcedureRow.field.totalPrice: totalPrice,
        if (category != null) ProcedureRow.field.category: category,
        if (description != null) ProcedureRow.field.description: description,
        if (explanation != null) ProcedureRow.field.explanation: explanation,
      };

      final response = await _supabase
          .from(ProcedureRow.table)
          .insert(data)
          .select()
          .single();

      final procedure = ProcedureRow.fromJson(response);
      _cache[procedure.id] = procedure;

      // Update category cache if applicable
      if (category != null && _categoryCache.containsKey(category)) {
        _categoryCache[category]!.add(procedure);
      }

      return procedure;
    } catch (error) {
      debugPrint('Error creating procedure: $error');
      return null;
    }
  }

  /// Gets a procedure by its ID.
  Future<ProcedureRow?> getFromId(String id, {bool cached = true}) async {
    // Return from cache if available and allowed
    if (cached && _cache.containsKey(id)) {
      return _cache[id];
    }

    try {
      final response = await _supabase
          .from(ProcedureRow.table)
          .select()
          .eq(ProcedureRow.field.id, id)
          .single();

      final procedure = ProcedureRow.fromJson(response);
      _cache[id] = procedure;
      return procedure;
    } catch (error) {
      debugPrint('Error fetching procedure by ID: $error');
      return null;
    }
  }

  /// Gets all procedures.
  Future<List<ProcedureRow>> getAllProcedures() async {
    try {
      final response = await _supabase
          .from(ProcedureRow.table)
          .select()
          .order(ProcedureRow.field.createdAt, ascending: false);

      final procedures = response.map<ProcedureRow>((data) {
        final procedure = ProcedureRow.fromJson(data);
        _cache[procedure.id] = procedure;
        return procedure;
      }).toList();

      return procedures;
    } catch (error) {
      debugPrint('Error fetching all procedures: $error');
      return [];
    }
  }

  /// Gets procedures by category ID.
  Future<List<ProcedureRow>> getProceduresByCategory(
    String categoryId, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _categoryCache.containsKey(categoryId)) {
      return _categoryCache[categoryId]!;
    }

    try {
      final response = await _supabase
          .from(ProcedureRow.table)
          .select()
          .eq(ProcedureRow.field.category, categoryId)
          .order(ProcedureRow.field.createdAt, ascending: false);

      final procedures = response.map<ProcedureRow>((data) {
        final procedure = ProcedureRow.fromJson(data);
        _cache[procedure.id] = procedure;
        return procedure;
      }).toList();

      _categoryCache[categoryId] = procedures;
      return procedures;
    } catch (error) {
      debugPrint('Error fetching procedures by category: $error');
      return [];
    }
  }

  /// Gets procedures by clinic ID using the procedure_with_category_clinic_area_names view.
  Future<List<ProcedureWithCategoryClinicAreaNamesRow>> getProceduresByClinic(
    String clinicId, {
    bool cached = true,
  }) async {
    try {
      final response = await _supabase
          .from(ProcedureWithCategoryClinicAreaNamesRow.table)
          .select()
          .eq(ProcedureWithCategoryClinicAreaNamesRow.field.clinicId, clinicId)
          .order(
            ProcedureWithCategoryClinicAreaNamesRow.field.createdAt,
            ascending: false,
          );

      final procedures =
          response.map<ProcedureWithCategoryClinicAreaNamesRow>((data) {
        return ProcedureWithCategoryClinicAreaNamesRow.fromJson(data);
      }).toList();

      return procedures;
    } catch (error) {
      debugPrint('Error fetching procedures by clinic: $error');
      return [];
    }
  }

  /// Gets procedures by clinic ID and category ID using the procedure_with_category_clinic_area_names view.
  Future<List<ProcedureWithCategoryClinicAreaNamesRow>>
      getProceduresByClinicAndCategory(
          String clinicId, String categoryId) async {
    try {
      final response = await _supabase
          .from(ProcedureWithCategoryClinicAreaNamesRow.table)
          .select()
          .eq(ProcedureWithCategoryClinicAreaNamesRow.field.clinicId, clinicId)
          .eq(
            ProcedureWithCategoryClinicAreaNamesRow.field.category,
            categoryId,
          )
          .order(
            ProcedureWithCategoryClinicAreaNamesRow.field.createdAt,
            ascending: false,
          );

      final procedures =
          response.map<ProcedureWithCategoryClinicAreaNamesRow>((data) {
        return ProcedureWithCategoryClinicAreaNamesRow.fromJson(data);
      }).toList();

      return procedures;
    } catch (error) {
      debugPrint('Error fetching procedures by clinic and category: $error');
      return [];
    }
  }

  /// Updates an existing procedure in the database.
  Future<ProcedureRow?> updateProcedure({
    required String id,
    String? titleEng,
    String? titleKor,
    double? commission,
    double? totalPrice,
    String? category,
    String? description,
    String? explanation,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Only include fields that are provided
      if (titleEng != null) data[ProcedureRow.field.titleEng] = titleEng;
      if (titleKor != null) data[ProcedureRow.field.titleKor] = titleKor;
      if (commission != null) data[ProcedureRow.field.commission] = commission;
      if (totalPrice != null) data[ProcedureRow.field.totalPrice] = totalPrice;
      if (category != null) data[ProcedureRow.field.category] = category;
      if (description != null)
        data[ProcedureRow.field.description] = description;
      if (explanation != null)
        data[ProcedureRow.field.explanation] = explanation;

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingProcedure = await getFromId(id);
        return existingProcedure;
      }

      final response = await _supabase
          .from(ProcedureRow.table)
          .update(data)
          .eq(ProcedureRow.field.id, id)
          .select()
          .single();

      final procedure = ProcedureRow.fromJson(response);
      _cache[id] = procedure;

      // Clear category cache since the category might have changed
      if (category != null) {
        _categoryCache.clear();
      }

      return procedure;
    } catch (error) {
      debugPrint('Error updating procedure: $error');
      return null;
    }
  }

  /// Deletes a procedure from the database.
  Future<bool> deleteProcedure(String id) async {
    try {
      await _supabase
          .from(ProcedureRow.table)
          .delete()
          .eq(ProcedureRow.field.id, id);

      // Update caches
      final procedure = _cache[id];
      _cache.remove(id);

      if (procedure != null && procedure.category != null) {
        _categoryCache[procedure.category!]?.removeWhere((p) => p.id == id);
      }

      return true;
    } catch (error) {
      debugPrint('Error deleting procedure: $error');
      return false;
    }
  }

  /// Searches procedures by title and description.
  Future<List<ProcedureRow>> searchProcedures(String query) async {
    try {
      final response = await _supabase
          .from(ProcedureRow.table)
          .select()
          .or(
            'title_eng.ilike.%$query%,title_kor.ilike.%$query%,description.ilike.%$query%',
          )
          .order(ProcedureRow.field.createdAt, ascending: false);

      final procedures = response.map<ProcedureRow>((data) {
        final procedure = ProcedureRow.fromJson(data);
        _cache[procedure.id] = procedure;
        return procedure;
      }).toList();

      return procedures;
    } catch (error) {
      debugPrint('Error searching procedures: $error');
      return [];
    }
  }

  /// Creates a new procedure category in the database.
  Future<ProcedureCategoryRow?> createProcedureCategory({
    required String name,
    required String createdBy,
    required String clinic,
  }) async {
    try {
      final now = DateTime.now();
      final data = {
        ProcedureCategoryRow.field.name: name,
        ProcedureCategoryRow.field.createdBy: createdBy,
        ProcedureCategoryRow.field.clinic: clinic,
        ProcedureCategoryRow.field.createdAt: now.toIso8601String(),
      };

      final response = await _supabase
          .from(ProcedureCategoryRow.table)
          .insert(data)
          .select()
          .single();

      final category = ProcedureCategoryRow.fromJson(response);
      _categoriesCache[category.id] = category;

      // Update clinic categories cache
      if (_clinicCategoriesCache.containsKey(clinic)) {
        _clinicCategoriesCache[clinic]!.add(category);
      }

      return category;
    } catch (error) {
      debugPrint('Error creating procedure category: $error');
      return null;
    }
  }

  /// Gets a procedure category by its ID.
  Future<ProcedureCategoryRow?> getCategoryFromId(
    String id, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _categoriesCache.containsKey(id)) {
      return _categoriesCache[id];
    }

    try {
      final response = await _supabase
          .from(ProcedureCategoryRow.table)
          .select()
          .eq(ProcedureCategoryRow.field.id, id)
          .single();

      final category = ProcedureCategoryRow.fromJson(response);
      _categoriesCache[id] = category;
      return category;
    } catch (error) {
      debugPrint('Error fetching procedure category by ID: $error');
      return null;
    }
  }

  /// Gets all procedure categories for a clinic.
  Future<List<ProcedureCategoryRow>> getCategoriesByClinic(
    String clinicId, {
    bool cached = true,
  }) async {
    // Return from cache if available and allowed
    if (cached && _clinicCategoriesCache.containsKey(clinicId)) {
      return _clinicCategoriesCache[clinicId]!;
    }

    try {
      final response = await _supabase
          .from(ProcedureCategoryRow.table)
          .select()
          .eq(ProcedureCategoryRow.field.clinic, clinicId)
          .order(ProcedureCategoryRow.field.name);

      final categories = response.map<ProcedureCategoryRow>((data) {
        final category = ProcedureCategoryRow.fromJson(data);
        _categoriesCache[category.id] = category;
        return category;
      }).toList();

      _clinicCategoriesCache[clinicId] = categories;
      return categories;
    } catch (error) {
      debugPrint('Error fetching procedure categories by clinic: $error');
      return [];
    }
  }

  /// Updates a procedure category.
  Future<ProcedureCategoryRow?> updateProcedureCategory({
    required String id,
    String? name,
    String? clinic,
  }) async {
    try {
      final data = <String, dynamic>{};

      // Only include fields that are provided
      if (name != null) data[ProcedureCategoryRow.field.name] = name;
      if (clinic != null) data[ProcedureCategoryRow.field.clinic] = clinic;

      // Skip update if no fields were provided
      if (data.isEmpty) {
        final existingCategory = await getCategoryFromId(id);
        return existingCategory;
      }

      final response = await _supabase
          .from(ProcedureCategoryRow.table)
          .update(data)
          .eq(ProcedureCategoryRow.field.id, id)
          .select()
          .single();

      final category = ProcedureCategoryRow.fromJson(response);
      _categoriesCache[id] = category;

      // Clear clinic categories cache since the clinic might have changed
      if (clinic != null) {
        _clinicCategoriesCache.clear();
      }

      return category;
    } catch (error) {
      debugPrint('Error updating procedure category: $error');
      return null;
    }
  }

  /// Deletes a procedure category from the database.
  Future<bool> deleteProcedureCategory(String id) async {
    try {
      await _supabase
          .from(ProcedureCategoryRow.table)
          .delete()
          .eq(ProcedureCategoryRow.field.id, id);

      // Update caches
      final category = _categoriesCache[id];
      _categoriesCache.remove(id);

      if (category != null && category.clinic != null) {
        _clinicCategoriesCache[category.clinic!]?.removeWhere(
          (c) => c.id == id,
        );
      }

      return true;
    } catch (error) {
      debugPrint('Error deleting procedure category: $error');
      return false;
    }
  }

  /// Returns a cached procedure if available
  ProcedureRow? getFromCache(String id) {
    return _cache[id];
  }

  /// Returns a cached procedure category if available
  ProcedureCategoryRow? getCategoryFromCache(String id) {
    return _categoriesCache[id];
  }

  // // Add this to your cache declarations at the top of the class

  /// Gets clinic area procedure category dropdown entries with caching support.
  Future<List<ClinicAreaProcedureCategoryDropdownEntriesRow>>
      getClinicAreaProcedureCategoryDropdownEntries(
          {bool cached = true}) async {
    // Return from cache if available and allowed
    const cacheKey = 'all_dropdown_entries';
    if (cached && _dropdownEntriesCache.containsKey(cacheKey)) {
      return _dropdownEntriesCache[cacheKey]!;
    }

    try {
      final response = await _supabase
          .from(ClinicAreaProcedureCategoryDropdownEntriesRow.table)
          .select();

      final entries =
          response.map<ClinicAreaProcedureCategoryDropdownEntriesRow>((data) {
        return ClinicAreaProcedureCategoryDropdownEntriesRow.fromJson(data);
      }).toList();

      // Cache the results
      _dropdownEntriesCache[cacheKey] = entries;
      return entries;
    } catch (error) {
      debugPrint(
        'Error fetching clinic area procedure category dropdown entries: $error',
      );
      return [];
    }
  }

  /// Gets unique clinic areas for dropdown menus.
  Future<List<ClinicAreaProcedureCategoryDropdownEntriesRow>>
      getUniqueClinicAreas({bool cached = true}) async {
    const cacheKey = 'unique_clinic_areas';
    if (cached && _dropdownEntriesCache.containsKey(cacheKey)) {
      return _dropdownEntriesCache[cacheKey]!;
    }

    try {
      // Get all entries first
      final allEntries = await getClinicAreaProcedureCategoryDropdownEntries(
        cached: cached,
      );

      // Use a map to deduplicate by clinicAreaId
      final uniqueAreas =
          <String, ClinicAreaProcedureCategoryDropdownEntriesRow>{};
      for (final entry in allEntries) {
        if (entry.clinicAreaId != null &&
            !uniqueAreas.containsKey(entry.clinicAreaId)) {
          uniqueAreas[entry.clinicAreaId!] = entry;
        }
      }

      final result = uniqueAreas.values.toList();
      _dropdownEntriesCache[cacheKey] = result;
      return result;
    } catch (error) {
      debugPrint('Error fetching unique clinic areas: $error');
      return [];
    }
  }

  /// Gets procedure categories by clinic area ID.
  Future<List<ClinicAreaProcedureCategoryDropdownEntriesRow>>
      getProcedureCategoriesByArea(String areaId, {bool cached = true}) async {
    final cacheKey = 'area_categories_$areaId';
    if (cached && _dropdownEntriesCache.containsKey(cacheKey)) {
      return _dropdownEntriesCache[cacheKey]!;
    }

    try {
      final response = await _supabase
          .from(ClinicAreaProcedureCategoryDropdownEntriesRow.table)
          .select()
          .eq(
            ClinicAreaProcedureCategoryDropdownEntriesRow.field.clinicAreaId,
            areaId,
          );

      final categories =
          response.map<ClinicAreaProcedureCategoryDropdownEntriesRow>((data) {
        return ClinicAreaProcedureCategoryDropdownEntriesRow.fromJson(data);
      }).toList();

      _dropdownEntriesCache[cacheKey] = categories;
      return categories;
    } catch (error) {
      debugPrint('Error fetching procedure categories by area: $error');
      return [];
    }
  }

  // create a function that get all procedure_with_category_clinic_area_names that accepts params. categoryid, clinic id, and area id this can be null
  // Cache for procedure_with_category_clinic_area_names view results

  Future<List<ProcedureWithCategoryClinicAreaNamesRow>> getProcedures({
    int? limit,
    int? offset,
    List<String>? clinicIds,
    List<String>? categoryIds,
    List<String>? areaIds,
    bool cached = true,
  }) async {
    // Generate a unique cache key based on parameters
    final cacheKey =
        'procedures_view_limit_${limit}_offset_${offset}_clinics_${clinicIds?.join(',')}_categories_${categoryIds?.join(',')}_areas_${areaIds?.join(',')}';

    // Return from cache if available and allowed
    if (cached && _proceduresViewCache.containsKey(cacheKey)) {
      return _proceduresViewCache[cacheKey]!;
    }

    try {
      PostgrestFilterBuilder<PostgrestList> procedureQuery = _supabase
          .from(ProcedureWithCategoryClinicAreaNamesRow.table)
          .select();

      if (clinicIds != null && clinicIds.isNotEmpty) {
        procedureQuery = procedureQuery.inFilter(
          ProcedureWithCategoryClinicAreaNamesRow.field.clinicId,
          clinicIds,
        );
      }

      if (categoryIds != null && categoryIds.isNotEmpty) {
        procedureQuery = procedureQuery.inFilter(
          ProcedureWithCategoryClinicAreaNamesRow.field.category,
          categoryIds,
        );
      }

      if (areaIds != null && areaIds.isNotEmpty) {
        procedureQuery = procedureQuery.inFilter(
          ProcedureWithCategoryClinicAreaNamesRow.field.clinicAreaId,
          areaIds,
        );
      }

      PostgrestTransformBuilder<PostgrestList> limitQuery = procedureQuery;

      // Apply Limit and Offset
      if (limit != null) {
        limitQuery = limitQuery.limit(limit);
        if (offset != null) {
          limitQuery = limitQuery.range(offset, offset + limit - 1);
        }
      }

      final queryResult = await limitQuery
          .order(
            ProcedureWithCategoryClinicAreaNamesRow.field.clinicName,
            ascending: true,
          )
          .order(
            ProcedureWithCategoryClinicAreaNamesRow.field.titleEng,
            ascending: true,
          )
          .order(
            ProcedureWithCategoryClinicAreaNamesRow.field.createdAt,
            ascending: false,
          );

      final List<ProcedureWithCategoryClinicAreaNamesRow> result = queryResult
          .map((e) => ProcedureWithCategoryClinicAreaNamesRow.fromJson(e))
          .toList();

      // Cache the result
      _proceduresViewCache[cacheKey] = result;

      return result;
    } catch (error) {
      debugPrint('Error fetching procedures from view: $error');
      return [];
    }
  }

  // create a function that get the procedure by id and cache
  Future<ProcedureWithCategoryClinicAreaNamesRow?> getProcedureById(
    String id, {
    bool cached = true,
  }) async {
    final cacheKey = 'procedure_$id';
    if (cached && _proceduresViewCache.containsKey(cacheKey)) {
      return _proceduresViewCache[cacheKey]!.first;
    }

    try {
      final response = await _supabase
          .from(ProcedureWithCategoryClinicAreaNamesRow.table)
          .select()
          .eq(ProcedureWithCategoryClinicAreaNamesRow.field.id, id)
          .single();

      final procedure =
          ProcedureWithCategoryClinicAreaNamesRow.fromJson(response);
      _proceduresViewCache[cacheKey] = [procedure];
      return procedure;
    } catch (error) {
      debugPrint('Error fetching procedure by ID: $error');
      return null;
    }
  }

  /// Clears all caches
  void clearCache() {
    _cache.clear();
    _categoryCache.clear();
    _clinicCache.clear();
    _categoriesCache.clear();
    _clinicCategoriesCache.clear();
    _dropdownEntriesCache.clear();
    _proceduresViewCache.clear();
  }
}

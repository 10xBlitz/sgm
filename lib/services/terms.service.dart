import 'package:sgm/row_row_row_generated/tables/terms_and_condition.row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TermsService {
  static final TermsService _instance = TermsService._internal();
  factory TermsService() => _instance;
  TermsService._internal();

  final _supabase = Supabase.instance.client;

  // Cache user-specific terms by userId
  final Map<String, TermsAndConditionRow> _userTermsCache = {};

  // Cache the latest terms (single instance)
  TermsAndConditionRow? _latestTermsCache;

  Future<TermsAndConditionRow> getTermsAndConditions(String userId) async {
    if (_userTermsCache.containsKey(userId)) {
      return _userTermsCache[userId]!;
    }

    final response =
        await _supabase
            .from(TermsAndConditionRow.table)
            .select()
            .eq('user_id', userId)
            .single();

    final termsAndConditions = TermsAndConditionRow.fromJson(response);
    _userTermsCache[userId] = termsAndConditions;
    return termsAndConditions;
  }

  Future<TermsAndConditionRow> getLatestTermsAndConditions() async {
    if (_latestTermsCache != null) {
      return _latestTermsCache!;
    }

    final response =
        await _supabase
            .from(TermsAndConditionRow.table)
            .select()
            .order('created_at', ascending: false)
            .limit(1)
            .single();

    final termsAndConditions = TermsAndConditionRow.fromJson(response);
    _latestTermsCache = termsAndConditions;
    return termsAndConditions;
  }

  Future<void> updateTermsAndConditions(
    String id,
    String updatedContent,
  ) async {
    final response =
        await _supabase
            .from(TermsAndConditionRow.table)
            .insert({'terms': updatedContent})
            .select()
            .single();
    // Optional: check response for error

    // Invalidate cache for updated row
    _userTermsCache.removeWhere((key, row) => row.id == id);
    _latestTermsCache = null;
  }

  // Optional: Method to clear cache if you want to force refresh
  void clearCache() {
    _userTermsCache.clear();
    _latestTermsCache = null;
  }
}

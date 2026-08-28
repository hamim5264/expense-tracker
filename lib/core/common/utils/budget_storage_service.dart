import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetStorageService {
  static const String _storageKeyPrefix = 'user_budget_plans_';

  static Future<List<BudgetPlan>> loadLocalCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_storageKeyPrefix$userId');
      if (jsonStr != null) {
        final List rawList = jsonDecode(jsonStr);
        return rawList.map((map) => BudgetPlan.fromJson(map)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<BudgetPlan>> loadBudgets(String userId, {bool forceRemote = false}) async {
    List<BudgetPlan> list = [];

    // Try Supabase remote fetch
    try {
      final client = Supabase.instance.client;
      final List<dynamic> response = await client
          .from('budget_plans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        list = response.map((map) => BudgetPlan.fromJson(map as Map<String, dynamic>)).toList();
        await _saveLocally(userId, list);
        return list;
      }
    } catch (_) {
      // Fallback to local cache if offline or remote error
    }

    return await loadLocalCache(userId);
  }

  static Future<void> saveBudget(BudgetPlan plan) async {
    final client = Supabase.instance.client;
    try {
      await client.from('budget_plans').upsert({
        'id': plan.id.isEmpty ? null : plan.id,
        'user_id': plan.userId,
        'name': plan.name,
        'target_amount': plan.targetAmount,
        'period': plan.period,
        'category': plan.category,
        'start_date': plan.startDate.toIso8601String(),
        'wallet_id': plan.walletId,
      });
    } catch (_) {}

    // Save locally
    final current = await loadBudgets(plan.userId);
    final idx = current.indexWhere((b) => b.id == plan.id);
    if (idx != -1) {
      current[idx] = plan;
    } else {
      current.insert(0, plan);
    }
    await _saveLocally(plan.userId, current);
  }

  static Future<void> deleteBudget(String userId, String budgetId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('budget_plans').delete().eq('id', budgetId);
    } catch (_) {}

    final current = await loadBudgets(userId);
    current.removeWhere((b) => b.id == budgetId);
    await _saveLocally(userId, current);
  }

  static Future<void> _saveLocally(String userId, List<BudgetPlan> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(list.map((b) => b.toJson()).toList());
      await prefs.setString('$_storageKeyPrefix$userId', jsonStr);
    } catch (_) {}
  }
}

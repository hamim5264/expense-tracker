import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/features/loan/domain/entities/loan.dart';
import 'package:expense_tracker/features/loan/domain/entities/loan_repayment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoanStorageService {
  static const String _storageKeyPrefix = 'user_loans_v2_';

  /// Loads loans from local offline cache
  static Future<List<Loan>> loadLocalCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('$_storageKeyPrefix$userId');
      if (jsonStr != null) {
        final List rawList = jsonDecode(jsonStr);
        return rawList.map((map) => Loan.fromJson(Map<String, dynamic>.from(map as Map))).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Loads loans with Supabase synchronization and local fallback
  static Future<List<Loan>> loadLoans(String userId, {bool forceRemote = false}) async {
    List<Loan> list = [];

    try {
      final client = Supabase.instance.client;
      final List<dynamic> loanRows = await client
          .from('loans')
          .select('*, loan_repayments(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (loanRows.isNotEmpty) {
        list = loanRows.map((map) {
          final m = Map<String, dynamic>.from(map as Map);
          if (m['loan_repayments'] is List) {
            m['repayments'] = m['loan_repayments'];
          }
          return Loan.fromJson(m);
        }).toList();

        await _saveLocally(userId, list);
        return list;
      }
    } catch (_) {
      // Fallback to local cache if offline or table not yet run
    }

    return await loadLocalCache(userId);
  }

  /// Saves or updates a loan
  static Future<void> saveLoan(Loan loan) async {
    // 1. Try Supabase
    try {
      final client = Supabase.instance.client;
      await client.from('loans').upsert({
        'id': loan.id.isEmpty ? null : loan.id,
        'user_id': loan.userId,
        'title': loan.title,
        'counterparty': loan.counterparty,
        'type': loan.type,
        'principal': loan.principal,
        'interest_rate': loan.interestRate,
        'interest_type': loan.interestType,
        'tenure_months': loan.tenureMonths,
        'start_date': loan.startDate.toIso8601String(),
        'due_date': loan.dueDate?.toIso8601String(),
        'wallet_id': loan.walletId,
        'status': loan.status,
        'notes': loan.notes,
        'details': loan.details,
      });
    } catch (_) {}

    // 2. Save locally
    final current = await loadLocalCache(loan.userId);
    final idx = current.indexWhere((l) => l.id == loan.id);
    if (idx != -1) {
      current[idx] = loan;
    } else {
      current.insert(0, loan);
    }
    await _saveLocally(loan.userId, current);
  }

  /// Adds a repayment log to a loan
  static Future<void> addRepayment(LoanRepayment repayment) async {
    // 1. Try Supabase
    try {
      final client = Supabase.instance.client;
      await client.from('loan_repayments').insert({
        'id': repayment.id.isEmpty ? null : repayment.id,
        'loan_id': repayment.loanId,
        'user_id': repayment.userId,
        'amount': repayment.amount,
        'payment_date': repayment.paymentDate.toIso8601String(),
        'wallet_id': repayment.walletId,
        'notes': repayment.notes,
      });
    } catch (_) {}

    // 2. Update local state
    final current = await loadLocalCache(repayment.userId);
    final loanIdx = current.indexWhere((l) => l.id == repayment.loanId);
    if (loanIdx != -1) {
      final loan = current[loanIdx];
      final updatedRepayments = List<LoanRepayment>.from(loan.repayments)..add(repayment);
      final updatedLoan = loan.copyWith(
        repayments: updatedRepayments,
        status: (loan.remainingBalance - repayment.amount) <= 0.01 ? 'settled' : loan.status,
      );
      current[loanIdx] = updatedLoan;
      await _saveLocally(repayment.userId, current);
    }
  }

  /// Deletes a repayment log
  static Future<void> deleteRepayment(String userId, String loanId, String repaymentId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('loan_repayments').delete().eq('id', repaymentId);
    } catch (_) {}

    final current = await loadLocalCache(userId);
    final loanIdx = current.indexWhere((l) => l.id == loanId);
    if (loanIdx != -1) {
      final loan = current[loanIdx];
      final updatedRepayments = loan.repayments.where((r) => r.id != repaymentId).toList();
      current[loanIdx] = loan.copyWith(repayments: updatedRepayments);
      await _saveLocally(userId, current);
    }
  }

  /// Deletes an entire loan and its repayments
  static Future<void> deleteLoan(String userId, String loanId) async {
    try {
      final client = Supabase.instance.client;
      await client.from('loans').delete().eq('id', loanId);
    } catch (_) {}

    final current = await loadLocalCache(userId);
    current.removeWhere((l) => l.id == loanId);
    await _saveLocally(userId, current);
  }

  static Future<void> _saveLocally(String userId, List<Loan> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(list.map((l) => l.toJson()).toList());
      await prefs.setString('$_storageKeyPrefix$userId', jsonStr);
    } catch (_) {}
  }
}

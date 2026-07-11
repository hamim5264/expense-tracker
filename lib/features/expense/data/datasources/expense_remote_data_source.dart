import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/data/models/wallet_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getAllExpenses();

  Future<void> addExpense(ExpenseModel expense);

  Future<List<WalletModel>> getWallets();

  Future<WalletModel> addWallet(WalletModel wallet);

  Future<void> deleteWallet(String walletId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient supabaseClient;

  ExpenseRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    try {
      final response = await supabaseClient
          .from('expenses')
          .select()
          .order('date', ascending: false);

      return response.map((e) => ExpenseModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final json = expense.toJson();
      if (expense.id.isEmpty || !expense.id.contains('-')) {
        json.remove('id');
      }
      await supabaseClient.from('expenses').insert(json);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<List<WalletModel>> getWallets() async {
    try {
      final response = await supabaseClient
          .from('wallets')
          .select()
          .order('created_at', ascending: false);

      return response.map((e) => WalletModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<WalletModel> addWallet(WalletModel wallet) async {
    try {
      final json = wallet.toJson();
      if (wallet.id.isEmpty || !wallet.id.contains('-')) {
        json.remove('id');
      }
      final response = await supabaseClient
          .from('wallets')
          .insert(json)
          .select()
          .single();

      return WalletModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }

  @override
  Future<void> deleteWallet(String walletId) async {
    try {
      await supabaseClient.from('wallets').delete().eq('id', walletId);
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }
}

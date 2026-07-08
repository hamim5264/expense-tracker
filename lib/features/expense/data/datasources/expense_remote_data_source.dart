import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getAllExpenses();

  Future<void> addExpense(ExpenseModel expense);
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
      await supabaseClient.from('expenses').insert(expense.toJson());
    } on PostgrestException catch (e) {
      throw Failure(e.message);
    } catch (e) {
      throw Failure(e.toString());
    }
  }
}

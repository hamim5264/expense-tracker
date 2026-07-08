import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_all_expenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetAllExpenses _getAllExpenses;

  ExpenseBloc({required this._getAllExpenses}) : super(ExpenseInitial()) {
    on<ExpenseEvent>((event, emit) => emit(ExpenseLoading()));
    on<ExpenseFetchAll>(_onFetchAllExpenses);
  }

  void _onFetchAllExpenses(
    ExpenseFetchAll event,
    Emitter<ExpenseState> emit,
  ) async {
    final res = await _getAllExpenses(NoParams());

    res.fold(
      (l) => emit(ExpenseFailure(l.message)),
      (r) => emit(ExpenseSuccess(r)),
    );
  }
}

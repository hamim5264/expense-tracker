// ignore_for_file: prefer_initializing_formals
library;

import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_all_expenses.dart';
import 'package:expense_tracker/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_wallets.dart';
import 'package:expense_tracker/features/expense/domain/usecases/add_wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/delete_wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetAllExpenses _getAllExpenses;
  final AddExpense _addExpense;
  final GetWallets _getWallets;
  final AddWallet _addWallet;
  final DeleteWallet _deleteWallet;

  ExpenseBloc({
    required GetAllExpenses getAllExpenses,
    required AddExpense addExpense,
    required GetWallets getWallets,
    required AddWallet addWallet,
    required DeleteWallet deleteWallet,
  }) : _getAllExpenses = getAllExpenses,
       _addExpense = addExpense,
       _getWallets = getWallets,
       _addWallet = addWallet,
       _deleteWallet = deleteWallet,
       super(ExpenseInitial()) {
    on<ExpenseFetchAll>(_onFetchAllExpenses);
    on<ExpenseAddTransaction>(_onAddTransaction);
    on<ExpenseAddWalletCard>(_onAddWalletCard);
    on<ExpenseDeleteWallet>(_onDeleteWallet);
  }

  void _onFetchAllExpenses(
    ExpenseFetchAll event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final expRes = await _getAllExpenses(NoParams());
    final wallRes = await _getWallets(NoParams());

    expRes.fold((l) => emit(ExpenseFailure(l.message)), (rExpenses) {
      wallRes.fold(
        // Surface wallet errors so they are visible instead of silently dropped
        (l) {
          debugPrint('[ExpenseBloc] getWallets failed: ${l.message}');
          emit(ExpenseSuccess(rExpenses, wallets: const []));
        },
        (rWallets) => emit(ExpenseSuccess(rExpenses, wallets: rWallets)),
      );
    });
  }

  void _onAddTransaction(
    ExpenseAddTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _addExpense(event.expense);

    res.fold(
      (l) => emit(ExpenseFailure(l.message)),
      (_) => add(ExpenseFetchAll()),
    );
  }

  void _onAddWalletCard(
    ExpenseAddWalletCard event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _addWallet(event.wallet);

    res.fold(
      (l) => emit(ExpenseFailure(l.message)),
      (_) => add(ExpenseFetchAll()),
    );
  }

  void _onDeleteWallet(
    ExpenseDeleteWallet event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _deleteWallet(event.walletId);

    res.fold(
      (l) => emit(ExpenseFailure(l.message)),
      (_) => add(ExpenseFetchAll()),
    );
  }
}

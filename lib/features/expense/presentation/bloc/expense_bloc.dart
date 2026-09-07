import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:expense_tracker/core/usecase/usecase.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_all_expenses.dart';
import 'package:expense_tracker/features/expense/domain/usecases/add_expense.dart';
import 'package:expense_tracker/features/expense/domain/usecases/get_wallets.dart';
import 'package:expense_tracker/features/expense/domain/usecases/add_wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/update_wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/delete_wallet.dart';
import 'package:expense_tracker/features/expense/domain/usecases/update_expense.dart';
import 'package:expense_tracker/features/expense/domain/usecases/delete_expense.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/common/utils/notification_service.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetAllExpenses _getAllExpenses;
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;
  final GetWallets _getWallets;
  final AddWallet _addWallet;
  final UpdateWallet _updateWallet;
  final DeleteWallet _deleteWallet;
  final ExpenseRepository _expenseRepository;

  ExpenseBloc({
    required GetAllExpenses getAllExpenses,
    required AddExpense addExpense,
    required UpdateExpense updateExpense,
    required DeleteExpense deleteExpense,
    required GetWallets getWallets,
    required AddWallet addWallet,
    required UpdateWallet updateWallet,
    required DeleteWallet deleteWallet,
    required ExpenseRepository expenseRepository,
  }) : _getAllExpenses = getAllExpenses,
       _addExpense = addExpense,
       _updateExpense = updateExpense,
       _deleteExpense = deleteExpense,
       _getWallets = getWallets,
       _addWallet = addWallet,
       _updateWallet = updateWallet,
       _deleteWallet = deleteWallet,
       _expenseRepository = expenseRepository,
       super(ExpenseInitial()) {
    on<ExpenseFetchAll>(_onFetchAll);
    on<ExpenseAddTransaction>(_onAddTransaction);
    on<ExpenseUpdateTransaction>(_onUpdateTransaction);
    on<ExpenseDeleteTransaction>(_onDeleteTransaction);
    on<ExpenseAddWalletCard>(_onAddWalletCard);
    on<ExpenseUpdateWallet>(_onUpdateWallet);
    on<ExpenseDeleteWallet>(_onDeleteWallet);
    on<ExpenseClearTransactions>(_onClearTransactions);
  }

  void _onFetchAll(ExpenseFetchAll event, Emitter<ExpenseState> emit) async {
    if (state is! ExpenseSuccess) {
      emit(ExpenseLoading());
    }

    final expRes = await _getAllExpenses(NoParams());
    final wallRes = await _getWallets(NoParams());

    expRes.fold((l) => emit(ExpenseFailure(l.message)), (rExpenses) {
      wallRes.fold((l) {
        debugPrint('[ExpenseBloc] getWallets failed: ${l.message}');
        emit(ExpenseSuccess(rExpenses, wallets: const []));
      }, (rWallets) => emit(ExpenseSuccess(rExpenses, wallets: rWallets)));
    });
  }

  void _onAddTransaction(
    ExpenseAddTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _addExpense(event.expense);

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: event.expense.type == 'income'
            ? 'Income Received'
            : 'Expense Recorded',
        message:
            '${event.expense.title}: ${event.expense.amount.toStringAsFixed(2)} added successfully.',
        type: event.expense.type == 'income' ? 'success' : 'info',
      );
      add(ExpenseFetchAll());
    });
  }

  void _onUpdateTransaction(
    ExpenseUpdateTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _updateExpense(event.expense);

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: 'Transaction Updated',
        message: '${event.expense.title} updated successfully.',
        type: 'success',
      );
      add(ExpenseFetchAll());
    });
  }

  void _onDeleteTransaction(
    ExpenseDeleteTransaction event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _deleteExpense(event.transactionId);

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: 'Transaction Deleted',
        message: 'Transaction deleted successfully.',
        type: 'warning',
      );
      add(ExpenseFetchAll());
    });
  }

  void _onAddWalletCard(
    ExpenseAddWalletCard event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());

    // If recording as an initial income transaction, set the baseline initial balance to 0.0
    // so the incoming income transaction provides the initial balance without double-counting.
    Wallet walletToSave = event.wallet;
    if (event.recordAsIncome && event.wallet.balance > 0) {
      final detailsCopy = Map<String, dynamic>.from(event.wallet.details);
      detailsCopy['initial_balance'] = 0.0;
      walletToSave = Wallet(
        id: event.wallet.id,
        userId: event.wallet.userId,
        name: event.wallet.name,
        type: event.wallet.type,
        balance: 0.0,
        details: detailsCopy,
        createdAt: event.wallet.createdAt,
      );
    }

    final res = await _addWallet(walletToSave);

    await res.fold(
      (l) async => emit(ExpenseFailure(l.message)),
      (createdWallet) async {
        if (event.recordAsIncome && event.wallet.balance > 0) {
          final incomeExpense = Expense(
            id: '',
            userId: createdWallet.userId,
            title: 'Opening Balance - ${createdWallet.name}',
            amount: event.wallet.balance,
            date: DateTime.now(),
            type: 'income',
            category: 'Others',
            walletId: createdWallet.id,
            notes: 'Initial balance for ${createdWallet.name}',
          );
          await _addExpense(incomeExpense);
        }

        NotificationService().addNotification(
          title: 'Wallet Added',
          message: 'Wallet "${event.wallet.name}" created successfully.',
          type: 'success',
        );
        add(ExpenseFetchAll());
      },
    );
  }

  void _onUpdateWallet(
    ExpenseUpdateWallet event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _updateWallet(event.wallet);

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: 'Wallet Updated',
        message: 'Wallet "${event.wallet.name}" updated successfully.',
        type: 'success',
      );
      add(ExpenseFetchAll());
    });
  }

  void _onDeleteWallet(
    ExpenseDeleteWallet event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _deleteWallet(event.walletId);

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: 'Wallet Deleted',
        message: 'Wallet deleted successfully.',
        type: 'warning',
      );
      add(ExpenseFetchAll());
    });
  }

  void _onClearTransactions(
    ExpenseClearTransactions event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    final res = await _expenseRepository.clearTransactions(
      userId: event.userId,
      type: event.type,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    res.fold((l) => emit(ExpenseFailure(l.message)), (_) {
      NotificationService().addNotification(
        title: 'History Cleared',
        message: 'Transaction history cleared successfully.',
        type: 'warning',
      );
      add(ExpenseFetchAll());
    });
  }
}

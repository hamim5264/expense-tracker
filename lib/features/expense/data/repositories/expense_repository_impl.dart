import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/core/common/utils/hive_cache_service.dart';
import 'package:expense_tracker/features/expense/data/datasources/expense_remote_data_source.dart';
import 'package:expense_tracker/features/expense/data/models/expense_model.dart';
import 'package:expense_tracker/features/expense/data/models/wallet_model.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/repositories/expense_repository.dart';
import 'package:fpdart/fpdart.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final HiveCacheService cacheService;

  ExpenseRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.cacheService,
  });

  @override
  Future<Either<Failure, List<Expense>>> getAllExpenses() async {
    try {
      final localData = await cacheService.getCachedExpenses();
      final List<Expense> cachedExpenses = localData
          .map((e) => ExpenseModel.fromJson(e))
          .toList();

      if (await networkInfo.isConnected) {
        final expenses = await remoteDataSource.getAllExpenses();
        final jsonList = expenses.map((e) => e.toJson()).toList();
        await cacheService.cacheExpenses(jsonList);
        return right(expenses);
      }

      return right(cachedExpenses);
    } on Failure {
      final localData = await cacheService.getCachedExpenses();
      return right(localData.map((e) => ExpenseModel.fromJson(e)).toList());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id.isEmpty
            ? DateTime.now().millisecondsSinceEpoch.toString()
            : expense.id,
        userId: expense.userId,
        title: expense.title,
        amount: expense.amount,
        date: expense.date,
        type: expense.type,
        category: expense.category,
        walletId: expense.walletId,
      );

      final currentCache = await cacheService.getCachedExpenses();
      currentCache.insert(0, expenseModel.toJson());
      await cacheService.cacheExpenses(currentCache);

      if (await networkInfo.isConnected) {
        await remoteDataSource.addExpense(expenseModel);
      } else {
        await cacheService.addUnsyncedExpense(expenseModel.toJson());
      }
      return right(null);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Wallet>>> getWallets() async {
    try {
      if (await networkInfo.isConnected) {
        final wallets = await remoteDataSource.getWallets();
        final jsonList = wallets.map((w) => w.toJson()).toList();
        await cacheService.cacheWallets(jsonList);
        return right(wallets);
      } else {
        final localData = await cacheService.getCachedWallets();
        final cached = localData.map((w) => WalletModel.fromJson(w)).toList();
        return right(cached);
      }
    } on Failure catch (e) {
      try {
        final localData = await cacheService.getCachedWallets();
        if (localData.isNotEmpty) {
          return right(localData.map((w) => WalletModel.fromJson(w)).toList());
        }
      } catch (_) {}
      return left(e);
    } catch (e) {
      try {
        final localData = await cacheService.getCachedWallets();
        if (localData.isNotEmpty) {
          return right(localData.map((w) => WalletModel.fromJson(w)).toList());
        }
      } catch (_) {}
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> addWallet(Wallet wallet) async {
    try {
      final walletModel = WalletModel(
        id: '',
        userId: wallet.userId,
        name: wallet.name,
        type: wallet.type,
        balance: wallet.balance,
        details: wallet.details,
        createdAt: wallet.createdAt,
      );

      if (await networkInfo.isConnected) {
        final added = await remoteDataSource.addWallet(walletModel);
        try {
          final allWallets = await remoteDataSource.getWallets();
          final jsonList = allWallets.map((w) => w.toJson()).toList();
          await cacheService.cacheWallets(jsonList);
        } catch (_) {
          final currentCache = await cacheService.getCachedWallets();
          currentCache.insert(0, added.toJson());
          await cacheService.cacheWallets(currentCache);
        }
        return right(added);
      } else {
        final offlineModel = WalletModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: wallet.userId,
          name: wallet.name,
          type: wallet.type,
          balance: wallet.balance,
          details: wallet.details,
          createdAt: wallet.createdAt,
        );
        final currentCache = await cacheService.getCachedWallets();
        currentCache.insert(0, offlineModel.toJson());
        await cacheService.cacheWallets(currentCache);
        await cacheService.addUnsyncedWallet(offlineModel.toJson());
        return right(offlineModel);
      }
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWallet(String walletId) async {
    try {
      final localData = await cacheService.getCachedWallets();
      localData.removeWhere((w) => w['id'] == walletId);
      await cacheService.cacheWallets(localData);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteWallet(walletId);
      }
      return right(null);
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Future<void> syncUnsyncedData() async {
    if (await networkInfo.isConnected) {
      final unsyncedWallets = await cacheService.getUnsyncedWallets();
      for (var wJson in unsyncedWallets) {
        try {
          final wModel = WalletModel.fromJson(wJson);
          await remoteDataSource.addWallet(wModel);
        } catch (_) {}
      }
      await cacheService.clearUnsyncedWallets();

      final unsyncedExpenses = await cacheService.getUnsyncedExpenses();
      for (var eJson in unsyncedExpenses) {
        try {
          final eModel = ExpenseModel.fromJson(eJson);
          await remoteDataSource.addExpense(eModel);
        } catch (_) {}
      }
      await cacheService.clearUnsyncedExpenses();
    }
  }
}

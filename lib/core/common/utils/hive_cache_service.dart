import 'package:hive_flutter/hive_flutter.dart';

class HiveCacheService {
  static const String _expensesBoxName = 'expenses_box';
  static const String _walletsBoxName = 'wallets_box';
  static const String _unsyncedExpensesKey = 'unsynced_expenses';
  static const String _unsyncedWalletsKey = 'unsynced_wallets';
  static const String _cachedExpensesKey = 'cached_expenses';
  static const String _cachedWalletsKey = 'cached_wallets';

  Future<Box> get _expensesBox async => await Hive.openBox(_expensesBoxName);

  Future<Box> get _walletsBox async => await Hive.openBox(_walletsBoxName);

  Future<void> cacheExpenses(List<Map<String, dynamic>> expensesJson) async {
    final box = await _expensesBox;
    await box.put(_cachedExpensesKey, expensesJson);
  }

  Future<List<Map<String, dynamic>>> getCachedExpenses() async {
    final box = await _expensesBox;
    final List<dynamic>? list = box.get(_cachedExpensesKey);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> cacheWallets(List<Map<String, dynamic>> walletsJson) async {
    final box = await _walletsBox;
    await box.put(_cachedWalletsKey, walletsJson);
  }

  Future<List<Map<String, dynamic>>> getCachedWallets() async {
    final box = await _walletsBox;
    final List<dynamic>? list = box.get(_cachedWalletsKey);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> addUnsyncedExpense(Map<String, dynamic> expenseJson) async {
    final box = await _expensesBox;
    final List<dynamic> current = box.get(
      _unsyncedExpensesKey,
      defaultValue: [],
    );
    current.add(expenseJson);
    await box.put(_unsyncedExpensesKey, current);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    final box = await _expensesBox;
    final List<dynamic> list = box.get(_unsyncedExpensesKey, defaultValue: []);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clearUnsyncedExpenses() async {
    final box = await _expensesBox;
    await box.delete(_unsyncedExpensesKey);
  }

  Future<void> addUnsyncedWallet(Map<String, dynamic> walletJson) async {
    final box = await _walletsBox;
    final List<dynamic> current = box.get(
      _unsyncedWalletsKey,
      defaultValue: [],
    );
    current.add(walletJson);
    await box.put(_unsyncedWalletsKey, current);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedWallets() async {
    final box = await _walletsBox;
    final List<dynamic> list = box.get(_unsyncedWalletsKey, defaultValue: []);
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> clearUnsyncedWallets() async {
    final box = await _walletsBox;
    await box.delete(_unsyncedWalletsKey);
  }
}

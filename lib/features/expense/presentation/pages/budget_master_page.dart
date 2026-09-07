import 'package:expense_tracker/core/common/utils/budget_storage_service.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/add_edit_budget_sheet.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/budget_goal_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/budget_master_overview_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

class BudgetMasterPage extends StatefulWidget {
  final VoidCallback? onBackTap;

  const BudgetMasterPage({super.key, this.onBackTap});

  @override
  State<BudgetMasterPage> createState() => _BudgetMasterPageState();
}

class _BudgetMasterPageState extends State<BudgetMasterPage> {
  String _selectedPeriodFilter = 'monthly'; // 'monthly' or 'yearly'
  List<BudgetPlan> _budgetPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
    context.read<ExpenseBloc>().add(ExpenseFetchAll());
  }

  Future<void> _fetchBudgets({bool isRefresh = false}) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final userId = authState.user.id;

      // 1. Instant Cached Load
      if (!isRefresh) {
        final cached = await BudgetStorageService.loadLocalCache(userId);
        if (cached.isNotEmpty && mounted) {
          setState(() {
            _budgetPlans = cached;
            _isLoading = false;
          });
        }
      }

      // 2. Fetch latest remote data from Supabase
      final list =
          await BudgetStorageService.loadBudgets(userId, forceRemote: isRefresh);
      if (mounted) {
        setState(() {
          _budgetPlans = list;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditBudgetModal([BudgetPlan? existingPlan]) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;
    final userId = authState.user.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return AddEditBudgetSheet(
          existingPlan: existingPlan,
          initialPeriodFilter: _selectedPeriodFilter,
          currencyCode: CurrencyService.getSymbol(authState.user.currency),
          isDark: isDark,
          primaryColor: primaryColor,
          onSave: (title, targetAmount, period, category) async {
            if (title.isEmpty) {
              Fluttertoast.showToast(msg: 'Please enter a budget title');
              return;
            }
            if (targetAmount <= 0) {
              Fluttertoast.showToast(msg: 'Please enter a valid target amount');
              return;
            }

            final newPlan = BudgetPlan(
              id: existingPlan?.id ?? const Uuid().v4(),
              userId: userId,
              name: title,
              targetAmount: targetAmount,
              period: period,
              category: category,
              startDate: existingPlan?.startDate ?? DateTime.now(),
            );

            await BudgetStorageService.saveBudget(newPlan);
            if (ctx.mounted) {
              Navigator.pop(ctx);
            }
            _fetchBudgets();
            Fluttertoast.showToast(msg: 'Budget plan saved!');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;
    final bgColor = isDark ? const Color(0xFF12111A) : const Color(0xFFF9F9FB);

    return Scaffold(
      backgroundColor: bgColor,
      // No duplicate floating action button!
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.back,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 20,
                      ),
                      onPressed: () {
                        if (widget.onBackTap != null) {
                          widget.onBackTap!();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Master',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'Targets & Spending Caps',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? Colors.white38 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Single Primary Add Button in Top Bar
                  GestureDetector(
                    onTap: () => _showAddEditBudgetModal(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.plus,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Target',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is! AuthSuccess) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final user = authState.user;

                  return BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, expenseState) {
                      List<Expense> expenses = [];
                      if (expenseState is ExpenseSuccess) {
                        expenses = expenseState.expenses;
                      }

                      final filteredBudgets = _budgetPlans
                          .where((b) => b.period == _selectedPeriodFilter)
                          .toList();

                      final monthlyCount =
                          _budgetPlans.where((b) => b.period == 'monthly').length;
                      final yearlyCount =
                          _budgetPlans.where((b) => b.period == 'yearly').length;

                      final double totalTarget = filteredBudgets.fold(
                        0.0,
                        (s, b) => s + b.targetAmount,
                      );

                      // Calculate deduplicated total spent across active budgets in this period
                      final Set<String> matchedTxIds = {};
                      double totalSpent = 0.0;
                      for (final b in filteredBudgets) {
                        for (final tx in expenses) {
                          if (b.matchesTransaction(tx)) {
                            if (matchedTxIds.add(tx.id)) {
                              totalSpent += tx.amount;
                            }
                          }
                        }
                      }

                      // Collect matched logs across all active budgets in this period
                      final List<({Expense tx, BudgetPlan plan})> activeBudgetLogs = [];
                      for (final b in filteredBudgets) {
                        for (final tx in expenses) {
                          if (b.matchesTransaction(tx)) {
                            activeBudgetLogs.add((tx: tx, plan: b));
                          }
                        }
                      }
                      activeBudgetLogs.sort((a, b) => b.tx.date.compareTo(a.tx.date));

                      return RefreshIndicator(
                        onRefresh: () async {
                          await _fetchBudgets(isRefresh: true);
                          if (context.mounted) {
                            context.read<ExpenseBloc>().add(ExpenseFetchAll());
                          }
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            18,
                            8,
                            18,
                            MediaQuery.of(context).padding.bottom + 115,
                          ),
                          children: [
                            // Period Toggle (Monthly vs Yearly)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedPeriodFilter = 'monthly',
                                      ),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedPeriodFilter == 'monthly'
                                              ? (isDark
                                                  ? primaryColor
                                                  : Colors.white)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow:
                                              _selectedPeriodFilter == 'monthly' &&
                                                      !isDark
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.06),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Monthly Budgets ($monthlyCount)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: _selectedPeriodFilter ==
                                                    'monthly'
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : (isDark
                                                    ? Colors.white60
                                                    : Colors.grey.shade600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedPeriodFilter = 'yearly',
                                      ),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _selectedPeriodFilter == 'yearly'
                                              ? (isDark
                                                  ? primaryColor
                                                  : Colors.white)
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow:
                                              _selectedPeriodFilter == 'yearly' &&
                                                      !isDark
                                                  ? [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.06),
                                                        blurRadius: 6,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ]
                                                  : null,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Yearly Budgets ($yearlyCount)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: _selectedPeriodFilter ==
                                                    'yearly'
                                                ? (isDark
                                                    ? Colors.white
                                                    : Colors.black87)
                                                : (isDark
                                                    ? Colors.white60
                                                    : Colors.grey.shade600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Master Overview Card
                            BudgetMasterOverviewCard(
                              currencyCode: user.currency,
                              totalTarget: totalTarget,
                              totalSpent: totalSpent,
                              selectedPeriodFilter: _selectedPeriodFilter,
                              isDark: isDark,
                              primaryColor: primaryColor,
                            ),
                            const SizedBox(height: 22),

                            // Section Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Budget Goals',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.08)
                                            : Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${filteredBudgets.length} active',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (_isLoading)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (filteredBudgets.isEmpty)
                              _buildEmptyBudgetState(isDark, primaryColor)
                            else ...[
                              ...filteredBudgets.map((plan) {
                                final matching = plan.getMatchingTransactions(expenses);
                                final spent = matching.fold(0.0, (s, tx) => s + tx.amount);
                                return BudgetGoalCard(
                                  plan: plan,
                                  spent: spent,
                                  matchedExpenses: matching,
                                  currencyCode: user.currency,
                                  isDark: isDark,
                                  primaryColor: primaryColor,
                                  onTap: () => _showBudgetLogsSheet(
                                    context: context,
                                    plan: plan,
                                    matchingExpenses: matching,
                                    currencyCode: user.currency,
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                  onEdit: () => _showAddEditBudgetModal(plan),
                                  onDelete: () async {
                                    await BudgetStorageService.deleteBudget(
                                      user.id,
                                      plan.id,
                                    );
                                    _fetchBudgets();
                                    Fluttertoast.showToast(
                                      msg: 'Budget deleted',
                                    );
                                  },
                                );
                              }),

                              // Dedicated Active Budget Logs Section
                              if (activeBudgetLogs.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Budget Activity Logs',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${activeBudgetLogs.length} logged',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ...activeBudgetLogs.map(
                                  (item) => _buildBudgetLogTile(
                                    tx: item.tx,
                                    plan: item.plan,
                                    currencyCode: user.currency,
                                    isDark: isDark,
                                    primaryColor: primaryColor,
                                  ),
                                ),
                              ],
                            ],
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyBudgetState(bool isDark, Color primaryColor) {
    final periodName =
        _selectedPeriodFilter == 'monthly' ? 'Monthly' : 'Yearly';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.chart_pie_fill,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No $periodName Budgets Configured',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Set category targets for recurring expenses like Food, Bills, or Transport to stay disciplined and save more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showAddEditBudgetModal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.plus_circle_fill, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Create $periodName Budget',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetLogTile({
    required Expense tx,
    required BudgetPlan plan,
    required String currencyCode,
    required bool isDark,
    required Color primaryColor,
  }) {
    final cardBg = isDark ? const Color(0xFF1A1827) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final formattedDate = '${tx.date.day}/${tx.date.month}/${tx.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              CupertinoIcons.arrow_down_right,
              color: primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tx.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${tx.category} • $formattedDate',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '- ${CurrencyService.format(tx.amount, currencyCode)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  void _showBudgetLogsSheet({
    required BuildContext context,
    required BudgetPlan plan,
    required List<Expense> matchingExpenses,
    required String currencyCode,
    required bool isDark,
    required Color primaryColor,
  }) {
    final sheetBg = isDark ? const Color(0xFF161522) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
    final totalSpent = matchingExpenses.fold(0.0, (s, tx) => s + tx.amount);
    final isExceeded = totalSpent > plan.targetAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 42,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${plan.name} Logs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${matchingExpenses.length} contributing ${matchingExpenses.length == 1 ? 'expense' : 'expenses'} (${plan.category})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isExceeded
                            ? const Color(0xFFEF4444).withOpacity(0.12)
                            : const Color(0xFF10B981).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        CurrencyService.format(totalSpent, currencyCode),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isExceeded
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // Transaction List or Empty State
              Flexible(
                child: matchingExpenses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.doc_text_search,
                              size: 40,
                              color: isDark
                                  ? Colors.white30
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions matched yet',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expenses with category "${plan.category}" or related titles will appear here automatically.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        itemCount: matchingExpenses.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final tx = matchingExpenses[index];
                          final formattedDate =
                              '${tx.date.day}/${tx.date.month}/${tx.date.year}';

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    CupertinoIcons.arrow_down_right,
                                    color: primaryColor,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${tx.category} • $formattedDate',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '- ${CurrencyService.format(tx.amount, currencyCode)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

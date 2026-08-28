import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/budget_storage_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/budget_plan.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/budget_master_overview_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/budget_goal_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/add_edit_budget_sheet.dart';

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
  }

  Future<void> _fetchBudgets({bool isRefresh = false}) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      final userId = authState.user.id;
      
      // 1. Instant Cached Load (No spinner if cache exists)
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
      final list = await BudgetStorageService.loadBudgets(userId, forceRemote: isRefresh);
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF9F9FB),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 68),
        child: SizedBox(
          height: 38,
          child: FloatingActionButton.extended(
            backgroundColor: primaryColor,
            elevation: 3,
            onPressed: () => _showAddEditBudgetModal(),
            icon: const Icon(CupertinoIcons.plus_circle_fill, color: Colors.white, size: 16),
            label: const Text(
              'New Target',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () {
                      if (widget.onBackTap != null) {
                        widget.onBackTap!();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Budget Master',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
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

                    double totalTarget = filteredBudgets.fold(0.0, (s, b) => s + b.targetAmount);
                    double totalSpent = filteredBudgets.fold(0.0, (s, b) => s + b.calculateSpent(expenses));

                    return RefreshIndicator(
                      onRefresh: () async {
                        await _fetchBudgets(isRefresh: true);
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        children: [
                          // Period Toggle (Monthly vs Yearly)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPeriodFilter = 'monthly'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _selectedPeriodFilter == 'monthly'
                                            ? primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Monthly Budgets',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _selectedPeriodFilter == 'monthly'
                                              ? Colors.white
                                              : (isDark ? Colors.white60 : Colors.grey.shade700),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedPeriodFilter = 'yearly'),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _selectedPeriodFilter == 'yearly'
                                            ? primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Yearly Budgets',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: _selectedPeriodFilter == 'yearly'
                                              ? Colors.white
                                              : (isDark ? Colors.white60 : Colors.grey.shade700),
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
                          const SizedBox(height: 20),

                          // Section Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget Goals (${filteredBudgets.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showAddEditBudgetModal(),
                                child: Text(
                                  '+ Create Plan',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF60A5FA) : primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (filteredBudgets.isEmpty)
                            _buildEmptyBudgetState(isDark)
                          else
                            ...filteredBudgets.map((plan) {
                              final spent = plan.calculateSpent(expenses);
                              return BudgetGoalCard(
                                plan: plan,
                                spent: spent,
                                currencyCode: user.currency,
                                isDark: isDark,
                                primaryColor: primaryColor,
                                onEdit: () => _showAddEditBudgetModal(plan),
                                onDelete: () async {
                                  await BudgetStorageService.deleteBudget(user.id, plan.id);
                                  _fetchBudgets();
                                  Fluttertoast.showToast(msg: 'Budget deleted');
                                },
                              );
                            }),
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
    );
  }

  Widget _buildEmptyBudgetState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B29) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.chart_pie_fill, size: 48, color: isDark ? Colors.white38 : Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No ${_selectedPeriodFilter == 'monthly' ? 'Monthly' : 'Yearly'} Budgets Set',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take control of your finances by setting target limits!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}


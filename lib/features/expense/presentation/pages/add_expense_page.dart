import 'package:expense_tracker/core/common/utils/category_prediction_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/category_selector.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/sliding_segment_control.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/transaction_form_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:expense_tracker/core/common/utils/sound_service.dart';

class AddExpensePage extends StatefulWidget {
  final String initialType;
  final Expense? expenseToEdit;

  static Route route({
    String initialType = 'expense',
    Expense? expenseToEdit,
  }) =>
      MaterialPageRoute(
        builder: (context) => AddExpensePage(
          initialType: initialType,
          expenseToEdit: expenseToEdit,
        ),
      );

  const AddExpensePage({
    super.key,
    this.initialType = 'expense',
    this.expenseToEdit,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Entertainment';
  String? _selectedWalletId;
  late String _transactionType;
  bool _isCategoryManuallySelected = false;
  bool _isCategoryAutoDetected = false;

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _transactionType = e.type;
      _nameController.text = e.title;
      _amountController.text = e.amount.truncateToDouble() == e.amount
          ? e.amount.toInt().toString()
          : e.amount.toString();
      _selectedDate = e.date;
      _selectedCategory = e.category;
      _selectedWalletId = e.walletId;
      _notesController.text = e.notes ?? '';
      _isCategoryManuallySelected = true;
    } else {
      _transactionType = widget.initialType;
    }
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final text = _nameController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _isCategoryAutoDetected = false;
        _isCategoryManuallySelected = false;
      });
      return;
    }

    if (_isCategoryManuallySelected) return;

    final predicted = CategoryPredictionService.predictCategory(
      text,
      _transactionType,
    );
    if (predicted != null) {
      setState(() {
        _selectedCategory = predicted;
        _isCategoryAutoDetected = true;
      });
    } else if (_isCategoryAutoDetected) {
      setState(() {
        _isCategoryAutoDetected = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            scaffoldBackgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1B29),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _confirmDelete() {
    if (widget.expenseToEdit == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1B29) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.trash, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Transaction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${widget.expenseToEdit!.title}"? Your wallet balance and calculations will update instantly.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<ExpenseBloc>().add(ExpenseDeleteTransaction(widget.expenseToEdit!.id));
              SoundService.playDelete();
              Navigator.pop(context);
              Fluttertoast.showToast(msg: 'Transaction deleted');
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _submitExpense(String userId) {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final notes = _notesController.text.trim();

    if (name.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter transaction name');
      return;
    }
    if (amount <= 0) {
      Fluttertoast.showToast(msg: 'Please enter a valid amount');
      return;
    }

    if (widget.expenseToEdit != null) {
      final updated = widget.expenseToEdit!.copyWith(
        title: name,
        amount: amount,
        date: _selectedDate,
        type: _transactionType,
        category: _selectedCategory,
        walletId: _selectedWalletId,
        notes: notes.isNotEmpty ? notes : null,
      );
      context.read<ExpenseBloc>().add(ExpenseUpdateTransaction(updated));
      SoundService.playSuccess();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Transaction updated successfully!');
    } else {
      final expense = Expense(
        id: '',
        userId: userId,
        title: name,
        amount: amount,
        date: _selectedDate,
        type: _transactionType,
        category: _selectedCategory,
        walletId: _selectedWalletId,
        notes: notes.isNotEmpty ? notes : null,
      );

      context.read<ExpenseBloc>().add(ExpenseAddTransaction(expense));
      SoundService.playSuccess();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Transaction added successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.expenseToEdit != null ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (widget.expenseToEdit != null)
            IconButton(
              icon: const Icon(CupertinoIcons.trash, color: Colors.white, size: 21),
              tooltip: 'Delete Transaction',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = authState.user;
          final currencySymbol = CurrencyService.getSymbol(user.currency);

          return BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, expenseState) {
              List<Wallet> wallets = [];
              if (expenseState is ExpenseSuccess) {
                wallets = expenseState.wallets;
                if (wallets.isNotEmpty) {
                  if (_selectedWalletId == null) {
                    _selectedWalletId = widget.expenseToEdit?.walletId ?? wallets.first.id;
                  } else if (!wallets.any((w) => w.id == _selectedWalletId)) {
                    _selectedWalletId = wallets.first.id;
                  }
                }
              }

              final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
              final borderColor = isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200;
              final labelStyle = TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: isDark ? Colors.white54 : Colors.grey.shade600,
              );

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        // Segment control
                        SlidingSegmentControl(
                          value: _transactionType,
                          onChanged: (val) {
                            setState(() {
                              _transactionType = val;
                              _isCategoryManuallySelected = false;
                              _isCategoryAutoDetected = false;
                              final predicted = CategoryPredictionService.predictCategory(
                                _nameController.text,
                                val,
                              );
                              if (predicted != null) {
                                _selectedCategory = predicted;
                                _isCategoryAutoDetected = true;
                              } else {
                                _selectedCategory = val == 'income'
                                    ? 'Salary'
                                    : 'Food';
                              }
                            });
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 18),

                        // Section 1: Main Transaction Details Card
                        TransactionFormCard(
                          nameController: _nameController,
                          amountController: _amountController,
                          selectedDate: _selectedDate,
                          transactionType: _transactionType,
                          selectedWalletId: _selectedWalletId,
                          wallets: wallets,
                          currencySymbol: currencySymbol,
                          isDark: isDark,
                          primaryColor: primaryColor,
                          onPickDate: _pickDate,
                          onWalletChanged: (val) => setState(() => _selectedWalletId = val),
                        ),
                        const SizedBox(height: 14),

                        // Section 2: Category Selector
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CATEGORY', style: labelStyle),
                              const SizedBox(height: 8),
                              CategorySelector(
                                selectedCategory: _selectedCategory,
                                transactionType: _transactionType,
                                isAutoDetected: _isCategoryAutoDetected,
                                onCategorySelected: (cat) => setState(() {
                                  _selectedCategory = cat;
                                  _isCategoryManuallySelected = true;
                                  _isCategoryAutoDetected = false;
                                }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Section 3: Notes Field Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NOTES (OPTIONAL)', style: labelStyle),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _notesController,
                                minLines: 2,
                                maxLines: 2,
                                maxLength: 155,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  hintText: 'e.g. Paid via online banking ref #482...',
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                  fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
                                  filled: true,
                                  counterStyle: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: primaryColor, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                              shadowColor: primaryColor.withOpacity(0.35),
                            ),
                            onPressed: () => _submitExpense(user.id),
                            child: Text(
                              widget.expenseToEdit != null
                                  ? 'Save Changes'
                                  : 'Save Transaction',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        if (widget.expenseToEdit != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFFEF4444).withOpacity(0.14)
                                    : const Color(0xFFFEE2E2),
                                foregroundColor: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFDC2626),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFFEF4444).withOpacity(0.28)
                                        : const Color(0xFFFCA5A5),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              onPressed: _confirmDelete,
                              icon: const Icon(CupertinoIcons.trash, size: 20),
                              label: const Text(
                                'Delete Transaction',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

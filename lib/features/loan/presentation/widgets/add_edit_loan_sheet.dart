import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/loan/domain/entities/loan.dart';
import 'package:uuid/uuid.dart';

class AddEditLoanSheet extends StatefulWidget {
  final Loan? existingLoan;
  final String userId;
  final String currency;
  final bool isDark;
  final Color primaryColor;
  final String initialType; // 'borrowed' or 'lent'
  final Function(Loan loan) onSave;

  const AddEditLoanSheet({
    super.key,
    this.existingLoan,
    required this.userId,
    required this.currency,
    required this.isDark,
    required this.primaryColor,
    this.initialType = 'borrowed',
    required this.onSave,
  });

  @override
  State<AddEditLoanSheet> createState() => _AddEditLoanSheetState();
}

class _AddEditLoanSheetState extends State<AddEditLoanSheet> {
  late String _selectedType;
  late TextEditingController _titleController;
  late TextEditingController _counterpartyController;
  late TextEditingController _principalController;
  late TextEditingController _interestRateController;
  late TextEditingController _tenureController;
  late TextEditingController _notesController;

  String _interestType = 'none'; // 'none', 'percentage', 'fixed'
  DateTime _startDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final loan = widget.existingLoan;
    _selectedType = loan?.type ?? widget.initialType;
    _titleController = TextEditingController(text: loan?.title ?? '');
    _counterpartyController = TextEditingController(text: loan?.counterparty ?? '');
    _principalController = TextEditingController(
      text: loan != null ? loan.principal.toStringAsFixed(2) : '',
    );
    _interestRateController = TextEditingController(
      text: loan != null && loan.interestRate > 0 ? loan.interestRate.toStringAsFixed(1) : '',
    );
    _tenureController = TextEditingController(
      text: loan != null && loan.tenureMonths > 0 ? loan.tenureMonths.toString() : '',
    );
    _notesController = TextEditingController(text: loan?.notes ?? '');
    _interestType = loan?.interestType ?? 'none';
    if (loan != null) {
      _startDate = loan.startDate;
      _dueDate = loan.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _counterpartyController.dispose();
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final counterparty = _counterpartyController.text.trim();
    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final interestRate = double.tryParse(_interestRateController.text.trim()) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text.trim()) ?? 0;

    if (title.isEmpty) return;
    if (principal <= 0) return;

    final loan = Loan(
      id: widget.existingLoan?.id ?? const Uuid().v4(),
      userId: widget.userId,
      title: title,
      counterparty: counterparty.isEmpty ? (_selectedType == 'borrowed' ? 'Bank' : 'Friend') : counterparty,
      type: _selectedType,
      principal: principal,
      interestRate: _interestType == 'none' ? 0.0 : interestRate,
      interestType: _interestType,
      tenureMonths: tenure,
      startDate: _startDate,
      dueDate: _dueDate,
      walletId: widget.existingLoan?.walletId,
      status: widget.existingLoan?.status ?? 'active',
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      details: widget.existingLoan?.details ?? {},
      repayments: widget.existingLoan?.repayments ?? [],
      createdAt: widget.existingLoan?.createdAt ?? DateTime.now(),
    );

    widget.onSave(loan);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final fieldBg = isDark ? const Color(0xFF2A273A) : Colors.grey.shade100;
    final primaryColor = widget.primaryColor;

    final principal = double.tryParse(_principalController.text.trim()) ?? 0.0;
    final rate = double.tryParse(_interestRateController.text.trim()) ?? 0.0;
    final tenure = int.tryParse(_tenureController.text.trim()) ?? 0;

    double previewInterest = 0.0;
    if (_interestType == 'fixed') {
      previewInterest = (principal * rate) / 100.0;
    } else if (_interestType == 'percentage') {
      final years = tenure > 0 ? (tenure / 12.0) : 1.0;
      previewInterest = principal * (rate / 100.0) * years;
    }
    final previewTotal = principal + previewInterest;
    final previewEmi = tenure > 0 ? (previewTotal / tenure) : 0.0;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: bottomSafeArea > 0 ? bottomSafeArea + 16 : 28,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.building_2_fill,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existingLoan == null ? 'New Loan Record' : 'Edit Loan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          'Track borrowed liabilities or money lent out',
                          style: TextStyle(fontSize: 12, color: subTextColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Type Selector: Borrowed vs Lent
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A273A) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 'borrowed'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == 'borrowed'
                                ? const Color(0xFFEF4444)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.arrow_down_circle_fill,
                                size: 14,
                                color: _selectedType == 'borrowed' ? Colors.white : subTextColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Borrowed (I Owe)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedType == 'borrowed' ? Colors.white : subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 'lent'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == 'lent'
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.arrow_up_circle_fill,
                                size: 14,
                                color: _selectedType == 'lent' ? Colors.white : subTextColor,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Lent (Owed)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedType == 'lent' ? Colors.white : subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Title Field
              Text(
                'Loan Purpose / Title',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _selectedType == 'borrowed' ? 'e.g. Car Loan, Personal Debt' : 'e.g. Friendly Loan, Business Advance',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Counterparty Field
              Text(
                _selectedType == 'borrowed' ? 'Lender (Bank or Person Name)' : 'Borrower (Person or Client Name)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _counterpartyController,
                style: TextStyle(color: textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. John Doe, City Bank, BRAC',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),

              // Principal Amount Field
              Text(
                'Principal Amount (${widget.currency})',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _principalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          CurrencyService.getSymbol(widget.currency),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 36),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                  filled: true,
                  fillColor: fieldBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // Interest Model Selector
              Text(
                'Interest / Profit Model',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInterestChip('none', '0% Interest-Free'),
                  const SizedBox(width: 8),
                  _buildInterestChip('percentage', 'Annual % Rate'),
                  const SizedBox(width: 8),
                  _buildInterestChip('fixed', 'Flat Fee'),
                ],
              ),
              const SizedBox(height: 12),

              if (_interestType != 'none') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rate / Fee (%)', style: TextStyle(fontSize: 12, color: subTextColor)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _interestRateController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g. 8.5',
                              filled: true,
                              fillColor: fieldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tenure (Months)', style: TextStyle(fontSize: 12, color: subTextColor)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _tenureController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g. 12, 24, 36',
                              filled: true,
                              fillColor: fieldBg,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Dates Picker Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.calendar, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Date', style: TextStyle(fontSize: 10, color: subTextColor)),
                                Text(
                                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: fieldBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.clock, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Due Date', style: TextStyle(fontSize: 10, color: subTextColor)),
                                Text(
                                  _dueDate != null
                                      ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                                      : 'Optional',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Live Calculation Breakdown
              if (principal > 0)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Principal', style: TextStyle(fontSize: 12, color: subTextColor)),
                          Text(CurrencyService.format(principal, widget.currency), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                        ],
                      ),
                      if (previewInterest > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Interest', style: TextStyle(fontSize: 12, color: subTextColor)),
                            Text('+${CurrencyService.format(previewInterest, widget.currency)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Repayable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
                          Text(CurrencyService.format(previewTotal, widget.currency), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
                        ],
                      ),
                      if (previewEmi > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Est. Monthly Installment', style: TextStyle(fontSize: 12, color: subTextColor)),
                            Text('${CurrencyService.format(previewEmi, widget.currency)} / mo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: const Text('Save Record', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterestChip(String type, String label) {
    final isSelected = _interestType == type;
    final isDark = widget.isDark;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _interestType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.primaryColor.withOpacity(0.15)
                : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? widget.primaryColor : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? widget.primaryColor : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

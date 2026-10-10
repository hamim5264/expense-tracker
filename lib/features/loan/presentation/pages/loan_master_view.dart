import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/loan.dart';
import '../../data/services/loan_storage_service.dart';
import '../widgets/loan_kpi_card.dart';
import '../widgets/loan_card_item.dart';
import '../widgets/add_edit_loan_sheet.dart';
import '../widgets/log_repayment_sheet.dart';
import '../widgets/loan_details_sheet.dart';
import '../widgets/emi_calculator_sheet.dart';

class LoanMasterView extends StatefulWidget {
  final String userId;
  final String currency;
  final bool isDark;
  final Color primaryColor;

  const LoanMasterView({
    super.key,
    required this.userId,
    required this.currency,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  State<LoanMasterView> createState() => _LoanMasterViewState();
}

class _LoanMasterViewState extends State<LoanMasterView> {
  List<Loan> _loans = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: All, 1: Borrowed, 2: Lent, 3: Settled
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLoans({bool forceRemote = false}) async {
    // 1. Instant local cache load
    if (!forceRemote) {
      final cached = await LoanStorageService.loadLocalCache(widget.userId);
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _loans = cached;
          _isLoading = false;
        });
      }
    }

    // 2. Fetch fresh data
    final list = await LoanStorageService.loadLoans(widget.userId, forceRemote: forceRemote);
    if (mounted) {
      setState(() {
        _loans = list;
        _isLoading = false;
      });
    }
  }

  List<Loan> get _filteredLoans {
    return _loans.where((loan) {
      if (_selectedFilterIndex == 1 && (!loan.isBorrowed || loan.isSettled)) return false;
      if (_selectedFilterIndex == 2 && (!loan.isLent || loan.isSettled)) return false;
      if (_selectedFilterIndex == 3 && !loan.isSettled) return false;
      if (_selectedFilterIndex == 0 && loan.isSettled) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchCounterparty = loan.counterparty.toLowerCase().contains(query);
        final matchNotes = loan.notes?.toLowerCase().contains(query) ?? false;
        return matchCounterparty || matchNotes;
      }
      return true;
    }).toList();
  }

  void _openAddLoanSheet({String initialType = 'borrowed'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddEditLoanSheet(
        userId: widget.userId,
        currency: widget.currency,
        isDark: widget.isDark,
        primaryColor: widget.primaryColor,
        initialType: initialType,
        onSave: (loan) async {
          await LoanStorageService.saveLoan(loan);
          _loadLoans();
        },
      ),
    );
  }

  void _openEmiCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EmiCalculatorSheet(
        currency: widget.currency,
        onApplyToLoan: (principal, rate, months) {
          _openAddLoanSheet();
        },
      ),
    );
  }

  void _openLoanDetails(Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LoanDetailsSheet(
        loan: loan,
        currency: widget.currency,
        isDark: widget.isDark,
        primaryColor: widget.primaryColor,
        onUpdated: _loadLoans,
      ),
    );
  }

  void _openLogRepayment(Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LogRepaymentSheet(
        loan: loan,
        currency: widget.currency,
        isDark: widget.isDark,
        primaryColor: widget.primaryColor,
        onSaved: _loadLoans,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final primaryColor = widget.primaryColor;
    final filtered = _filteredLoans;

    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    return Column(
      children: [
        // KPI Summary Overview
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: LoanKpiCard(
            loans: _loans,
            currency: widget.currency,
            isDark: isDark,
            primaryColor: primaryColor,
          ),
        ),

        // Quick Actions & Tools Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _openEmiCalculator,
                    icon: Icon(CupertinoIcons.circle_grid_hex_fill, size: 15, color: primaryColor),
                    label: Text(
                      'EMI Simulator',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: primaryColor,
                      backgroundColor: primaryColor.withValues(alpha: 0.08),
                      side: BorderSide(color: primaryColor.withValues(alpha: 0.35), width: 1.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAddLoanSheet(),
                    icon: Icon(
                      CupertinoIcons.plus_circle_fill,
                      size: 15,
                      color: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                    ),
                    label: Text(
                      'Add New Loan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: primaryColor,
                      foregroundColor: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF20202F) : const Color(0xFFF2F3F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                hintText: 'Search loan by person, bank, note...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),

        // Filter Segmented Control
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              _buildFilterChip(
                0,
                'Active (${_loans.where((l) => !l.isSettled).length})',
                CupertinoIcons.square_grid_2x2,
                isDark,
                primaryColor,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                1,
                'Borrowed (${_loans.where((l) => l.isBorrowed && !l.isSettled).length})',
                CupertinoIcons.arrow_up_circle_fill,
                isDark,
                Colors.redAccent,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                2,
                'Lent (${_loans.where((l) => l.isLent && !l.isSettled).length})',
                CupertinoIcons.arrow_down_circle_fill,
                isDark,
                Colors.green,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                3,
                'Settled (${_loans.where((l) => l.isSettled).length})',
                CupertinoIcons.checkmark_seal_fill,
                isDark,
                primaryColor,
              ),
            ],
          ),
        ),

        // Loan List or Empty State
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(isDark, primaryColor)
              : RefreshIndicator(
                  onRefresh: () => _loadLoans(forceRemote: true),
                  color: primaryColor,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      MediaQuery.of(context).padding.bottom + 115,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final loan = filtered[index];
                      return LoanCardItem(
                        loan: loan,
                        currency: widget.currency,
                        isDark: isDark,
                        primaryColor: primaryColor,
                        onTap: () => _openLoanDetails(loan),
                        onLogPayment: () => _openLogRepayment(loan),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    int index,
    String label,
    IconData icon,
    bool isDark,
    Color activeColor,
  ) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF222232) : const Color(0xFFF3F4F8)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color primaryColor) {
    final bottomInset = MediaQuery.of(context).padding.bottom + 120;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.building_2_fill,
                size: 32,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _loans.isEmpty
                  ? 'No Loans Recorded Yet'
                  : 'No Matching Loans Found',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _loans.isEmpty
                  ? 'Track borrowed debts, money lent to others, interest rates, and EMI installments with complete clarity.'
                  : 'Try adjusting your search query or switching the filter tab.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            if (_loans.isEmpty) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _openAddLoanSheet(),
                icon: Icon(
                  CupertinoIcons.plus_circle_fill,
                  size: 15,
                  color: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                ),
                label: Text(
                  'Record First Loan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: primaryColor.computeLuminance() > 0.45 ? Colors.black87 : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

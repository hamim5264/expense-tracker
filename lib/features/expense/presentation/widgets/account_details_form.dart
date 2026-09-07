import 'package:expense_tracker/features/expense/presentation/widgets/record_income_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AccountDetailsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String selectedBankType;
  final TextEditingController bankNameController;
  final TextEditingController mobileProviderController;
  final TextEditingController accountNameController;
  final TextEditingController accountNumberController;
  final TextEditingController accountBalanceController;
  final FocusNode bankNameFocusNode;
  final FocusNode mobileProviderFocusNode;
  final FocusNode accountNameFocusNode;
  final FocusNode accountNumberFocusNode;
  final FocusNode accountBalanceFocusNode;
  final List<String> popularBanks;
  final List<String> popularMobileProviders;
  final bool isDark;
  final String displayName;
  final String userId;
  final bool recordAsIncome;
  final ValueChanged<bool> onToggleRecordAsIncome;
  final VoidCallback onChanged;
  final Function(String userId) onSaveBankWallet;

  const AccountDetailsForm({
    super.key,
    required this.formKey,
    required this.selectedBankType,
    required this.bankNameController,
    required this.mobileProviderController,
    required this.accountNameController,
    required this.accountNumberController,
    required this.accountBalanceController,
    required this.bankNameFocusNode,
    required this.mobileProviderFocusNode,
    required this.accountNameFocusNode,
    required this.accountNumberFocusNode,
    required this.accountBalanceFocusNode,
    required this.popularBanks,
    required this.popularMobileProviders,
    required this.isDark,
    required this.displayName,
    required this.userId,
    required this.recordAsIncome,
    required this.onToggleRecordAsIncome,
    required this.onChanged,
    required this.onSaveBankWallet,
  });

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      );

  InputDecoration _inputDeco(BuildContext context, String hint) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      fillColor: isDarkTheme ? Colors.white10 : Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    final isCash = selectedBankType == 'Cash in Hand';
    final isBank = selectedBankType == 'Bank Link';
    final isPaypal = selectedBankType == 'Paypal';
    final isMobile = selectedBankType == 'Mobile Banking';

    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isCash ? const Color(0xFF10B981) : primaryColor).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCash
                    ? Icons.payments_rounded
                    : isBank
                        ? Icons.account_balance_rounded
                        : isPaypal
                            ? Icons.payment_rounded
                            : Icons.phone_android_rounded,
                color: isCash ? const Color(0xFF10B981) : primaryColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              isCash
                  ? 'Cash in Hand'
                  : isBank
                      ? 'Link Bank Account'
                      : isPaypal
                          ? 'Link PayPal'
                          : 'Link Mobile Wallet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          if (isCash) ...[
            _fieldLabel('WALLET NAME'),
            const SizedBox(height: 8),
            TextFormField(
              controller: bankNameController,
              focusNode: bankNameFocusNode,
              decoration: _inputDeco(context, 'e.g. Cash in Hand'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(accountBalanceFocusNode),
            ),
            const SizedBox(height: 16),
          ] else ...[
            if (isBank) ...[
              _fieldLabel('BANK NAME'),
              const SizedBox(height: 8),
              TextFormField(
                controller: bankNameController,
                focusNode: bankNameFocusNode,
                decoration: _inputDeco(context, 'e.g. Chase Bank'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: popularBanks.map((bank) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          bank,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey.shade100,
                        onPressed: () {
                          bankNameController.text = bank;
                          onChanged();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (isMobile) ...[
              _fieldLabel('MOBILE PROVIDER'),
              const SizedBox(height: 8),
              TextFormField(
                controller: mobileProviderController,
                focusNode: mobileProviderFocusNode,
                decoration: _inputDeco(context, 'e.g. Venmo'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: popularMobileProviders.map((prov) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          prov,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark
                            ? Colors.white10
                            : Colors.grey.shade100,
                        onPressed: () {
                          mobileProviderController.text = prov;
                          onChanged();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            _fieldLabel(isBank ? 'ACCOUNT HOLDER NAME' : 'YOUR NAME / ALIAS'),
            const SizedBox(height: 8),
            TextFormField(
              controller: accountNameController,
              focusNode: accountNameFocusNode,
              decoration: _inputDeco(context, 'e.g. JOHN DOE'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(accountNumberFocusNode),
            ),
            const SizedBox(height: 16),

            _fieldLabel(
              isBank
                  ? 'ACCOUNT NUMBER (LAST 4 DIGITS)'
                  : isPaypal
                      ? 'PAYPAL EMAIL ADDRESS'
                      : 'REGISTERED PHONE NUMBER (LAST 4 DIGITS)',
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: accountNumberController,
              focusNode: accountNumberFocusNode,
              keyboardType: isPaypal
                  ? TextInputType.emailAddress
                  : TextInputType.number,
              inputFormatters: !isPaypal
                  ? [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ]
                  : null,
              onChanged: (val) {
                if (!isPaypal && val.length == 4) {
                  FocusScope.of(context).requestFocus(accountBalanceFocusNode);
                }
              },
              decoration: _inputDeco(
                context,
                isBank
                    ? 'e.g. 7890'
                    : isPaypal
                        ? 'name@example.com'
                        : 'e.g. 4321',
              ),
              validator: (v) {
                final val = v?.trim() ?? '';
                if (val.isEmpty) return 'Required';
                if (isPaypal && !val.contains('@')) return 'Enter a valid email';
                if (!isPaypal && val.length < 4) {
                  return 'Must be exactly 4 digits';
                }
                return null;
              },
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(accountBalanceFocusNode),
            ),
            const SizedBox(height: 16),
          ],

          _fieldLabel(isCash ? 'CURRENT CASH AMOUNT' : 'INITIAL BALANCE'),
          const SizedBox(height: 8),
          TextFormField(
            controller: accountBalanceController,
            focusNode: accountBalanceFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco(context, '0.00'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (double.tryParse(v.trim()) == null) {
                return 'Enter a valid amount';
              }
              return null;
            },
            onFieldSubmitted: (_) => onSaveBankWallet(userId),
          ),
          const SizedBox(height: 16),
          RecordIncomeToggle(
            value: recordAsIncome,
            onChanged: onToggleRecordAsIncome,
            isDark: isDark,
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCash ? const Color(0xFF10B981) : primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => onSaveBankWallet(userId),
              child: Text(
                isCash ? 'Save Cash Wallet' : 'Link Account',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

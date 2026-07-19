import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/premium_credit_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/account_option_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/card_number_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';

class ConnectWalletPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const ConnectWalletPage());

  const ConnectWalletPage({super.key});

  @override
  State<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends State<ConnectWalletPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isSaving = false;
  String _pendingToast = '';

  final _cardFormKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardCvcController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardZipController = TextEditingController();
  final _cardBalanceController = TextEditingController(text: '0.00');

  final _cardNameFocusNode = FocusNode();
  final _cardNumberFocusNode = FocusNode();
  final _cardExpiryFocusNode = FocusNode();
  final _cardCvcFocusNode = FocusNode();
  final _cardZipFocusNode = FocusNode();
  final _cardBalanceFocusNode = FocusNode();

  bool _showAccountDetailsForm = false;
  String _selectedBankType = 'Bank Link';

  final _accountFormKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountBalanceController = TextEditingController(text: '0.00');

  final _bankNameController = TextEditingController(text: 'Chase Bank');
  final _mobileProviderController = TextEditingController(text: 'bKash');

  final _bankNameFocusNode = FocusNode();
  final _mobileProviderFocusNode = FocusNode();

  final List<String> _popularBanks = [
    'Chase Bank',
    'Bank of America',
    'Wells Fargo',
    'HSBC',
    'Barclays',
    'Citi',
    'BRAC Bank',
    'Dutch-Bangla Bank',
  ];

  final List<String> _popularMobileProviders = [
    'bKash',
    'Nagad',
    'Rocket',
    'Venmo',
    'Cash App',
    'M-Pesa',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _cardCvcController.dispose();
    _cardExpiryController.dispose();
    _cardZipController.dispose();
    _cardBalanceController.dispose();
    _cardNameFocusNode.dispose();
    _cardNumberFocusNode.dispose();
    _cardExpiryFocusNode.dispose();
    _cardCvcFocusNode.dispose();
    _cardZipFocusNode.dispose();
    _cardBalanceFocusNode.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _accountBalanceController.dispose();
    _bankNameController.dispose();
    _mobileProviderController.dispose();
    _bankNameFocusNode.dispose();
    _mobileProviderFocusNode.dispose();
    super.dispose();
  }

  void _saveCardWallet(String userId) {
    if (!_cardFormKey.currentState!.validate()) return;
    final cardNum = _cardNumberController.text.replaceAll(' ', '');
    final initialBalance =
        double.tryParse(_cardBalanceController.text.trim()) ?? 0.0;
    final wallet = Wallet(
      id: '',
      userId: userId,
      name: _cardNameController.text.trim(),
      type: 'card',
      balance: initialBalance,
      details: {'card_number': cardNum},
      createdAt: DateTime.now(),
    );
    setState(() {
      _isSaving = true;
      _pendingToast = 'Card added successfully!';
    });
    context.read<ExpenseBloc>().add(ExpenseAddWalletCard(wallet));
  }

  void _saveBankWallet(String userId) {
    if (!_accountFormKey.currentState!.validate()) return;

    final initialBalance =
        double.tryParse(_accountBalanceController.text.trim()) ?? 0.0;
    String name = '';
    String type = 'bank';
    Map<String, dynamic> details = {};

    if (_selectedBankType == 'Bank Link') {
      final accNum = _accountNumberController.text.trim();
      final hidden = accNum.length > 4
          ? accNum.substring(accNum.length - 4)
          : accNum;
      final bankName = _bankNameController.text.trim();
      name = '$bankName (••$hidden)';
      type = 'bank';
      details = {
        'bank_name': bankName,
        'account_number': accNum,
        'account_holder': _accountNameController.text.trim(),
      };
    } else if (_selectedBankType == 'Paypal') {
      name = 'PayPal (${_accountNameController.text.trim()})';
      type = 'others';
      details = {
        'email': _accountNumberController.text.trim(),
        'account_name': _accountNameController.text.trim(),
      };
    } else {
      final phone = _accountNumberController.text.trim();
      final hidden = phone.length > 4
          ? phone.substring(phone.length - 4)
          : phone;
      final provider = _mobileProviderController.text.trim();
      name = '$provider (••$hidden)';
      type = 'others';
      details = {'provider': provider, 'phone_number': phone};
    }

    final wallet = Wallet(
      id: '',
      userId: userId,
      name: name,
      type: type,
      balance: initialBalance,
      details: details,
      createdAt: DateTime.now(),
    );

    setState(() {
      _isSaving = true;
      _pendingToast = 'Account linked successfully!';
    });
    context.read<ExpenseBloc>().add(ExpenseAddWalletCard(wallet));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFF4F378A);

    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (_isSaving && state is ExpenseSuccess) {
          setState(() => _isSaving = false);
          AnimationHelper.showSuccess(context, _pendingToast);
          final navigator = Navigator.of(context);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              navigator.pop();
            }
          });
        }
        if (_isSaving && state is ExpenseFailure) {
          setState(() => _isSaving = false);
          AnimationHelper.showFailed(context, 'Error: ${state.message}');
        }
      },
      builder: (context, expenseState) {
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final user = authState.user;
            final displayName = user.name.isEmpty
                ? user.email.split('@').first
                : user.name;

            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF121212)
                  : const Color(0xFFF9F9FB),
              appBar: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_showAccountDetailsForm) {
                      setState(() => _showAccountDetailsForm = false);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  _showAccountDetailsForm
                      ? 'Enter Account Details'
                      : 'Connect Wallet',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      if (!_showAccountDetailsForm)
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            labelColor: isDark ? Colors.white : primaryColor,
                            unselectedLabelColor: Colors.grey,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            tabs: const [
                              Tab(text: 'Cards'),
                              Tab(text: 'Accounts'),
                            ],
                          ),
                        ),

                      Expanded(
                        child: _showAccountDetailsForm
                            ? _buildAccountDetailsForm(
                                user.id,
                                isDark,
                                displayName,
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildCardsTab(user.id, isDark, displayName),
                                  _buildAccountsTab(isDark),
                                ],
                              ),
                      ),
                    ],
                  ),

                  if (_isSaving)
                    Container(
                      color: Colors.black45,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCardsTab(String userId, bool isDark, String displayName) {
    const primaryColor = Color(0xFF4F378A);
    return Form(
      key: _cardFormKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 8),
          PremiumCreditCard(
            cardHolderName: _cardNameController.text.isEmpty
                ? 'JOHN DOE'
                : _cardNameController.text.toUpperCase(),
            cardNumber: _cardNumberController.text.isEmpty
                ? '•••• •••• •••• ••••'
                : _cardNumberController.text,
            expiryDate: _cardExpiryController.text.isEmpty
                ? 'MM/YY'
                : _cardExpiryController.text,
          ),
          const SizedBox(height: 24),

          _fieldLabel('NAME ON CARD'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardNameController,
            focusNode: _cardNameFocusNode,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.characters,
            decoration: _inputDeco('e.g. JOHN DOE'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_cardNumberFocusNode),
          ),
          const SizedBox(height: 16),

          _fieldLabel('CARD NUMBER (LAST 4 DIGITS OR FULL)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardNumberController,
            focusNode: _cardNumberFocusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CardNumberFormatter(),
            ],
            onChanged: (val) {
              setState(() {});
            },
            decoration: _inputDeco('e.g. 4321 or Full Number'),
            validator: (v) {
              final clean = (v ?? '').replaceAll(' ', '');
              if (clean.isEmpty) return 'Card number is required';
              if (clean.length < 4) return 'Must be at least 4 digits';
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_cardBalanceFocusNode),
          ),
          const SizedBox(height: 16),

          _fieldLabel('INITIAL BALANCE'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardBalanceController,
            focusNode: _cardBalanceFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco('0.00'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (double.tryParse(v.trim()) == null) return 'Invalid number';
              return null;
            },
            onFieldSubmitted: (_) => _saveCardWallet(userId),
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => _saveCardWallet(userId),
              child: const Text(
                'Add Card',
                style: TextStyle(
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

  Widget _buildAccountsTab(bool isDark) {
    const primaryColor = Color(0xFF4F378A);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Choose an account type to link:',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        AccountOptionTile(
          title: 'Bank Link',
          subtitle: 'Connect your bank account directly',
          icon: Icons.account_balance_rounded,
          isSelected: _selectedBankType == 'Bank Link',
          onTap: () => setState(() => _selectedBankType = 'Bank Link'),
        ),
        const SizedBox(height: 14),
        AccountOptionTile(
          title: 'PayPal',
          subtitle: 'Link your PayPal account',
          icon: Icons.payment_rounded,
          isSelected: _selectedBankType == 'Paypal',
          onTap: () => setState(() => _selectedBankType = 'Paypal'),
        ),
        const SizedBox(height: 14),
        AccountOptionTile(
          title: 'Mobile Banking',
          subtitle: 'bKash, Nagad, Rocket, Upay & more',
          icon: Icons.phone_android_rounded,
          isSelected: _selectedBankType == 'Mobile Banking',
          onTap: () => setState(() => _selectedBankType = 'Mobile Banking'),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: () => setState(() => _showAccountDetailsForm = true),
            child: const Text(
              'Next →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAccountDetailsForm(
    String userId,
    bool isDark,
    String displayName,
  ) {
    const primaryColor = Color(0xFF4F378A);

    final isBank = _selectedBankType == 'Bank Link';
    final isPaypal = _selectedBankType == 'Paypal';
    final isMobile = _selectedBankType == 'Mobile Banking';

    return Form(
      key: _accountFormKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          const SizedBox(height: 16),

          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isBank
                    ? Icons.account_balance_rounded
                    : isPaypal
                    ? Icons.payment_rounded
                    : Icons.phone_android_rounded,
                color: primaryColor,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              isBank
                  ? 'Link Bank Account'
                  : isPaypal
                  ? 'Link PayPal'
                  : 'Link Mobile Wallet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),

          if (isBank) ...[
            _fieldLabel('BANK NAME'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bankNameController,
              focusNode: _bankNameFocusNode,
              decoration: _inputDeco('e.g. Chase Bank'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _popularBanks.map((bank) {
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
                        setState(() {
                          _bankNameController.text = bank;
                        });
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
              controller: _mobileProviderController,
              focusNode: _mobileProviderFocusNode,
              decoration: _inputDeco('e.g. Venmo'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _popularMobileProviders.map((prov) {
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
                        setState(() {
                          _mobileProviderController.text = prov;
                        });
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
            controller: _accountNameController,
            decoration: _inputDeco('e.g. JOHN DOE'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          _fieldLabel(
            isBank
                ? 'ACCOUNT NUMBER (LAST 4 DIGITS OR FULL)'
                : isPaypal
                ? 'PAYPAL EMAIL ADDRESS'
                : 'REGISTERED PHONE NUMBER (LAST 4 DIGITS OR FULL)',
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _accountNumberController,
            keyboardType: isPaypal
                ? TextInputType.emailAddress
                : TextInputType.number,
            inputFormatters: isMobile
                ? [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ]
                : null,
            decoration: _inputDeco(
              isBank
                  ? 'e.g. 7890 or Full Account Number'
                  : isPaypal
                  ? 'name@example.com'
                  : 'e.g. 4321 or Full Number',
            ),
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return 'Required';
              if (isPaypal && !val.contains('@')) return 'Enter a valid email';
              if (val.length < 4) {
                return 'Must be at least 4 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          _fieldLabel('INITIAL BALANCE'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _accountBalanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco('0.00'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (double.tryParse(v.trim()) == null) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () => _saveBankWallet(userId),
              child: const Text(
                'Link Account',
                style: TextStyle(
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

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Colors.grey,
      letterSpacing: 0.8,
    ),
  );

  InputDecoration _inputDeco(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      fillColor: isDark ? Colors.white10 : Colors.white,
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
        borderSide: const BorderSide(color: Color(0xFF4F378A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

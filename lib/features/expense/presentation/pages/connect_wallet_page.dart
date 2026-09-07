import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/account_option_tile.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/add_card_tab_form.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/account_details_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/common/utils/animation_helper.dart';
import 'package:expense_tracker/core/common/utils/show_snackbar.dart';

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
  final _cardBalanceController = TextEditingController();

  final _cardNameFocusNode = FocusNode();
  final _cardNumberFocusNode = FocusNode();
  final _cardExpiryFocusNode = FocusNode();
  final _cardCvcFocusNode = FocusNode();
  final _cardZipFocusNode = FocusNode();
  final _cardBalanceFocusNode = FocusNode();

  bool _showAccountDetailsForm = false;
  String _selectedBankType = 'Bank Link';
  bool _recordAsIncome = true;

  final _accountFormKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountBalanceController = TextEditingController();

  final _bankNameController = TextEditingController(text: 'Chase Bank');
  final _mobileProviderController = TextEditingController(text: 'bKash');

  final _bankNameFocusNode = FocusNode();
  final _mobileProviderFocusNode = FocusNode();
  final _accountNameFocusNode = FocusNode();
  final _accountNumberFocusNode = FocusNode();
  final _accountBalanceFocusNode = FocusNode();

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
    _accountNameFocusNode.dispose();
    _accountNumberFocusNode.dispose();
    _accountBalanceFocusNode.dispose();
    super.dispose();
  }

  void _saveCardWallet(String userId) {
    if (!_cardFormKey.currentState!.validate()) return;

    final expenseState = context.read<ExpenseBloc>().state;
    if (expenseState is ExpenseSuccess) {
      final cardCount = expenseState.wallets.where((w) => w.type == 'card').length;
      if (cardCount >= 3) {
        showToast('Maximum limit reached: You can only add up to 3 cards.', isError: true, context: context);
        return;
      }
    }

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
    context.read<ExpenseBloc>().add(
      ExpenseAddWalletCard(wallet, recordAsIncome: _recordAsIncome),
    );
  }

  void _saveBankWallet(String userId) {
    if (!_accountFormKey.currentState!.validate()) return;

    final initialBalance =
        double.tryParse(_accountBalanceController.text.trim()) ?? 0.0;
    String name = '';
    String type = 'bank';
    Map<String, dynamic> details = {};

    if (_selectedBankType == 'Cash in Hand') {
      name = _bankNameController.text.trim().isNotEmpty
          ? _bankNameController.text.trim()
          : 'Cash in Hand';
      type = 'others';
      details = {
        'is_cash': true,
        'wallet_category': 'cash',
      };
    } else if (_selectedBankType == 'Bank Link') {
      final accNum = _accountNumberController.text.trim();
      final hidden = accNum.length > 4
          ? accNum.substring(accNum.length - 4)
          : accNum;
      final bankName = _bankNameController.text.trim();
      name = '$bankName ($hidden)';
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
      name = '$provider ($hidden)';
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
      _pendingToast = _selectedBankType == 'Cash in Hand'
          ? 'Cash wallet saved successfully!'
          : 'Account linked successfully!';
    });
    context.read<ExpenseBloc>().add(
      ExpenseAddWalletCard(wallet, recordAsIncome: _recordAsIncome),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

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
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Clean Top Navigation Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                onPressed: () {
                                  if (_showAccountDetailsForm) {
                                    setState(() => _showAccountDetailsForm = false);
                                  } else {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              Expanded(
                                child: Text(
                                  _showAccountDetailsForm
                                      ? 'Enter Account Details'
                                      : 'Connect Wallet',
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
                      if (!_showAccountDetailsForm)
                        Container(
                          margin: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 4,
                            bottom: 12,
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
                            ? AccountDetailsForm(
                                formKey: _accountFormKey,
                                selectedBankType: _selectedBankType,
                                bankNameController: _bankNameController,
                                mobileProviderController: _mobileProviderController,
                                accountNameController: _accountNameController,
                                accountNumberController: _accountNumberController,
                                accountBalanceController: _accountBalanceController,
                                bankNameFocusNode: _bankNameFocusNode,
                                mobileProviderFocusNode: _mobileProviderFocusNode,
                                accountNameFocusNode: _accountNameFocusNode,
                                accountNumberFocusNode: _accountNumberFocusNode,
                                accountBalanceFocusNode: _accountBalanceFocusNode,
                                popularBanks: _popularBanks,
                                popularMobileProviders: _popularMobileProviders,
                                isDark: isDark,
                                displayName: displayName,
                                userId: user.id,
                                recordAsIncome: _recordAsIncome,
                                onToggleRecordAsIncome: (val) => setState(() => _recordAsIncome = val),
                                onChanged: () => setState(() {}),
                                onSaveBankWallet: _saveBankWallet,
                              )
                            : TabBarView(
                                controller: _tabController,
                                children: [
                                  AddCardTabForm(
                                    formKey: _cardFormKey,
                                    nameController: _cardNameController,
                                    numberController: _cardNumberController,
                                    balanceController: _cardBalanceController,
                                    nameFocusNode: _cardNameFocusNode,
                                    numberFocusNode: _cardNumberFocusNode,
                                    balanceFocusNode: _cardBalanceFocusNode,
                                    recordAsIncome: _recordAsIncome,
                                    onToggleRecordAsIncome: (val) => setState(() => _recordAsIncome = val),
                                    onChanged: () => setState(() {}),
                                    onSaveCard: _saveCardWallet,
                                    userId: user.id,
                                  ),
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
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildAccountsTab(bool isDark) {
    final primaryColor = Theme.of(context).primaryColor;
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
          title: 'Cash in Hand',
          subtitle: 'Track physical cash and pocket expenses',
          icon: Icons.payments_rounded,
          iconColor: const Color(0xFF10B981),
          isSelected: _selectedBankType == 'Cash in Hand',
          onTap: () => setState(() {
            _selectedBankType = 'Cash in Hand';
            _bankNameController.text = 'Cash in Hand';
          }),
        ),
        const SizedBox(height: 14),
        AccountOptionTile(
          title: 'Bank Link',
          subtitle: 'Connect your bank account directly',
          icon: Icons.account_balance_rounded,
          iconColor: const Color(0xFF3B82F6),
          isSelected: _selectedBankType == 'Bank Link',
          onTap: () => setState(() => _selectedBankType = 'Bank Link'),
        ),
        const SizedBox(height: 14),
        AccountOptionTile(
          title: 'PayPal',
          subtitle: 'Link your PayPal account',
          icon: Icons.payment_rounded,
          iconColor: const Color(0xFF6366F1),
          isSelected: _selectedBankType == 'Paypal',
          onTap: () => setState(() => _selectedBankType = 'Paypal'),
        ),
        const SizedBox(height: 14),
        AccountOptionTile(
          title: 'Mobile Banking',
          subtitle: 'bKash, Nagad, Rocket, Upay & more',
          icon: Icons.phone_android_rounded,
          iconColor: const Color(0xFF10B981),
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
}


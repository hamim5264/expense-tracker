import 'dart:async';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/core/common/utils/onyx_ai_engine.dart';
import 'package:expense_tracker/core/common/utils/onyx_financial_health_service.dart';
import 'package:expense_tracker/core/common/utils/onyx_forecast_service.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/animated_insight_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_avatar_section.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_chat_view.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_health_score_card.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_run_rate_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnyxAiPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const OnyxAiPage());

  const OnyxAiPage({super.key});

  @override
  State<OnyxAiPage> createState() => _OnyxAiPageState();
}

class _OnyxAiPageState extends State<OnyxAiPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _speechController;
  late Animation<double> _speechScale;
  late Animation<double> _speechFade;

  Timer? _speechTimer;
  final ValueNotifier<int> _greetingIndexNotifier = ValueNotifier<int>(0);
  int _selectedTab = 0; // 0: Insights & Health, 1: Ask Onyx (Chat)

  final List<String> _botGreetings = [
    'Hey there!',
    'How can I help today?',
    'Analyzing your spending...',
    'Hello! Ready to save?',
    'Hi! I\'m Onyx AI',
    'Let\'s check your goals',
    'Looking good today',
  ];

  String _selectedTimeframe = 'month'; // 'today', 'week', 'month', 'all'
  String _selectedInsightType = 'all'; // 'all', 'warning', 'success', 'info'

  List<Expense> _filterExpenses(List<Expense> expenses, String timeframe) {
    final now = DateTime.now();
    switch (timeframe) {
      case 'today':
        return expenses
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
      case 'week':
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return expenses
            .where((e) =>
                !e.date.isBefore(startOfWeek) &&
                e.date.isBefore(now.add(const Duration(days: 1))))
            .toList();
      case 'month':
        return expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
      case 'all':
      default:
        return expenses;
    }
  }

  String _formatHudAmount(double amount, String currencyCode) {
    final symbol = CurrencyService.getSymbol(currencyCode);
    final absAmount = amount.abs();
    final isInt = absAmount == absAmount.roundToDouble();
    final formattedNum = isInt
        ? absAmount.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')
        : absAmount.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    if (currencyCode.toUpperCase() == 'BDT') {
      return '$symbol $formattedNum';
    }
    return '$symbol$formattedNum';
  }

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(ExpenseFetchAll());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _speechController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _speechScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _speechController, curve: Curves.elasticOut),
    );

    _speechFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _speechController, curve: Curves.easeIn),
    );

    _startSpeechLoop();
  }

  void _startSpeechLoop() {
    _triggerSpeech();
    _speechTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _triggerSpeech();
      }
    });
  }

  void _triggerSpeech() async {
    if (!mounted) return;
    _greetingIndexNotifier.value =
        (_greetingIndexNotifier.value + 1) % _botGreetings.length;
    _speechController.forward();
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      _speechController.reverse();
    }
  }

  @override
  void dispose() {
    _speechTimer?.cancel();
    _pulseController.dispose();
    _speechController.dispose();
    _greetingIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final glowAccentColor = HSLColor.fromColor(primaryColor)
        .withLightness(
          (HSLColor.fromColor(primaryColor).lightness + 0.15).clamp(0.0, 0.95),
        )
        .toColor();

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9FB);
    final cardBg = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Top Header Container (AppBar + Sliding Tabs enclosed cleanly)
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -20,
                  left: -20,
                  child: Opacity(
                    opacity: 0.55,
                    child: Image.asset(
                      'assets/images/components/background_design.png',
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top App Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                CupertinoIcons.back,
                                color: Colors.white,
                              ),
                            ),
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Onyx Lumina AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showWhatsNewDialog(context),
                              icon: const Icon(
                                CupertinoIcons.ellipsis_vertical,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Sliding Tab Bar Selector
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 2, 20, 14),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: _selectedTab == 0
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.sparkles,
                                        size: 14,
                                        color: _selectedTab == 0
                                            ? primaryColor
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Insights & Health',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 0
                                              ? primaryColor
                                              : Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: _selectedTab == 1
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.15),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.chat_bubble_2_fill,
                                        size: 14,
                                        color: _selectedTab == 1
                                            ? primaryColor
                                            : Colors.white70,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ask Onyx',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: _selectedTab == 1
                                              ? primaryColor
                                              : Colors.white70,
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Body - EVERYTHING sits cleanly below the header!
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                String currencySymbol = '\$';
                if (authState is AuthSuccess) {
                  currencySymbol =
                      CurrencyService.getSymbol(authState.user.currency);
                }

                return BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    final allExpenses = state is ExpenseSuccess
                        ? state.expenses
                        : <Expense>[];
                    final wallets = state is ExpenseSuccess
                        ? state.wallets
                        : <Wallet>[];

                    final filteredExpenses =
                        _filterExpenses(allExpenses, _selectedTimeframe);

                    final insights = OnyxAiEngine.analyze(
                      expenses: filteredExpenses,
                      wallets: wallets,
                    );
                    final healthScore =
                        OnyxFinancialHealthService.calculate(
                      expenses: filteredExpenses,
                      wallets: wallets,
                    );
                    final forecast = OnyxForecastService.calculate(
                      filteredExpenses.isNotEmpty ? filteredExpenses : allExpenses,
                    );

                    final timeframeIncome = filteredExpenses
                        .where((e) => e.type == 'income')
                        .fold(0.0, (s, e) => s + e.amount);
                    final timeframeExpense = filteredExpenses
                        .where((e) => e.type == 'expense')
                        .fold(0.0, (s, e) => s + e.amount);
                    final timeframeNet = timeframeIncome - timeframeExpense;
                    final savingsRate = timeframeIncome > 0
                        ? ((timeframeNet / timeframeIncome) * 100).clamp(-100.0, 100.0)
                        : 0.0;

                    final alertsCount =
                        insights.where((i) => i.type == 'warning').length;
                    final savingsCount =
                        insights.where((i) => i.type == 'success').length;
                    final tipsCount =
                        insights.where((i) => i.type == 'info').length;

                    final displayedInsights = _selectedInsightType == 'all'
                        ? insights
                        : insights
                            .where((i) => i.type == _selectedInsightType)
                            .toList();

                    if (_selectedTab == 1) {
                      return OnyxChatView(
                        expenses: allExpenses,
                        wallets: wallets,
                        currencySymbol: currencySymbol,
                        isDark: isDark,
                        primaryColor: primaryColor,
                      );
                    }

                    final currencyCode = authState is AuthSuccess
                        ? authState.user.currency
                        : 'USD';

                    // Tab 0: Insights & Health Dashboard
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ExpenseBloc>().add(ExpenseFetchAll());
                        await Future.delayed(const Duration(milliseconds: 350));
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          20,
                          16,
                          20,
                          MediaQuery.of(context).padding.bottom + 40,
                        ),
                        children: [
                          const SizedBox(height: 6),
                          OnyxAvatarSection(
                            pulseController: _pulseController,
                            speechController: _speechController,
                            speechScale: _speechScale,
                            speechFade: _speechFade,
                            greetingIndexNotifier: _greetingIndexNotifier,
                            botGreetings: _botGreetings,
                            primaryColor: primaryColor,
                            glowAccentColor: glowAccentColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.sparkles,
                                    size: 13,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'ONYX LUMINA v3.0',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Timeframe Segmented Selector
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildTimeframeTab('Today', 'today', isDark, primaryColor),
                                _buildTimeframeTab('This Week', 'week', isDark, primaryColor),
                                _buildTimeframeTab('This Month', 'month', isDark, primaryColor),
                                _buildTimeframeTab('All Time', 'all', isDark, primaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Live Cash Flow Mini-HUD Card
                          _buildCashFlowHudCard(
                            income: timeframeIncome,
                            expense: timeframeExpense,
                            netMargin: timeframeNet,
                            savingsRate: savingsRate,
                            currencyCode: currencyCode,
                            isDark: isDark,
                            cardBg: cardBg,
                            borderColor: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.shade200,
                          ),
                          const SizedBox(height: 18),

                          // 1. Financial Health Score (0 - 100)
                          OnyxHealthScoreCard(
                            score: healthScore,
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 16),

                          // 2. Month-End Run-Rate Forecast Card
                          OnyxRunRateCard(
                            forecast: forecast,
                            currencySymbol: currencySymbol,
                            isDark: isDark,
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(height: 24),

                          // 3. Watchdog & Smart Insights Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Smart Watchdog & Recommendations',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Insight Filter Chips Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                _buildInsightFilterChip('All', 'all', insights.length, isDark, primaryColor),
                                const SizedBox(width: 8),
                                _buildInsightFilterChip('Alerts', 'warning', alertsCount, isDark, const Color(0xFFEF4444)),
                                const SizedBox(width: 8),
                                _buildInsightFilterChip('Savings', 'success', savingsCount, isDark, const Color(0xFF10B981)),
                                const SizedBox(width: 8),
                                _buildInsightFilterChip('Tips', 'info', tipsCount, isDark, const Color(0xFF3B82F6)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          if (displayedInsights.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 28,
                              ),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.06)
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'No $_selectedInsightType insights found for this period.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...displayedInsights.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final insight = entry.value;
                              return RepaintBoundary(
                                child: AnimatedInsightCard(
                                  insight: insight,
                                  index: idx,
                                  cardBg: cardBg,
                                  textColor: textColor,
                                  isDark: isDark,
                                ),
                              );
                            }),
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
    );
  }

  void _showWhatsNewDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1A1824) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.sparkles,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's New in Onyx Lumina",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Version 3.0 • Intelligent Financial Copilot',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Features list
                _buildFeatureItem(
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  iconColor: const Color(0xFF0284C7),
                  title: 'Ask Onyx Conversational Copilot',
                  description:
                      'Chat naturally about your money, balances, subscriptions, and spending trends with instant, zero-latency answers.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  icon: CupertinoIcons.shield_lefthalf_fill,
                  iconColor: const Color(0xFF10B981),
                  title: 'Financial Health Score (0 - 100)',
                  description:
                      'A composite diagnostic evaluating your savings rate, spend stability, budget balance, and liquid cash runway.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  icon: CupertinoIcons.graph_circle_fill,
                  iconColor: const Color(0xFFF59E0B),
                  title: 'Predictive Month-End Forecaster',
                  description:
                      'Calculates daily burn rates and projects month-end spending velocity to alert you before budget deficits occur.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  icon: CupertinoIcons.cart_badge_plus,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Purchase Affordability Simulator',
                  description:
                      'Simulates big-ticket purchases against your liquid reserves and projects buffer impact before you spend.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
                _buildFeatureItem(
                  icon: CupertinoIcons.lock_shield_fill,
                  iconColor: const Color(0xFF06B6D4),
                  title: '100% Private & On-Device',
                  description:
                      'Zero external third-party subscriptions, zero latency, offline ready, and 100% private to your device.',
                  isDark: isDark,
                ),
                const SizedBox(height: 22),

                // Dismiss Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explore Onyx Lumina',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeTab(
    String label,
    String value,
    bool isDark,
    Color primaryColor,
  ) {
    final isSelected = _selectedTimeframe == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTimeframe = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6.5),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? primaryColor : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              color: isSelected
                  ? (isDark ? Colors.white : primaryColor)
                  : (isDark ? Colors.white60 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightFilterChip(
    String label,
    String value,
    int count,
    bool isDark,
    Color chipColor,
  ) {
    final isSelected = _selectedInsightType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedInsightType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withOpacity(isDark ? 0.22 : 0.14)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor.withOpacity(0.5)
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : chipColor)
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? chipColor.withOpacity(0.3)
                    : (isDark ? Colors.white10 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? (isDark ? Colors.white : chipColor)
                      : (isDark ? Colors.white60 : Colors.grey.shade700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashFlowHudCard({
    required double income,
    required double expense,
    required double netMargin,
    required double savingsRate,
    required String currencyCode,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.42 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INCOME',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '+ ${_formatHudAmount(income, currencyCode)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF10B981),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 6),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EXPENSE',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '- ${_formatHudAmount(expense, currencyCode)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEF4444),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 26,
            width: 1,
            color: borderColor,
            margin: const EdgeInsets.symmetric(horizontal: 6),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET (${savingsRate.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${netMargin >= 0 ? '+' : '-'} ${_formatHudAmount(netMargin, currencyCode)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: netMargin >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

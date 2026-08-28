import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/onyx_ai_engine.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/onyx_avatar_section.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/animated_insight_card.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';

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

  final List<String> _botGreetings = [
    'Hey there!',
    'How can I help today?',
    'Analyzing your spending...',
    'Hello! Ready to save?',
    'Hi! I\'m Onyx AI',
    'Let\'s check your goals',
    'Looking good today',
  ];

  List<Expense>? _cachedExpensesRef;
  List<Wallet>? _cachedWalletsRef;
  List<AiInsight>? _cachedInsights;

  List<AiInsight> _getOrComputeInsights(
    List<Expense> expenses,
    List<Wallet> wallets,
  ) {
    if (_cachedInsights != null &&
        identical(_cachedExpensesRef, expenses) &&
        identical(_cachedWalletsRef, wallets)) {
      return _cachedInsights!;
    }
    _cachedExpensesRef = expenses;
    _cachedWalletsRef = wallets;
    _cachedInsights = OnyxAiEngine.analyze(
      expenses: expenses,
      wallets: wallets,
    );
    return _cachedInsights!;
  }

  @override
  void initState() {
    super.initState();
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
      body: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 240),
            painter: HeaderPainter(color: primaryColor),
          ),
          Positioned(
            top: -20,
            left: -20,
            child: Opacity(
              opacity: 0.80,
              child: Image.asset(
                'assets/images/components/background_design.png',
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
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
                            'Onyx Apex AI (Stable)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, state) {
                      final expenses = state is ExpenseSuccess
                          ? state.expenses
                          : <Expense>[];
                      final wallets = state is ExpenseSuccess
                          ? state.wallets
                          : <Wallet>[];
                      final insights = _getOrComputeInsights(expenses, wallets);

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        children: [
                          const SizedBox(height: 10),
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
                          const SizedBox(height: 18),
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
                                    'ONYX APEX STABLE',
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
                          const SizedBox(height: 28),
                          Text(
                            'Smart Insights & Recommendations',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...insights.asMap().entries.map((entry) {
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
                      );
                    },
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


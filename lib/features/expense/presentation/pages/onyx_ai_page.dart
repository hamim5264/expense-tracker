import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:expense_tracker/features/expense/presentation/bloc/expense_bloc.dart';
import 'package:expense_tracker/core/common/utils/onyx_ai_engine.dart';
import 'package:expense_tracker/features/expense/presentation/widgets/header_painter.dart';
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

  Color _getInsightColor(String type, BuildContext context) {
    switch (type) {
      case 'success':
        return const Color(0xFF22C55E);
      case 'warning':
        return const Color(0xFFFF6B6B);
      case 'info':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'success':
        return CupertinoIcons.sparkles;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle_fill;
      case 'info':
      default:
        return CupertinoIcons.lightbulb_fill;
    }
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
                          Center(
                            child: SizedBox(
                              width: 200,
                              height: 170,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RepaintBoundary(
                                    child: AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(
                                                  0.28 + 0.15 * _pulseController.value,
                                                ),
                                                blurRadius: 28,
                                                spreadRadius:
                                                    5 + 4 * _pulseController.value,
                                              ),
                                              BoxShadow(
                                                color: glowAccentColor.withOpacity(
                                                  0.22 + 0.12 * _pulseController.value,
                                                ),
                                                blurRadius: 16,
                                                spreadRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: child,
                                        );
                                      },
                                      child: Lottie.asset(
                                        'assets/animations/onyx_ai.json',
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return CircleAvatar(
                                            backgroundColor: primaryColor
                                                .withOpacity(0.1),
                                            child: Icon(
                                              CupertinoIcons.sparkles,
                                              size: 64,
                                              color: primaryColor,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 4,
                                    child: AnimatedBuilder(
                                      animation: _speechController,
                                      builder: (context, child) {
                                        return Opacity(
                                          opacity: _speechFade.value,
                                          child: Transform.scale(
                                            scale: _speechScale.value,
                                            alignment: Alignment.bottomLeft,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 12,
                                            sigmaY: 12,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withOpacity(0.12)
                                                  : Colors.white.withOpacity(0.25),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(16),
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomRight: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      4,
                                                    ),
                                                  ),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(
                                                  0.35,
                                                ),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(
                                                        isDark ? 0.2 : 0.05,
                                                      ),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: _greetingIndexNotifier,
                                              builder: (context, greetingIdx, _) {
                                                return Text(
                                                  _botGreetings[greetingIdx],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                getInsightColor: (type) =>
                                    _getInsightColor(type, context),
                                getInsightIcon: _getInsightIcon,
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

class AnimatedInsightCard extends StatefulWidget {
  final AiInsight insight;
  final int index;
  final Color cardBg;
  final Color textColor;
  final bool isDark;
  final Color Function(String) getInsightColor;
  final IconData Function(String) getInsightIcon;

  const AnimatedInsightCard({
    super.key,
    required this.insight,
    required this.index,
    required this.cardBg,
    required this.textColor,
    required this.isDark,
    required this.getInsightColor,
    required this.getInsightIcon,
  });

  @override
  State<AnimatedInsightCard> createState() => _AnimatedInsightCardState();
}

class _AnimatedInsightCardState extends State<AnimatedInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.getInsightColor(widget.insight.type);
    final icon = widget.getInsightIcon(widget.insight.type);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: FractionalTranslation(
            translation: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: widget.isDark
              ? LinearGradient(
                  colors: [
                    const Color(0xFF2A273A).withOpacity(0.9),
                    const Color(0xFF1E1B29).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFF8F9FA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          border: Border.all(
            color: color.withOpacity(widget.isDark ? 0.35 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 17),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.insight.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.1,
                            color: widget.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    widget.insight.message,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade700.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb_fill,
                          color: Colors.amber.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            widget.insight.recommendation,
                            style: TextStyle(
                              fontSize: 11.5,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: widget.isDark
                                  ? Colors.white70
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

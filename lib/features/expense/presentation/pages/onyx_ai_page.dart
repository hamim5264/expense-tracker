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
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getInsightColor(String type, BuildContext context) {
    switch (type) {
      case 'success':
        return const Color(0xFF22C55E);
      case 'warning':
        return const Color(0xFFEF4444);
      case 'info':
      default:
        return Theme.of(context).primaryColor;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.insights_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

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
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Onyx AI Assistant',
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
                      final insights = OnyxAiEngine.analyze(
                        expenses: expenses,
                        wallets: wallets,
                      );

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 170,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(
                                          0.25 * _pulseController.value,
                                        ),
                                        blurRadius: 35,
                                        spreadRadius:
                                            10 * _pulseController.value,
                                      ),
                                    ],
                                  ),
                                  child: child,
                                );
                              },
                              child: Lottie.asset(
                                'assets/animations/onyx_ai.json',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return CircleAvatar(
                                    backgroundColor: primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    child: Icon(
                                      Icons.psychology,
                                      size: 72,
                                      color: primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'BETA ANALYSIS ENGINE',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Smart Insights & Suggestions',
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
                            return AnimatedInsightCard(
                              insight: insight,
                              index: idx,
                              cardBg: cardBg,
                              textColor: textColor,
                              isDark: isDark,
                              getInsightColor: (type) =>
                                  _getInsightColor(type, context),
                              getInsightIcon: _getInsightIcon,
                            );
                          }),
                          const SizedBox(height: 24),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(widget.isDark ? 0.06 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.insight.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.insight.message,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: widget.isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.15), height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.insight.recommendation,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? Colors.white60
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'dart:async';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceCard extends StatefulWidget {
  final List<Wallet> cardWallets;
  final List<Expense> allTransactions;
  final String currencyCode;
  final VoidCallback? onAddCardTap;
  final ValueChanged<int>? onCardChanged;

  const BalanceCard({
    super.key,
    required this.cardWallets,
    required this.allTransactions,
    required this.currencyCode,
    this.onAddCardTap,
    this.onCardChanged,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  int _activeIndex = 0;
  String _selectedStyle = 'purple';
  Timer? _autoSwipeTimer;

  double get _activeBalance {
    if (widget.cardWallets.isEmpty) return 0.0;
    if (_activeIndex >= widget.cardWallets.length) return 0.0;
    return widget.cardWallets[_activeIndex].balance;
  }

  @override
  void initState() {
    super.initState();
    _loadStyles();
    _startAutoSwipeTimer();
  }

  void _startAutoSwipeTimer() {
    _autoSwipeTimer?.cancel();
    if (widget.cardWallets.length > 1) {
      _autoSwipeTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
        if (mounted && widget.cardWallets.length > 1) {
          final nextIdx = (_activeIndex + 1) % widget.cardWallets.length;
          _selectCard(nextIdx);
        }
      });
    }
  }

  void _selectCard(int index) async {
    setState(() {
      _activeIndex = index;
    });
    if (widget.onCardChanged != null) {
      widget.onCardChanged!(index);
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      if (widget.cardWallets.isNotEmpty && index < widget.cardWallets.length) {
        await prefs.setString('balance_card_active_wallet_id', widget.cardWallets[index].id);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cardWallets.length != oldWidget.cardWallets.length) {
      _loadStyles();
      _startAutoSwipeTimer();
    }
  }

  @override
  void dispose() {
    _autoSwipeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStyles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultStyle = prefs.getString('balance_card_style_default') ?? 'purple';
      final savedActiveId = prefs.getString('balance_card_active_wallet_id');
      
      int activeIdx = _activeIndex;
      if (savedActiveId != null && widget.cardWallets.isNotEmpty) {
        final idx = widget.cardWallets.indexWhere((w) => w.id == savedActiveId);
        if (idx != -1) {
          activeIdx = idx;
        }
      }
      if (activeIdx >= widget.cardWallets.length && widget.cardWallets.isNotEmpty) {
        activeIdx = 0;
      }

      setState(() {
        _activeIndex = activeIdx;
        _selectedStyle = defaultStyle;
      });
    } catch (_) {}
  }



  Map<String, dynamic> _getStyleConfig(bool isDark) {
    final balanceVal = _activeBalance;
    final negativeColor = const Color(0xFFFF6B6B);

    switch (_selectedStyle) {
      case 'glass':
        return {
          'isGlass': true,
          'gradient': LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E1B2E).withOpacity(0.85),
                    const Color(0xFF161224).withOpacity(0.75),
                  ]
                : [
                    Colors.white.withOpacity(0.92),
                    Colors.white.withOpacity(0.82),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'solidColor': isDark
              ? const Color(0xFF1A1829).withOpacity(0.80)
              : Colors.white.withOpacity(0.88),
          'borderColor': isDark
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.90),
          'textColor': isDark ? Colors.white : const Color(0xFF1F2937),
          'labelColor': isDark ? Colors.white.withOpacity(0.80) : const Color(0xFF4B5563),
          'totalBalanceColor': balanceVal < 0
              ? const Color(0xFFFF5252)
              : (balanceVal > 0
                  ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
                  : (isDark ? Colors.white : const Color(0xFF1F2937))),
          'incomeColor': isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          'expensesColor': const Color(0xFFFF5252),
        };
      case 'silver':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFCBD5E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': const Color(0xFF0F172A),
          'labelColor': const Color(0xFF475569),
          'totalBalanceColor': balanceVal < 0
              ? const Color(0xFFDC2626)
              : const Color(0xFF0F172A),
          'incomeColor': const Color(0xFF16A34A),
          'expensesColor': const Color(0xFFDC2626),
        };
      case 'rose_gold':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFFFFF1F2), Color(0xFFFECDD3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': const Color(0xFF881337),
          'labelColor': const Color(0xFF9F1239),
          'totalBalanceColor': balanceVal < 0
              ? const Color(0xFFE11D48)
              : const Color(0xFF881337),
          'incomeColor': const Color(0xFF15803D),
          'expensesColor': const Color(0xFFE11D48),
        };
      case 'ocean':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': balanceVal < 0 ? negativeColor : Colors.white,
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF9E9E),
        };
      case 'sunset':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFFF857A6), Color(0xFFFF5858)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': balanceVal < 0 ? negativeColor : Colors.white,
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFFD2D2),
        };
      case 'dark_obsidian':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': balanceVal < 0
              ? negativeColor
              : (balanceVal > 0
                  ? const Color(0xFF4ADE80)
                  : Colors.white),
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF6B6B),
        };
      case 'golden':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFF855B00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': balanceVal < 0 ? negativeColor : Colors.white,
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFFD2D2),
        };
      case 'purple':
      default:
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFF65558F), Color(0xFF4F378A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': balanceVal < 0
              ? negativeColor
              : (balanceVal > 0
                  ? const Color(0xFF4ADE80)
                  : Colors.white),
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF6B6B),
        };
    }
  }

  String _detectCardType(String rawNumber, String walletType, String walletName) {
    final clean = rawNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.startsWith('4')) return 'VISA';
    if (RegExp(r'^(5[1-5]|2[2-7])').hasMatch(clean)) return 'MASTERCARD';
    if (RegExp(r'^3[47]').hasMatch(clean)) return 'AMEX';
    if (RegExp(r'^(6011|65)').hasMatch(clean)) return 'DISCOVER';
    if (RegExp(r'^35').hasMatch(clean)) return 'JCB';
    
    final lowerName = walletName.toLowerCase();
    final lowerType = walletType.toLowerCase();
    if (lowerName.contains('paypal') || lowerType.contains('paypal')) return 'PAYPAL';
    if (lowerName.contains('visa') || lowerType.contains('visa')) return 'VISA';
    if (lowerName.contains('master') || lowerType.contains('master')) return 'MASTERCARD';
    if (lowerName.contains('bkash')) return 'BKASH';
    if (lowerName.contains('nagad')) return 'NAGAD';
    if (walletType.isNotEmpty && walletType != 'card') return walletType.toUpperCase();
    return 'CARD';
  }

  Widget _buildBackCardWidget(bool isDark, bool isLightHeader, Wallet wallet, int index, int depth) {
    final cardNum = wallet.details['card_number'] as String? ?? '0000';
    final last4 = cardNum.length > 4 ? cardNum.substring(cardNum.length - 4) : cardNum;

    final expDate = wallet.details['expiry'] as String? ?? '08/32';
    final cardType = _detectCardType(cardNum, wallet.type, wallet.name);

    // Deeper cards get lower opacity to blend into the header
    final double fillOpacity = depth == 2 ? 0.12 : 0.20;
    final double borderOpacity = depth == 2 ? 0.18 : 0.30;
    final double textOpacity = depth == 2 ? 0.55 : 0.75;

    Widget backCardBody = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          color: isLightHeader
              ? Colors.black.withOpacity(fillOpacity * 0.35)
              : Colors.white.withOpacity(fillOpacity),
          border: Border.all(
            color: isLightHeader
                ? Colors.black.withOpacity(borderOpacity * 0.35)
                : Colors.white.withOpacity(borderOpacity),
            width: 1.0,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '•••• $last4',
                      style: TextStyle(
                        color: isLightHeader
                            ? Colors.black87.withOpacity(textOpacity)
                            : Colors.white.withOpacity(textOpacity),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      expDate,
                      style: TextStyle(
                        color: isLightHeader
                            ? Colors.black54.withOpacity(textOpacity)
                            : Colors.white.withOpacity(textOpacity * 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  cardType,
                  style: TextStyle(
                    color: isLightHeader
                        ? Colors.black87.withOpacity(textOpacity)
                        : Colors.white.withOpacity(textOpacity),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectCard(index),
      child: backCardBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLightHeader = theme.primaryColor.computeLuminance() > 0.45;
    final config = _getStyleConfig(isDark);

    final activeWallet = widget.cardWallets.isNotEmpty ? widget.cardWallets[_activeIndex < widget.cardWallets.length ? _activeIndex : 0] : null;
    final activeBalance = _activeBalance;
    
    double activeIncome = 0.0;
    double activeExpenses = 0.0;
    if (activeWallet != null) {
      final walletTx = widget.allTransactions.where((tx) => tx.walletId == activeWallet.id).toList();
      for (var tx in walletTx) {
        if (tx.type == 'income') {
          activeIncome += tx.amount;
        } else {
          activeExpenses += tx.amount;
        }
      }
    }

    Widget cardBody;

    cardBody = ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          color: isLightHeader
              ? Colors.black.withOpacity(0.06)
              : Colors.white.withOpacity(0.40),
          border: Border.all(
            color: isLightHeader
                ? Colors.black.withOpacity(0.12)
                : Colors.white.withOpacity(0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isLightHeader ? 0.06 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: _buildCardContent(config, isDark, isLightHeader, activeBalance, activeIncome, activeExpenses),
          ),
        ),
      ),
    );

    if (widget.cardWallets.length > 1) {
      final wallets = widget.cardWallets;
      final List<Widget> cardStackWidgets = [];
      final int maxDepth = wallets.length > 2 ? 2 : 1;
      
      for (int d = maxDepth; d >= 0; d--) {
        final walletIdx = (_activeIndex + d) % wallets.length;
        final wallet = wallets[walletIdx];
        
        final double topOffset = d == 0 ? 72.0 : (d == 1 ? 36.0 : 0.0);
        final double scaleVal = d == 0 ? 1.0 : (d == 1 ? 0.94 : 0.88);
        
        Widget childWidget;
        if (d == 0) {
          childWidget = cardBody;
        } else {
          childWidget = _buildBackCardWidget(isDark, isLightHeader, wallet, walletIdx, d);
        }
        
        cardStackWidgets.add(
          AnimatedPositioned(
            key: ValueKey(wallet.id),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            top: topOffset,
            left: 0,
            right: 0,
            child: AnimatedScale(
              scale: scaleVal,
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: childWidget,
            ),
          ),
        );
      }
      
      return Container(
        height: 132,
        margin: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: cardStackWidgets,
        ),
      );
    }

    if (widget.cardWallets.isEmpty) {
      return Container(
        height: 132,
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              color: isLightHeader
                  ? Colors.black.withOpacity(0.06)
                  : Colors.white.withOpacity(0.35),
              border: Border.all(
                color: isLightHeader
                    ? Colors.black.withOpacity(0.12)
                    : Colors.white.withOpacity(0.50),
                width: 1.2,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_off_rounded,
                      color: isLightHeader ? const Color(0xFF1F2937) : Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Please add your wallet or card',
                      style: TextStyle(
                        color: isLightHeader ? const Color(0xFF1F2937) : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
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

    if (widget.cardWallets.length == 1) {
      return Container(
        height: 132,
        alignment: Alignment.bottomCenter,
        child: cardBody,
      );
    }

    return cardBody;
  }

  Widget _buildCardContent(
    Map<String, dynamic> config,
    bool isDark,
    bool isLightHeader,
    double activeBalance,
    double activeIncome,
    double activeExpenses,
  ) {
    final wallet = widget.cardWallets.isNotEmpty
        ? widget.cardWallets[_activeIndex < widget.cardWallets.length ? _activeIndex : 0]
        : null;
    final cardNum = wallet?.details['card_number'] as String? ?? '9286';
    final last4 = cardNum.length > 4 ? cardNum.substring(cardNum.length - 4) : cardNum;
    final expDate = wallet?.details['expiry'] as String? ?? '08/32';
    final cardType = wallet != null
        ? _detectCardType(cardNum, wallet.type, wallet.name)
        : 'CARD';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '•••• $last4',
                style: TextStyle(
                  color: isLightHeader ? const Color(0xFF1F2937) : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                expDate,
                style: TextStyle(
                  color: isLightHeader
                      ? const Color(0xFF4B5563)
                      : Colors.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            cardType,
            style: TextStyle(
              color: isLightHeader ? const Color(0xFF1F2937) : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class CardCutoutClipper extends CustomClipper<Path> {
  final double radius;
  CardCutoutClipper({this.radius = 28.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    final cutoutW = 105.0;
    final cutoutH = 38.0;
    
    path.moveTo(radius, 0);
    path.lineTo(w - radius, 0);
    path.quadraticBezierTo(w, 0, w, radius);
    
    path.lineTo(w, h - cutoutH - radius);
    path.quadraticBezierTo(w, h - cutoutH, w - radius, h - cutoutH);
    
    path.lineTo(w - cutoutW + radius, h - cutoutH);
    path.quadraticBezierTo(w - cutoutW, h - cutoutH, w - cutoutW, h - cutoutH + radius);
    
    path.lineTo(w - cutoutW, h - radius);
    path.quadraticBezierTo(w - cutoutW, h, w - cutoutW - radius, h);
    
    path.lineTo(radius, h);
    path.quadraticBezierTo(0, h, 0, h - radius);
    
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class CardTexturePainter extends CustomPainter {
  final bool isLight;
  CardTexturePainter({this.isLight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = isLight
        ? Colors.black.withOpacity(0.09)
        : Colors.white.withOpacity(0.045);
    final dotColor = isLight
        ? Colors.black.withOpacity(0.07)
        : Colors.white.withOpacity(0.035);

    final wavePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double i = -size.width * 0.5; i < size.width * 1.5; i += 28) {
      path.moveTo(i, 0);
      path.cubicTo(
        i + size.width * 0.4,
        size.height * 0.25,
        i + size.width * 0.15,
        size.height * 0.75,
        i + size.width * 0.7,
        size.height,
      );
    }
    canvas.drawPath(path, wavePaint);

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = 14; x < size.width; x += 22) {
      for (double y = 14; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CardTexturePainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}

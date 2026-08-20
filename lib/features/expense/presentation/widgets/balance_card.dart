import 'dart:ui';
import 'dart:async';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:expense_tracker/features/expense/domain/entities/wallet.dart';
import 'package:expense_tracker/features/expense/domain/entities/expense.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceCard extends StatefulWidget {
  final List<Wallet> cardWallets;
  final List<Expense> allTransactions;
  final String currencyCode;
  final VoidCallback? onAddCardTap;

  const BalanceCard({
    super.key,
    required this.cardWallets,
    required this.allTransactions,
    required this.currencyCode,
    this.onAddCardTap,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  int _activeIndex = 0;
  Map<String, String> _cardStyles = {};
  String _selectedStyle = 'purple';
  bool _isBalanceVisible = false;
  Timer? _hideTimer;

  double get _activeBalance {
    if (widget.cardWallets.isEmpty) return 0.0;
    if (_activeIndex >= widget.cardWallets.length) return 0.0;
    return widget.cardWallets[_activeIndex].balance;
  }

  @override
  void initState() {
    super.initState();
    _loadStyles();
  }

  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cardWallets.length != oldWidget.cardWallets.length) {
      _loadStyles();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _revealBalance() {
    _hideTimer?.cancel();
    setState(() {
      _isBalanceVisible = true;
    });

    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isBalanceVisible = false;
        });
      }
    });
  }

  void _toggleBalanceVisibility() {
    if (_isBalanceVisible) {
      _hideTimer?.cancel();
      setState(() {
        _isBalanceVisible = false;
      });
    } else {
      _revealBalance();
    }
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

      final Map<String, String> loadedStyles = {};
      for (var wallet in widget.cardWallets) {
        final style = prefs.getString('balance_card_style_${wallet.id}') ?? defaultStyle;
        loadedStyles[wallet.id] = style;
      }

      setState(() {
        _activeIndex = activeIdx;
        _cardStyles = loadedStyles;
        if (widget.cardWallets.isNotEmpty) {
          final activeWallet = widget.cardWallets[_activeIndex < widget.cardWallets.length ? _activeIndex : 0];
          _selectedStyle = loadedStyles[activeWallet.id] ?? defaultStyle;
        } else {
          _selectedStyle = defaultStyle;
        }
      });
    } catch (_) {}
  }

  Future<void> _loadSelectedStyle() async {
    await _loadStyles();
  }

  Future<void> _saveSelectedStyle(String style) async {
    setState(() {
      _selectedStyle = style;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('balance_card_style_default', style);
      
      if (widget.cardWallets.isNotEmpty) {
        final activeWallet = widget.cardWallets[_activeIndex < widget.cardWallets.length ? _activeIndex : 0];
        _cardStyles[activeWallet.id] = style;
        await prefs.setString('balance_card_style_${activeWallet.id}', style);
      }
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
            colors: [
              Colors.white.withOpacity(0.16),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'solidColor': null,
          'borderColor': Colors.white.withOpacity(0.22),
          'textColor': Colors.white.withOpacity(0.95),
          'labelColor': Colors.white.withOpacity(0.7),
          'totalBalanceColor': balanceVal < 0
              ? negativeColor
              : (balanceVal > 0
                  ? const Color(0xFF4ADE80)
                  : Colors.white),
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF6B6B),
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

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1B29) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customize Balance Card Style',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStyleOption('purple', 'Purple', const [
                      Color(0xFF65558F),
                      Color(0xFF4F378A),
                    ], false),
                    _buildStyleOption('glass', 'Glass', const [
                      Colors.white30,
                      Colors.white10,
                    ], true),
                    _buildStyleOption('silver', 'Platinum', const [
                      Color(0xFFF8FAFC),
                      Color(0xFFCBD5E1),
                    ], false),
                    _buildStyleOption('rose_gold', 'Rose Gold', const [
                      Color(0xFFFFF1F2),
                      Color(0xFFFECDD3),
                    ], false),
                    _buildStyleOption('golden', 'Golden', const [
                      Color(0xFFD4AF37),
                      Color(0xFF855B00),
                    ], false),
                    _buildStyleOption('ocean', 'Ocean', const [
                      Color(0xFF00B4DB),
                      Color(0xFF0083B0),
                    ], false),
                    _buildStyleOption('sunset', 'Sunset', const [
                      Color(0xFFF857A6),
                      Color(0xFFFF5858),
                    ], false),
                    _buildStyleOption('dark_obsidian', 'Obsidian', const [
                      Color(0xFF232526),
                      Color(0xFF414345),
                    ], false),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStyleOption(
    String id,
    String label,
    List<Color> colors,
    bool isGlass,
  ) {
    final isSelected = _selectedStyle == id;
    return GestureDetector(
      onTap: () {
        _saveSelectedStyle(id);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4F378A)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: isGlass
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                alignment: isGlass ? Alignment.center : null,
                child: isGlass
                    ? const Icon(
                        Icons.blur_on_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getBackCardGradient(String style, int index) {
    final stylesList = [
      'purple',
      'silver',
      'rose_gold',
      'golden',
      'ocean',
      'sunset',
      'dark_obsidian'
    ];
    String finalStyle = style;
    if (style == 'default') {
      finalStyle = stylesList[index % stylesList.length];
    }
    switch (finalStyle) {
      case 'silver':
        return [const Color(0xFFF8FAFC), const Color(0xFFCBD5E1)];
      case 'rose_gold':
        return [const Color(0xFFFFF1F2), const Color(0xFFFECDD3)];
      case 'ocean':
        return [const Color(0xFF00B4DB), const Color(0xFF0083B0)];
      case 'sunset':
        return [const Color(0xFFF857A6), const Color(0xFFFF5858)];
      case 'dark_obsidian':
        return [const Color(0xFF232526), const Color(0xFF414345)];
      case 'golden':
        return [const Color(0xFFD4AF37), const Color(0xFF855B00)];
      case 'glass':
        return [Colors.white.withOpacity(0.16), Colors.white.withOpacity(0.03)];
      case 'purple':
      default:
        return [const Color(0xFF65558F), const Color(0xFF4F378A)];
    }
  }

  Widget _buildBackCardWidget(bool isDark, Wallet wallet, int index, int depth) {
    final cardNum = wallet.details['card_number'] as String? ?? '0000';
    final last4 = cardNum.length > 4 ? cardNum.substring(cardNum.length - 4) : cardNum;
    
    final style = _cardStyles[wallet.id] ?? 'purple';
    final isLightBackCard = style == 'silver' || style == 'rose_gold';
    final colors = _getBackCardGradient(style, index);

    Widget backCardBody = Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: CustomPaint(
                size: Size.infinite,
                painter: CardTexturePainter(isLight: isLightBackCard),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '•••• •••• $last4',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);

    if (widget.onAddCardTap != null) {
      backCardBody = ClipPath(
        clipper: CardCutoutClipper(radius: 28),
        child: backCardBody,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        setState(() {
          _activeIndex = index;
        });
        await _loadSelectedStyle();
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('balance_card_active_wallet_id', wallet.id);
        } catch (_) {}
      },
      child: backCardBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

    final isLightCard =
        _selectedStyle == 'silver' || _selectedStyle == 'rose_gold';

    final textureOverlay = Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: CardTexturePainter(isLight: isLightCard),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLightCard
                      ? [
                          Colors.black.withOpacity(0.04),
                          Colors.black.withOpacity(0.01),
                          Colors.transparent,
                        ]
                      : [
                          Colors.white.withOpacity(0.14),
                          Colors.white.withOpacity(0.02),
                          Colors.transparent,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (config['isGlass'] == true) {
      cardBody = ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: config['solidColor'],
            gradient: config['gradient'],
            border: Border.all(color: config['borderColor'], width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Stack(
                children: [
                  textureOverlay,
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: _buildCardContent(config, isDark, activeBalance, activeIncome, activeExpenses),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      cardBody = Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: config['gradient'],
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            textureOverlay,
            Padding(
              padding: const EdgeInsets.all(22),
              child: _buildCardContent(config, isDark, activeBalance, activeIncome, activeExpenses),
            ),
          ],
        ),
      );
    }

    if (widget.onAddCardTap != null) {
      cardBody = ClipPath(
        clipper: CardCutoutClipper(radius: 28),
        child: cardBody,
      );

      final addCardTextColor = config['textColor'] as Color? ?? Colors.white;

      cardBody = Stack(
        children: [
          cardBody,
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: widget.onAddCardTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: config['solidColor'] ?? (config['gradient'] != null ? config['gradient'].colors.first : Colors.black),
                  gradient: config['gradient'] != null
                      ? LinearGradient(
                          colors: config['gradient'].colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isDark ? Colors.white.withAlpha(40) : Colors.black.withAlpha(20),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: addCardTextColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Add Card',
                      style: TextStyle(
                        color: addCardTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (widget.cardWallets.length > 1) {
      final wallets = widget.cardWallets;
      final List<Widget> cardStackWidgets = [];
      final int maxDepth = wallets.length > 2 ? 2 : 1;
      
      for (int d = maxDepth; d >= 0; d--) {
        final walletIdx = (_activeIndex + d) % wallets.length;
        final wallet = wallets[walletIdx];
        
        final double bottomOffset = d == 0 ? 0.0 : (d == 1 ? 20.0 : 40.0);
        final double scaleVal = d == 0 ? 1.0 : (d == 1 ? 0.95 : 0.90);
        
        Widget childWidget;
        if (d == 0) {
          childWidget = cardBody;
        } else {
          childWidget = _buildBackCardWidget(isDark, wallet, walletIdx, d);
        }
        
        cardStackWidgets.add(
          AnimatedPositioned(
            key: ValueKey(wallet.id),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            bottom: bottomOffset,
            left: 0,
            right: 0,
            child: AnimatedScale(
              scale: scaleVal,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.bottomCenter,
              child: childWidget,
            ),
          ),
        );
      }
      
      return Container(
        height: 240,
        margin: const EdgeInsets.only(top: 4),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: cardStackWidgets,
        ),
      );
    }

    return cardBody;
  }

  Widget _buildCardContent(
    Map<String, dynamic> config,
    bool isDark,
    double activeBalance,
    double activeIncome,
    double activeExpenses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: config['labelColor'],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isBalanceVisible
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: config['labelColor'],
                  size: 20,
                ),
              ],
            ),
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: config['labelColor'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: config['labelColor'],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isBalanceVisible ? _toggleBalanceVisibility : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.horizontal,
                    axisAlignment: -1.0,
                    child: child,
                  ),
                );
              },
              child: _isBalanceVisible
                  ? FittedBox(
                      key: const ValueKey('visible_balance'),
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyService.format(
                          activeBalance,
                          widget.currencyCode,
                        ),
                        style: TextStyle(
                          color: config['totalBalanceColor'],
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    )
                  : GestureDetector(
                      key: const ValueKey('tap_reveal_bar'),
                      onTap: _revealBalance,
                      child: Container(
                        width: 180,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: config['textColor'].withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: config['textColor'].withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2ECC71),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71).withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.payments_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tap to reveal',
                                style: TextStyle(
                                  color: config['textColor'].withOpacity(0.85),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.only(right: widget.onAddCardTap != null ? 85.0 : 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildBalanceItem(
                  label: 'Income',
                  amount: activeIncome,
                  icon: Icons.arrow_downward_rounded,
                  iconBgColor: const Color(0xFF22C55E).withOpacity(0.2),
                  iconColor: config['incomeColor'],
                  amountColor: config['incomeColor'],
                  config: config,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildBalanceItem(
                  label: 'Expenses',
                  amount: activeExpenses,
                  icon: Icons.arrow_upward_rounded,
                  iconBgColor: const Color(0xFFEF4444).withOpacity(0.2),
                  iconColor: config['expensesColor'],
                  amountColor: config['expensesColor'],
                  config: config,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Color amountColor,
    required Map<String, dynamic> config,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
              child: Icon(icon, size: 10, color: iconColor),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: config['labelColor'],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            CurrencyService.format(amount, widget.currencyCode),
            maxLines: 1,
            style: TextStyle(
              color: amountColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
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

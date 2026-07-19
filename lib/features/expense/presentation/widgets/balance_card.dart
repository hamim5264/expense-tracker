import 'dart:ui';
import 'dart:async';
import 'package:expense_tracker/core/common/utils/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BalanceCard extends StatefulWidget {
  final double totalBalance;
  final double income;
  final double expenses;
  final String currencyCode;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.income,
    required this.expenses,
    required this.currencyCode,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  String _selectedStyle = 'purple';
  bool _isBalanceVisible = false;
  double _dragPosition = 0.0;
  final double _maxDragWidth = 135.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _loadSelectedStyle();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isBalanceVisible) return;
    setState(() {
      _dragPosition += details.delta.dx;
      if (_dragPosition < 0) _dragPosition = 0;
      if (_dragPosition > _maxDragWidth) _dragPosition = _maxDragWidth;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isBalanceVisible) return;
    if (_dragPosition >= _maxDragWidth - 25) {
      _revealBalance();
    } else {
      _resetDrag();
    }
  }

  void _revealBalance() {
    _hideTimer?.cancel();
    setState(() {
      _dragPosition = _maxDragWidth;
      _isBalanceVisible = true;
    });

    _hideTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isBalanceVisible = false;
          _dragPosition = 0.0;
        });
      }
    });
  }

  void _resetDrag() {
    setState(() {
      _dragPosition = 0.0;
    });
  }

  void _toggleBalanceVisibility() {
    if (_isBalanceVisible) {
      _hideTimer?.cancel();
      setState(() {
        _isBalanceVisible = false;
        _dragPosition = 0.0;
      });
    } else {
      _revealBalance();
    }
  }

  Future<void> _loadSelectedStyle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final style = prefs.getString('balance_card_style') ?? 'purple';
      setState(() {
        _selectedStyle = style;
      });
    } catch (_) {}
  }

  Future<void> _saveSelectedStyle(String style) async {
    setState(() {
      _selectedStyle = style;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('balance_card_style', style);
    } catch (_) {}
  }

  Map<String, dynamic> _getStyleConfig(bool isDark) {
    switch (_selectedStyle) {
      case 'glass':
        return {
          'isGlass': true,
          'gradient': null,
          'solidColor': const Color(0xFF1E1B29).withOpacity(0.4),
          'borderColor': Colors.white.withOpacity(0.08),
          'textColor': Colors.white.withOpacity(0.9),
          'labelColor': Colors.white.withOpacity(0.7),
          'totalBalanceColor': widget.totalBalance > 0
              ? const Color(0xFF4ADE80)
              : widget.totalBalance < 0
              ? const Color(0xFFFF6B6B)
              : Colors.white,
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF6B6B),
        };
      case 'emerald':
        return {
          'isGlass': false,
          'gradient': const LinearGradient(
            colors: [Color(0xFF0F9B0F), Color(0xFF006400)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          'textColor': Colors.white,
          'labelColor': Colors.white.withOpacity(0.8),
          'totalBalanceColor': Colors.white,
          'incomeColor': const Color(0xFF4ADE80),
          'expensesColor': const Color(0xFFFF9E9E),
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
          'totalBalanceColor': Colors.white,
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
          'totalBalanceColor': Colors.white,
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
          'totalBalanceColor': widget.totalBalance > 0
              ? const Color(0xFF4ADE80)
              : widget.totalBalance < 0
              ? const Color(0xFFFF6B6B)
              : Colors.white,
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
          'totalBalanceColor': Colors.white,
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
          'totalBalanceColor': widget.totalBalance > 0
              ? const Color(0xFF4ADE80)
              : widget.totalBalance < 0
              ? const Color(0xFFFF6B6B)
              : Colors.white,
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
                    _buildStyleOption('golden', 'Golden', const [
                      Color(0xFFD4AF37),
                      Color(0xFF855B00),
                    ], false),
                    _buildStyleOption('emerald', 'Emerald', const [
                      Color(0xFF0F9B0F),
                      Color(0xFF006400),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final config = _getStyleConfig(isDark);

    if (config['isGlass'] == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: config['solidColor'],
            border: Border.all(color: config['borderColor'], width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _buildCardContent(config, isDark),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: config['gradient'],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: _buildCardContent(config, isDark),
        ),
      );
    }
  }

  Widget _buildCardContent(Map<String, dynamic> config, bool isDark) {
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
                          widget.totalBalance,
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
                  : Container(
                      key: const ValueKey('swipe_bar'),
                      width: 200,
                      height: 40,
                      decoration: BoxDecoration(
                        color: config['textColor'].withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: config['textColor'].withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: (1.0 - (_dragPosition / _maxDragWidth))
                                    .clamp(0.0, 1.0),
                                child: Text(
                                  'Swipe to reveal',
                                  style: TextStyle(
                                    color: config['textColor'].withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: _dragPosition + 4,
                            child: GestureDetector(
                              onHorizontalDragUpdate: _onDragUpdate,
                              onHorizontalDragEnd: _onDragEnd,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: config['totalBalanceColor'],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: config['totalBalanceColor']
                                          .withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.payments_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildBalanceItem(
                label: 'Income',
                amount: widget.income,
                icon: Icons.arrow_downward_rounded,
                iconBgColor: const Color(0xFF22C55E).withOpacity(0.2),
                iconColor: config['incomeColor'],
                amountColor: config['incomeColor'],
                config: config,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBalanceItem(
                label: 'Expenses',
                amount: widget.expenses,
                icon: Icons.arrow_upward_rounded,
                iconBgColor: const Color(0xFFEF4444).withOpacity(0.2),
                iconColor: config['expensesColor'],
                amountColor: config['expensesColor'],
                config: config,
              ),
            ),
          ],
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: config['labelColor'],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  CurrencyService.format(amount, widget.currencyCode),
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

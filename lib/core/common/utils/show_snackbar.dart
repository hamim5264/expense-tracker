import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/core/routing/app_router.dart';

void showToast(
  String message, {
  bool isError = false,
  BuildContext? context,
}) {
  GlassToast.show(message, context: context, isError: isError);
}

void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  GlassToast.show(message, context: context, isError: isError);
}

class GlassToast {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  static void show(
    String message, {
    BuildContext? context,
    bool isError = false,
    Duration duration = const Duration(milliseconds: 2800),
  }) {
    final ctx = context ?? AppRouter.navigatorKey.currentContext;
    if (ctx == null) return;

    OverlayState? overlay;
    try {
      overlay = Overlay.maybeOf(ctx) ?? AppRouter.navigatorKey.currentState?.overlay;
    } catch (_) {
      overlay = AppRouter.navigatorKey.currentState?.overlay;
    }

    if (overlay == null) return;

    _dismissTimer?.cancel();
    if (_currentEntry != null) {
      try {
        _currentEntry!.remove();
      } catch (_) {}
      _currentEntry = null;
    }

    final theme = Theme.of(ctx);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        return _GlassToastWidget(
          message: message,
          isError: isError,
          isDark: isDark,
          primaryColor: primaryColor,
          onDismiss: () {
            _dismissTimer?.cancel();
            try {
              entry.remove();
            } catch (_) {}
            if (_currentEntry == entry) {
              _currentEntry = null;
            }
          },
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, () {
      if (_currentEntry == entry) {
        try {
          entry.remove();
        } catch (_) {}
        _currentEntry = null;
      }
    });
  }
}

class _GlassToastWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isDark;
  final Color primaryColor;
  final VoidCallback onDismiss;

  const _GlassToastWidget({
    required this.message,
    required this.isError,
    required this.isDark,
    required this.primaryColor,
    required this.onDismiss,
  });

  @override
  State<_GlassToastWidget> createState() => _GlassToastWidgetState();
}

class _GlassToastWidgetState extends State<_GlassToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 12;
    final accentColor = widget.isError ? const Color(0xFFFF5252) : widget.primaryColor;
    final icon = widget.isError
        ? CupertinoIcons.exclamationmark_circle_fill
        : CupertinoIcons.checkmark_alt_circle_fill;

    final glassBg = widget.isDark
        ? const Color(0xFF1E1B29).withOpacity(0.88)
        : Colors.white.withOpacity(0.90);

    final borderColor = widget.isError
        ? const Color(0xFFFF5252).withOpacity(0.5)
        : widget.primaryColor.withOpacity(0.4);

    final textColor = widget.isDark ? Colors.white : Colors.black87;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding, left: 24, right: 24),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _dismiss,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: glassBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(widget.isDark ? 0.35 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  height: 1.3,
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
            ),
          ),
        ),
      ),
    );
  }
}

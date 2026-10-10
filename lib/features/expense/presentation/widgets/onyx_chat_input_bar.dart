import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnyxChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final Color primaryColor;
  final bool isLoading;
  final Function(String) onSubmitted;
  final VoidCallback onSettingsTap;

  const OnyxChatInputBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.primaryColor,
    required this.isLoading,
    required this.onSubmitted,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E1B29) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.shade200;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        6,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'AI Engine Settings',
              icon: Icon(
                CupertinoIcons.sparkles,
                size: 20,
                color: primaryColor,
              ),
              onPressed: onSettingsTap,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                onSubmitted: onSubmitted,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: isLoading
                      ? 'Onyx Nova is thinking...'
                      : 'Ask Onyx Nova about your finances...',
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false,
                  fillColor: Colors.transparent,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _AnimatedSendButton(
              isLoading: isLoading,
              primaryColor: primaryColor,
              isDark: isDark,
              onTap: () => onSubmitted(controller.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSendButton extends StatefulWidget {
  final bool isLoading;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onTap;

  const _AnimatedSendButton({
    required this.isLoading,
    required this.primaryColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_AnimatedSendButton> createState() => _AnimatedSendButtonState();
}

class _AnimatedSendButtonState extends State<_AnimatedSendButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AnimatedSendButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isLoading && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: widget.primaryColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.primaryColor.computeLuminance() > 0.45
                ? Colors.black.withOpacity(0.15)
                : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.computeLuminance() > 0.45
                  ? Colors.black.withOpacity(0.08)
                  : widget.primaryColor.withOpacity(0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: Icon(
            Icons.arrow_upward_rounded,
            color: widget.primaryColor.computeLuminance() > 0.45
                ? Colors.black87
                : Colors.white,
            size: 20,
          ),
          onPressed: widget.onTap,
        ),
      );
    }

    // Dynamic, colorful, animated generator state
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              transform: GradientRotation(_controller.value * 2 * math.pi),
              colors: const [
                Color(0xFF8B5CF6), // Royal Purple
                Color(0xFFEC4899), // Neon Pink
                Color(0xFF3B82F6), // Bright Blue
                Color(0xFF10B981), // Emerald
                Color(0xFFF59E0B), // Warm Amber
                Color(0xFF8B5CF6), // Loop back
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.45),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color(0xFFEC4899).withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isDark ? const Color(0xFF181524) : Colors.white,
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -_controller.value * 2 * math.pi * 0.5,
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFFEC4899),
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      CupertinoIcons.sparkles,
                      size: 17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


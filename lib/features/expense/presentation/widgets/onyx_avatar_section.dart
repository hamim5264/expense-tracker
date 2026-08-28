import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnyxAvatarSection extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController speechController;
  final Animation<double> speechScale;
  final Animation<double> speechFade;
  final ValueNotifier<int> greetingIndexNotifier;
  final List<String> botGreetings;
  final Color primaryColor;
  final Color glowAccentColor;
  final bool isDark;

  const OnyxAvatarSection({
    super.key,
    required this.pulseController,
    required this.speechController,
    required this.speechScale,
    required this.speechFade,
    required this.greetingIndexNotifier,
    required this.botGreetings,
    required this.primaryColor,
    required this.glowAccentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 170,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: pulseController,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(
                            0.28 + 0.15 * pulseController.value,
                          ),
                          blurRadius: 28,
                          spreadRadius: 5 + 4 * pulseController.value,
                        ),
                        BoxShadow(
                          color: glowAccentColor.withOpacity(
                            0.22 + 0.12 * pulseController.value,
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
                  errorBuilder: (context, error, stackTrace) {
                    return CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
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
                animation: speechController,
                builder: (context, child) {
                  return Opacity(
                    opacity: speechFade.value,
                    child: Transform.scale(
                      scale: speechScale.value,
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                          bottomLeft: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.2 : 0.05,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: greetingIndexNotifier,
                        builder: (context, greetingIdx, _) {
                          return Text(
                            botGreetings[greetingIdx],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
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
    );
  }
}

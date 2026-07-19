import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/home_page.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:permission_handler/permission_handler.dart';

class SplashPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const SplashPage());

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _rippleController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoScale = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _logoOpacity = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeIn,
    );

    _entranceController.forward();
    _requestPermissionAndCheckAuth();
  }

  Future<void> _requestPermissionAndCheckAuth() async {
    try {
      await Permission.sms.request();
    } catch (_) {}
    _checkAuth();
  }

  bool _isOnline = true;

  Future<void> _checkAuth() async {
    final networkInfo = serviceLocator<NetworkInfo>();
    final connected = await networkInfo.isConnected;
    if (mounted) {
      setState(() => _isOnline = connected);
    }
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFF4F378A);
    final logoAsset = 'assets/images/logos/app_final_splash_logo.png';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(context, HomePage.route());
          } else if (state is AuthInitial) {
            Navigator.pushReplacement(context, LoginPage.route());
          }
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: SplashPainter(
                    _rippleController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
            Center(
              child: FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withAlpha(isDark ? 10 : 20),
                        ),
                        child: Image.asset(logoAsset, width: 180),
                      ),
                      Positioned(
                        bottom: -100,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ONYX',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _isOnline
                                  ? 'Connecting securely...'
                                  : 'Offline mode enabled',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.0,
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
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'powered by',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Image.asset(
                      'assets/images/logos/brand_logo.png',
                      height: 32,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business,
                          color: Colors.white70,
                          size: 28,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'TheDevHamim',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  SplashPainter(this.animationValue, {required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final breathingGlow = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80)
      ..color = const Color(
        0xFF9E82F0,
      ).withAlpha((30 + 20 * math.sin(animationValue * 2 * math.pi)).toInt());
    canvas.drawCircle(center, 120, breathingGlow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withAlpha(isDark ? 15 : 30);

    canvas.drawCircle(center, 140, ringPaint);
    canvas.drawCircle(center, 180, ringPaint);

    final particlePaint = Paint()..style = PaintingStyle.fill;

    const particleCount = 4;
    for (int i = 0; i < particleCount; i++) {
      final double angle = (animationValue * 2 * math.pi) + (i * math.pi / 2);
      final double radius = (i % 2 == 0) ? 140 : 180;
      final double size = (i % 2 == 0) ? 4.0 : 3.0;

      final particleCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final particleGlow = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..color = const Color(0xFF9E82F0).withAlpha(150);
      canvas.drawCircle(particleCenter, size * 2.5, particleGlow);

      particlePaint.color = Colors.white.withAlpha(200);
      canvas.drawCircle(particleCenter, size, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant SplashPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

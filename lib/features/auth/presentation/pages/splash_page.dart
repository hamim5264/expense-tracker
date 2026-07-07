import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/expense/presentation/pages/home_page.dart';
import 'package:expense_tracker/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute(builder: (context) => const SplashPage());

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final session = serviceLocator<SupabaseClient>().auth.currentSession;

    if (session != null) {
      Navigator.pushReplacement(context, HomePage.route());
    } else {
      Navigator.pushReplacement(context, LoginPage.route());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/images/logos/app_logo_white.png'
        : 'assets/images/logos/app_logo.png';

    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Image.asset(logoAsset, width: 250),
          ),
        ),
      ),
    );
  }
}

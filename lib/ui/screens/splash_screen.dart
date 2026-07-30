import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../controllers/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Hardware-accelerated scale pulse
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );

    _animController.repeat(reverse: true);

    // Initialize all services asynchronously while displaying the splash screen
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    // Supabase is already initialised in main() before runApp — skip here.
    // Only initialise Firebase & notification service (they can't run in main).
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      await NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('Firebase / Notification init warning: $e');
    }

    // Enforce smooth minimum splash duration (1.2 seconds) for UX polish
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed < const Duration(milliseconds: 1200)) {
      await Future.delayed(const Duration(milliseconds: 1200) - elapsed);
    }

    if (!mounted) return;
    _animController.stop(); // Stop animation work before page transition

    // Smart Authentication Routing
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        context.go('/main');
        return;
      }
    } catch (_) {}

    context.go('/login');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neuBg,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnim,
          child: SizedBox(
            width: 320,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Dark Shadow Layer
                Transform.translate(
                  offset: const Offset(6, 6),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: SvgPicture.asset(
                      'app_assets/svglogo.svg',
                      width: 240,
                      colorFilter: const ColorFilter.mode(AppTheme.neuShadowDark, BlendMode.srcIn),
                    ),
                  ),
                ),
                // Light Shadow Layer
                Transform.translate(
                  offset: const Offset(-6, -6),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: SvgPicture.asset(
                      'app_assets/svglogo.svg',
                      width: 240,
                      colorFilter: const ColorFilter.mode(AppTheme.neuShadowLight, BlendMode.srcIn),
                    ),
                  ),
                ),
                // Foreground Vector
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppTheme.redAccent, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: SvgPicture.asset(
                    'app_assets/svglogo.svg',
                    width: 240,
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

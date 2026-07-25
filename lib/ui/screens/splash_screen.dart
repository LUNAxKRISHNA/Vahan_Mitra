import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

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

    // Navigate to login quickly, stopping heavy animation first
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _animController.stop(); // CRITICAL: Stop CPU/GPU work before page transition
        context.go('/login');
      }
    });
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
                // Dark Shadow Layer (Static, so Flutter caches the raster layer)
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
                // Light Shadow Layer (Static cacheable layer)
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

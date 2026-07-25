import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  bool _isGoogleBtnPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();
  }

  void _handleGoogleLogin() {
    setState(() => _isLoading = true);
    // Simulate login network delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/main');
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
      body: Stack(
        children: [
          // Background transit graphic with grayscale filter
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: Image.asset(
                'app_assets/transit_mono_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Neumorphic blend overlay
          Positioned.fill(
            child: Container(
              color: AppTheme.neuBg.withValues(alpha: 0.82),
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Optimized static shadow logo with entrance scale animation
                        ScaleTransition(
                          scale: _scaleAnim,
                          child: SizedBox(
                            width: 280,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(4, 4),
                                  child: SvgPicture.asset(
                                    'app_assets/svglogo.svg',
                                    width: 220,
                                    colorFilter: const ColorFilter.mode(AppTheme.neuShadowDark, BlendMode.srcIn),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(-2, -2),
                                  child: SvgPicture.asset(
                                    'app_assets/svglogo.svg',
                                    width: 220,
                                    colorFilter: const ColorFilter.mode(AppTheme.neuShadowLight, BlendMode.srcIn),
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [AppTheme.redAccent, AppTheme.primaryDark],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: SvgPicture.asset(
                                    'app_assets/svglogo.svg',
                                    width: 220,
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your campus transport companion',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),

                    // Neumorphic Google Login Button
                    GestureDetector(
                      onTapDown:
                          (_) => setState(() => _isGoogleBtnPressed = true),
                      onTapUp: (_) {
                        setState(() => _isGoogleBtnPressed = false);
                        if (!_isLoading) _handleGoogleLogin();
                      },
                      onTapCancel:
                          () => setState(() => _isGoogleBtnPressed = false),
                      child: AnimatedScale(
                        scale: _isGoogleBtnPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.easeOut,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: AppTheme.neuBoxDecoration(
                            radius: 30,
                            inset: _isGoogleBtnPressed,
                          ),
                          child:
                              _isLoading
                                  ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.redAccent,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Simulated Google Icon
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          ' G ',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Footers
                    Text(
                      'Made by School of STEM',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Managed by Transport department',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}

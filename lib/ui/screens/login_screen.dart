import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../controllers/auth_service.dart';
import '../components/route_background_painter.dart';

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

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await AuthService.instance.signInWithGoogle();
      if (mounted) {
        setState(() => _isLoading = false);
        if (response != null) {
          context.go('/main');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: AppTheme.redAccent,
          ),
        );
      }
    }
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
        fit: StackFit.expand,
        children: [
          Image.asset(
            'app_assets/backdrop.png',
            fit: BoxFit.cover,
          ),
          // Optional semi-transparent overlay to ensure content is readable
          Container(
            color: AppTheme.neuBg.withValues(alpha: 0.8),
          ),
          SubtleRouteBackground(
            child: SafeArea(
              child: LayoutBuilder(
              builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),
                child: IntrinsicHeight(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          const Spacer(flex: 1),

                          // ── Exact Splash Screen Logo with Neumorphic Shadows & Gradient ─
                          ScaleTransition(
                            scale: _scaleAnim,
                            child: SizedBox(
                              width: 280,
                              height: 160,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 1. Soft Black Ambient Glow/Shadow (Deep spread)
                                  Transform.translate(
                                    offset: const Offset(0, 10),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 18,
                                        sigmaY: 18,
                                      ),
                                      child: SvgPicture.asset(
                                        'app_assets/svglogo.svg',
                                        width: 230,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.12),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 2. Sharp Black Drop Shadow
                                  Transform.translate(
                                    offset: const Offset(6, 6),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: SvgPicture.asset(
                                        'app_assets/svglogo.svg',
                                        width: 230,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.18),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 3. Tight Black Contour Shadow
                                  Transform.translate(
                                    offset: const Offset(3, 3),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 4,
                                        sigmaY: 4,
                                      ),
                                      child: SvgPicture.asset(
                                        'app_assets/svglogo.svg',
                                        width: 230,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black.withValues(alpha: 0.22),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 4. Soft White Top-Left Highlight
                                  Transform.translate(
                                    offset: const Offset(-4, -4),
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                        sigmaX: 10,
                                        sigmaY: 10,
                                      ),
                                      child: SvgPicture.asset(
                                        'app_assets/svglogo.svg',
                                        width: 230,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withValues(alpha: 0.45),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 4. Foreground Gradient Vector
                                  ShaderMask(
                                    shaderCallback:
                                        (bounds) => const LinearGradient(
                                          colors: [
                                            AppTheme.redAccent,
                                            AppTheme.primaryDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                    child: SvgPicture.asset(
                                      'app_assets/svglogo.svg',
                                      width: 230,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(flex: 2),

                          // ── Centered Neumorphic Sign-In Card (Bottom Positioned) ─
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 22,
                              ),
                              decoration: AppTheme.neuBoxDecoration(
                                radius: 24,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Header Title
                                  Text(
                                    'Sign In',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Continue with your university account to access live bus tracking.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Google Sign-In Button with Authentic 4-Color G Logo
                                  GestureDetector(
                                    onTapDown:
                                        (_) => setState(
                                          () => _isGoogleBtnPressed = true,
                                        ),
                                    onTapUp: (_) {
                                      setState(
                                        () => _isGoogleBtnPressed = false,
                                      );
                                      if (!_isLoading) _handleGoogleLogin();
                                    },
                                    onTapCancel:
                                        () => setState(
                                          () => _isGoogleBtnPressed = false,
                                        ),
                                    child: AnimatedScale(
                                      scale: _isGoogleBtnPressed ? 0.96 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 100,
                                      ),
                                      curve: Curves.easeOut,
                                      child: Container(
                                        width: double.infinity,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: AppTheme.neuBoxDecoration(
                                          radius: 20,
                                          inset: _isGoogleBtnPressed,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (_isLoading)
                                              Positioned.fill(
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: TweenAnimationBuilder<double>(
                                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                                    duration: const Duration(seconds: 2),
                                                    builder: (context, value, child) {
                                                      return FractionallySizedBox(
                                                        alignment: Alignment.centerLeft,
                                                        widthFactor: value,
                                                        child: Container(
                                                          color: AppTheme.redAccent.withValues(alpha: 0.15),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 13),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const _RealGoogleGLogo(),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    _isLoading ? 'Signing in...' : 'Continue with Google',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textPrimary,
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
                                  const SizedBox(height: 16),

                                  Divider(
                                    color: Colors.grey.withValues(
                                      alpha: 0.15,
                                    ),
                                    height: 1,
                                  ),
                                  const SizedBox(height: 14),

                                  // Security Notice Row (Centered)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: AppTheme.neuBoxDecoration(
                                          radius: 50,
                                          inset: true,
                                        ),
                                        child: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 14,
                                          color: AppTheme.redAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Only authorized students and faculty can access the application.',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppTheme.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Centered Footers ───────────────────────────────────────
                          Text(
                            'Managed by Transportation Department',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Made by School of STEM',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
        ],
      ),
    );
  }
}

// ── Official 4-Color Google G Logo Widget ──────────────────────────────────

class _RealGoogleGLogo extends StatelessWidget {
  const _RealGoogleGLogo();

  static const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.66 0 6.58 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.28-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.58 42.62 14.66 48 24 48z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: SvgPicture.string(_googleSvg, width: 18, height: 18),
    );
  }
}

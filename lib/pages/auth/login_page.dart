import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/wave_clipper.dart';
//==============================================================

class LoginPage extends StatefulWidget {
  // ignore: use_super_parameters
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final Color primaryColor = const Color(0xFF0D47A1); // A deep blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 350,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          // CHANGED: Text color to white for contrast on the gradient
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your Vahan Mitra account',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildInputDecoration(
                        label: 'Email',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.black87),
                      decoration: _buildInputDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade700, primaryColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (_) => const HomePage()),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.black54, size: 20),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }
}
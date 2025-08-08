import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:google_fonts/google_fonts.dart';

//==============================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  // --- 1. Create FocusNodes to track focus state ---
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // --- 2. Add listeners to rebuild the UI on focus change ---
    _emailFocusNode.addListener(() {
      setState(() {}); // Re-render
    });
    _passwordFocusNode.addListener(() {
      setState(() {}); // Re-render
    });
  }

  @override
  void dispose() {
    // --- 3. Clean up the focus nodes when the widget is disposed ---
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // --- Row for Title and Logo ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 55.0, // Adjust height as needed
                      width: 55.0,  // Adjust width as needed
                    ),
                    const SizedBox(width: 12), // Spacing between logo and text
                    Text(
                      'Vahan Mitra',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Color(0xfFE0E0E0),
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lobster(
                    color: Color(0xFFE0E0E0),
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFE0E0E0), fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- Email Text Field ---
                TextField(
                  focusNode: _emailFocusNode, // Assign focus node
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF1A1A1A)),
                  decoration: _buildInputDecoration(
                    label: 'Email',
                    icon: Icons.email_outlined,
                    isFocused: _emailFocusNode.hasFocus,
                  ),
                ),
                const SizedBox(height: 20),

                // --- Password Text Field ---
                TextField(
                  focusNode: _passwordFocusNode, // Assign focus node
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Color(0xFF1A1A1A)),
                  decoration: _buildInputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isFocused: _passwordFocusNode.hasFocus,
                    isPassword: true,
                  ),
                ),
                const SizedBox(height: 50),

                // --- Login Button ---
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6EDED),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff1a202c),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper method to build InputDecoration to avoid repetition ---
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData icon,
    required bool isFocused,
    bool isPassword = false,
  }) {
    return InputDecoration(
      // --- This is the key change ---
      // Show labelText when not focused, and hintText when focused.
      labelText: isFocused ? null : label,
      labelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
      hintText: isFocused ? label : '',
      hintStyle: const TextStyle(color: Color(0xFF1A1A1A)),

      prefixIcon: Icon(icon, color: Color(0xFF1A1A1A)),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Color(0xFF1A1A1A),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
      filled: true,
      fillColor: Colors.white, 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }
}

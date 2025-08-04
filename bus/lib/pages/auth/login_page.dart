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
      backgroundColor: const Color.fromARGB(255, 61, 65, 38),
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
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12), // Spacing between text and logo
                    // --- Add your logo here ---
                    // Make sure you have 'logo.png' in your 'assets' folder
                    // and have declared it in pubspec.yaml
                    
                  ],
                ),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // --- Email Text Field ---
                TextField(
                  focusNode: _emailFocusNode, // Assign focus node
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
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
                  style: const TextStyle(color: Colors.white),
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
                    backgroundColor: const Color.fromARGB(255, 246, 237, 222),
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
      labelStyle: const TextStyle(color: Colors.white70),
      hintText: isFocused ? label : '',
      hintStyle: const TextStyle(color: Colors.white70),

      prefixIcon: Icon(icon, color: Colors.white70),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.white70,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            )
          : null,
      
      // Consistent styling for both text fields
      filled: true,
      // --- CORRECTED --- Increased opacity for better visibility
      fillColor: Colors.white.withOpacity(0.2), 
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      // Remove the floating label's space when it's not visible
      floatingLabelBehavior: FloatingLabelBehavior.never,
    );
  }
}

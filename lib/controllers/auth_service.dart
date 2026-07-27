import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _defaultWebClientId =
      '195240791425-edt1eq7i1imr5qcs5f0pp1kqh7556nfd.apps.googleusercontent.com';

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      final String envClientId = const String.fromEnvironment(
        'GOOGLE_WEB_CLIENT_ID',
        defaultValue: '',
      );
      final String clientId = (envClientId.isNotEmpty && !envClientId.contains('googleclientid'))
          ? envClientId
          : _defaultWebClientId;

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: clientId,
        hostedDomain: 'cvv.ac.in',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in process
        return null;
      }

      // Domain restriction check: Enforce @cvv.ac.in emails only
      if (!googleUser.email.toLowerCase().endsWith('@cvv.ac.in')) {
        await googleSignIn.signOut();
        throw 'Access Restricted: Only @cvv.ac.in university accounts are allowed to sign in.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google Sign-In failed: No ID Token retrieved.';
      }

      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('Google Sign-In Successful for user: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await Supabase.instance.client.auth.signOut();
  }
}

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yoauto_api/yoauto_api.dart';

enum AuthStep { idle, emailSent, loggedIn }

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider(this.authService);

  AuthUser? _user;
  AuthStep _step = AuthStep.idle;
  bool _isLoading = false;
  String? _error;

  AuthUser? get user => _user;
  AuthStep get step => _step;
  bool get isLoggedIn => _step == AuthStep.loggedIn;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Step 1: sends magic link email
  Future<bool> requestMagicLink(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await authService.requestMagicLink(email);
      _step = AuthStep.emailSent;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Step 2: verifies token from email link
  Future<bool> verifyMagicLink(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final loginResponse = await authService.verifyMagicLink(token);
      _user = loginResponse.user;
      _step = AuthStep.loggedIn;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google. Requires GOOGLE_CLIENT_ID configured in the Google
  /// Cloud Console and added to your Android/iOS native project files.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '967817877584-6s83sp3si583lcc9442qa0lib0g5ci6t.apps.googleusercontent.com',
        scopes: ['email'],
      );
      final account = await googleSignIn.signIn();
      if (account == null) {
        // User cancelled
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final auth = await account.authentication;
      final serverAuthCode = account.serverAuthCode ?? auth.idToken;
      if (serverAuthCode == null) {
        _error = 'Google sign-in did not return an auth code or ID token.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final loginResponse = await authService.loginWithGoogle(
        serverAuthCode,
        '', // redirect_uri — set to your Google Cloud redirect URI if required
      );
      _user = loginResponse.user;
      _step = AuthStep.loggedIn;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _user = null;
    _step = AuthStep.idle;
    notifyListeners();
  }
}

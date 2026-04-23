import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../config/firebase_config.dart';
import '../services/firebase_service.dart';
import '../models/user.dart' as app_model;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final RegExp _emailPattern =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isCompletingAuth = false;
  bool _obscurePassword = true;
  String? _error;
  StreamSubscription<fb_auth.User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    if (!FirebaseConfig.isReady) return;

    _authSubscription = FirebaseService.instance.authStateChanges.listen((user) {
      if (user != null) {
        _handleAuthComplete();
      }
    });
  }

  Future<void> _handleAuthComplete() async {
    if (!mounted || _isCompletingAuth) return;
    _isCompletingAuth = true;

    final service = FirebaseService.instance;
    final user = service.currentUser;
    if (user == null) {
      _isCompletingAuth = false;
      return;
    }

    setState(() => _isLoading = true);

    try {
      var profile = await service.loadCurrentProfile();

      if (profile == null) {
        final newProfile = app_model.User(
          id: user.uid,
          name: user.displayName ??
              user.email?.split('@').first ??
              'Student',
          email: user.email ?? '',
          avatarUrl: user.photoURL ?? '',
          college: '',
          branch: '',
          semester: '',
        );
        await service.upsertUserProfile(newProfile);
        profile = await service.loadCurrentProfile();
      }

      if (!mounted) return;

      if (profile == null || profile.college.isEmpty) {
        Navigator.pushReplacementNamed(context, '/college-setup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyAuthError(e));
    } finally {
      _isCompletingAuth = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    if (_isSignUp && _nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your name');
      return;
    }
    if (!FirebaseConfig.isReady) {
      setState(() => _error = _configurationErrorMessage());
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final service = FirebaseService.instance;
      if (_isSignUp) {
        final credential = await service.signUpWithEmail(
          email: email,
          password: password,
          name: _nameController.text.trim(),
        );
        if (!mounted) return;
        if (credential.user != null) {
          final user = app_model.User(
            id: credential.user!.uid,
            name: _nameController.text.trim(),
            email: email,
            college: '',
            branch: '',
            semester: '',
          );
          await service.upsertUserProfile(user);
          await service.loadCurrentProfile();
          if (mounted) Navigator.pushReplacementNamed(context, '/college-setup');
        } else {
          if (mounted) setState(() => _error = 'Sign-up failed. Try again.');
        }
      } else {
        await service.signInWithEmail(email, password);
        if (!mounted) return;
        final profile = service.currentProfile;
        if (profile == null || profile.college.isEmpty) {
          if (mounted) Navigator.pushReplacementNamed(context, '/college-setup');
        } else {
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter your email first, then tap Forgot password');
      return;
    }
    if (!FirebaseConfig.isReady) {
      setState(() => _error = _configurationErrorMessage());
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      await FirebaseService.instance.resetPassword(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyAuthError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleAuth() async {
    if (!FirebaseConfig.isReady) {
      setState(() => _error = _configurationErrorMessage());
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = FirebaseService.instance;
      final credential = await service.signInWithGoogle();

      if (credential == null) {
        // User cancelled Google sign-in
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      // Auth state listener will handle navigation,
      // but if it doesn't fire (already signed in), handle directly
      if (credential.user != null && mounted) {
        await _handleAuthComplete();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = _friendlyAuthError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildAuthCard(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF136DEC),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF136DEC).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.share, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Share knowledge with\nyour college',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join thousands of students sharing notes\nand studying together',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Lexend',
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (_isSignUp) ...[
            _buildInput(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 12),
          ],
          _buildInput(_emailController, 'Email', Icons.email_outlined),
          const SizedBox(height: 12),
          _buildInput(_passwordController, 'Password', Icons.lock_outline, obscure: true),
          if (!_isSignUp)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isLoading ? null : _handleForgotPassword,
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF136DEC)),
                ),
              ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Lexend'),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF136DEC),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isSignUp ? 'Create Account' : 'Sign In',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Lexend'),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildGoogleButton(context),
          const SizedBox(height: 20),
          _buildToggleRow(),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure && _obscurePassword,
      keyboardType: hint == 'Email' ? TextInputType.emailAddress : TextInputType.text,
      textInputAction: obscure ? TextInputAction.done : TextInputAction.next,
      autofillHints: hint == 'Email'
          ? const [AutofillHints.email]
          : obscure
              ? const [AutofillHints.password]
              : const [AutofillHints.name],
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontFamily: 'Lexend', color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF136DEC), width: 2),
        ),
        suffixIcon: obscure
            ? IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[500],
                ),
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onSubmitted: obscure ? (_) => _handleEmailAuth() : null,
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleAuth,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF136DEC)),
        label: const Text(
          'Continue with Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Lexend', color: Color(0xFF1A1A1A)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[200])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: TextStyle(fontSize: 14, fontFamily: 'Lexend', color: Colors.grey[500])),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[200])),
      ],
    );
  }

  Widget _buildToggleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
          style: TextStyle(fontSize: 14, fontFamily: 'Lexend', color: Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _isSignUp = !_isSignUp;
            _error = null;
          }),
          child: Text(
            _isSignUp ? 'Sign In' : 'Create Account',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Lexend', color: Color(0xFF136DEC)),
          ),
        ),
      ],
    );
  }

  String _friendlyAuthError(Object error) {
    final raw = error.toString().replaceAll('Exception: ', '');
    final lower = raw.toLowerCase();
    if (lower.contains('invalid-credential') || lower.contains('wrong-password') || lower.contains('user-not-found')) {
      return 'Incorrect email or password';
    }
    if (lower.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    }
    if (lower.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters';
    }
    if (lower.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Network error. Check your connection and try again';
    }
    if (lower.contains('invalid-email')) {
      return 'Please enter a valid email address';
    }
    return raw;
  }

  String _configurationErrorMessage() {
    final initError = FirebaseConfig.initializationError;
    if (initError == null || initError.isEmpty) {
      return 'Firebase is not ready. Ensure google-services.json is configured.';
    }
    return 'Firebase initialization failed. Check configuration.\n$initError';
  }
}

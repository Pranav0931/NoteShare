import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/supabase_service.dart';
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
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    if (!SupabaseConfig.isConfigured) return;

    _authSubscription = SupabaseService.instance.authStateChanges.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _handleAuthComplete();
      }
    });
  }

  Future<void> _handleAuthComplete() async {
    if (!mounted || _isCompletingAuth) return;
    _isCompletingAuth = true;

    final service = SupabaseService.instance;
    final user = service.currentUser;
    if (user == null) {
      _isCompletingAuth = false;
      return;
    }

    setState(() => _isLoading = true);

    try {
      var profile = await service.loadCurrentProfile();

      if (profile == null) {
        final metadata = user.userMetadata;
        final newProfile = app_model.User(
          id: user.id,
          name: _metadataString(metadata, 'full_name') ??
              _metadataString(metadata, 'name') ??
              user.email?.split('@').first ??
              'Student',
          email: user.email ?? '',
          avatarUrl: _metadataString(metadata, 'avatar_url') ??
              _metadataString(metadata, 'picture') ??
              '',
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
    if (!SupabaseConfig.isConfigured) {
      setState(() => _error = 'App configuration is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final service = SupabaseService.instance;
      if (_isSignUp) {
        final response = await service.signUpWithEmail(
          email: email,
          password: password,
          name: _nameController.text.trim(),
        );
        if (!mounted) return;
        if (response.user != null) {
          final user = app_model.User(
            id: response.user!.id,
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
      setState(() => _error = _friendlyAuthError(e));
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
    if (!SupabaseConfig.isConfigured) {
      setState(() => _error = 'App configuration is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    try {
      await SupabaseService.instance.resetPassword(email);
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
    if (!SupabaseConfig.isConfigured) {
      setState(() => _error = 'App configuration is missing. Set SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = SupabaseService.instance;
      final initiated = await service.signInWithGoogle();

      if (!initiated) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Could not start Google sign-in. Please try again.';
          });
        }
      }
      // If initiated, the auth state listener (_setupAuthListener) will handle
      // the redirect callback and complete the login flow.
      // Keep loading state while waiting for redirect.
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
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 24, height: 24,
          errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 24, color: Color(0xFF136DEC)),
        ),
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
    if (lower.contains('invalid login credentials')) {
      return 'Incorrect email or password';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please confirm your email before signing in';
    }
    if (lower.contains('already registered') || lower.contains('user already registered')) {
      return 'An account with this email already exists';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'Network error. Check your connection and try again';
    }
    return raw;
  }

  String? _metadataString(Map<String, dynamic>? metadata, String key) {
    final value = metadata?[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }
}

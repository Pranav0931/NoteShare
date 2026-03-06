import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),
              _buildHeader(),
              const Spacer(flex: 1),
              _buildLoginCard(context),
              const Spacer(flex: 2),
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
            child: Icon(
              Icons.share,
              size: 40,
              color: Colors.white,
            ),
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

  Widget _buildLoginCard(BuildContext context) {
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
          _buildGoogleButton(context),
          const SizedBox(height: 16),
          _buildEmailButton(context),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 24),
          _buildCreateAccountRow(context),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          // Handle Google sign in
          Navigator.pushReplacementNamed(context, '/home');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.g_mobiledata,
            size: 24,
            color: Color(0xFF136DEC),
          ),
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF136DEC),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.email_outlined, size: 22),
        label: const Text(
          'Sign in with Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lexend',
            color: Colors.grey[600],
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to signup
            Navigator.pushReplacementNamed(context, '/home');
          },
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
              color: Color(0xFF136DEC),
            ),
          ),
        ),
      ],
    );
  }
}

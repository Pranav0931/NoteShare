import 'package:flutter/material.dart';
import '../config/college_config.dart';
import '../services/firebase_service.dart';

class CollegeSetupScreen extends StatefulWidget {
  const CollegeSetupScreen({super.key});

  @override
  State<CollegeSetupScreen> createState() => _CollegeSetupScreenState();
}

class _CollegeSetupScreenState extends State<CollegeSetupScreen> {
  String? _selectedCollege;
  String? _selectedBranch;
  String? _selectedSemester;
  bool _isLoading = false;
  String? _error;

  final _colleges = CollegeConfig.colleges.map((c) => c['name']!).toList();

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
              const SizedBox(height: 40),
              _buildForm(),
              const Spacer(flex: 1),
              _buildContinueButton(),
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
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF136DEC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.school,
            size: 32,
            color: Color(0xFF136DEC),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Set Up Your Profile',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your college, branch and semester\nto get personalized notes',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Lexend',
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildDropdown(
          label: 'College',
          value: _selectedCollege,
          items: _colleges,
          icon: Icons.account_balance,
          onChanged: (v) => setState(() => _selectedCollege = v),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Branch',
          value: _selectedBranch,
          items: CollegeConfig.branches,
          icon: Icons.category,
          onChanged: (v) => setState(() => _selectedBranch = v),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Semester',
          value: _selectedSemester,
          items: CollegeConfig.semesters,
          icon: Icons.calendar_today,
          onChanged: (v) => setState(() => _selectedSemester = v),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF136DEC)),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  'Select $label',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 15,
                    color: Colors.grey[400],
                  ),
                ),
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final isComplete = _selectedCollege != null &&
        _selectedBranch != null &&
        _selectedSemester != null;

    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13, fontFamily: 'Lexend'),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isComplete && !_isLoading ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF136DEC),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Lexend',
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _onContinue() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = FirebaseService.instance;
      final user = service.currentUser;
      if (user != null) {
        // Find the college ID from the name
        final collegeEntry = CollegeConfig.colleges.firstWhere(
          (c) => c['name'] == _selectedCollege,
          orElse: () => CollegeConfig.colleges.first,
        );
        await service.updateUserCollege(
          userId: user.uid,
          college: collegeEntry['id']!,
          branch: _selectedBranch!,
          semester: _selectedSemester!,
        );
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = 'Failed to save: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

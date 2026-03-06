import 'package:flutter/material.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedSubject;
  String? _selectedSemester;
  String? _selectedBranch;
  bool _fileSelected = false;
  String _selectedFileName = '';

  final List<String> _subjects = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Electronics',
    'Mechanical',
  ];

  final List<String> _semesters = [
    '1st Sem',
    '2nd Sem',
    '3rd Sem',
    '4th Sem',
    '5th Sem',
    '6th Sem',
    '7th Sem',
    '8th Sem',
  ];

  final List<String> _branches = [
    'CSE',
    'ECE',
    'ME',
    'CE',
    'EE',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUploadSection(),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter notes title',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Subject',
                        value: _selectedSubject,
                        items: _subjects,
                        onChanged: (value) => setState(() => _selectedSubject = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Semester',
                              value: _selectedSemester,
                              items: _semesters,
                              onChanged: (value) => setState(() => _selectedSemester = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Branch',
                              value: _selectedBranch,
                              items: _branches,
                              onChanged: (value) => setState(() => _selectedBranch = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Describe your notes...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      _buildPublishButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Upload Notes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lexend',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return GestureDetector(
      onTap: _selectFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF136DEC).withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF136DEC).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _fileSelected ? Icons.description : Icons.cloud_upload_outlined,
                size: 40,
                color: const Color(0xFF136DEC),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fileSelected ? _selectedFileName : 'Drag or browse file',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
                color: _fileSelected ? const Color(0xFF136DEC) : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _fileSelected 
                  ? 'Tap to change file' 
                  : 'PDF, DOC, DOCX up to 10MB',
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Lexend',
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFile() {
    // Simulating file selection
    setState(() {
      _fileSelected = true;
      _selectedFileName = 'DSA_Notes_Chapter1.pdf';
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.white,
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
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                'Select $label',
                style: TextStyle(
                  fontFamily: 'Lexend',
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
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _publishNotes,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF136DEC),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Publish Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
          ),
        ),
      ),
    );
  }

  void _publishNotes() {
    if (_formKey.currentState!.validate()) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes Published!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your notes have been uploaded successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Color(0xFF136DEC),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

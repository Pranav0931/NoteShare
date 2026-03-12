import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../config/college_config.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';

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
  String? _selectedFileType;
  String? _selectedCategory;
  bool _fileSelected = false;
  String _selectedFileName = '';
  Uint8List? _fileBytes;
  bool _isUploading = false;

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
                        items: CollegeConfig.subjects,
                        onChanged: (value) => setState(() => _selectedSubject = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'Semester',
                              value: _selectedSemester,
                              items: CollegeConfig.semesters,
                              onChanged: (value) => setState(() => _selectedSemester = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Branch',
                              value: _selectedBranch,
                              items: CollegeConfig.branches,
                              onChanged: (value) => setState(() => _selectedBranch = value),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: 'File Type',
                              value: _selectedFileType,
                              items: CollegeConfig.noteFileTypes,
                              onChanged: (value) => setState(() => _selectedFileType = value),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdown(
                              label: 'Category',
                              value: _selectedCategory,
                              items: CollegeConfig.noteCategories,
                              onChanged: (value) => setState(() => _selectedCategory = value),
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
                  : 'PDF, Images, DOC, DOCX up to 10MB',
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

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        withData: true,
      );
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _fileSelected = true;
          _selectedFileName = result.files.single.name;
          _fileBytes = result.files.single.bytes!;

          // Auto-detect file type from extension
          final ext = p.extension(_selectedFileName).toLowerCase();
          if (ext == '.pdf') {
            _selectedFileType = 'PDF';
          } else if (['.jpg', '.jpeg', '.png'].contains(ext)) {
            _selectedFileType = 'Image';
          } else {
            _selectedFileType = 'Document';
          }
        });
      }
    } catch (_) {}
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
        onPressed: _isUploading ? null : _publishNotes,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF136DEC),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isUploading
            ? const SizedBox(
                width: 24, height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text(
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

  Future<void> _publishNotes() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_fileSelected || _fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final service = SupabaseService.instance;
      final user = service.currentUser;
      final profile = service.currentProfile;
      if (user == null || profile == null) throw Exception('Not logged in');

      // Upload file to storage
      final ext = p.extension(_selectedFileName).toLowerCase();
      final storagePath = '${profile.college}/${user.id}/${DateTime.now().millisecondsSinceEpoch}$ext';
      final contentType = ext == '.pdf'
          ? 'application/pdf'
          : ['.jpg', '.jpeg', '.png'].contains(ext)
              ? 'image/${ext.replaceAll('.', '')}'
              : 'application/octet-stream';

      final fileUrl = await service.uploadFile(storagePath, _fileBytes!, contentType);

      // Map UI strings to enums
      final fileType = _selectedFileType == 'PDF'
          ? NoteFileType.pdf
          : _selectedFileType == 'Image'
              ? NoteFileType.image
              : NoteFileType.document;
      final category = _selectedCategory == 'Short Notes'
          ? NoteCategory.shortNotes
          : _selectedCategory == 'Important Questions'
              ? NoteCategory.importantQuestions
              : _selectedCategory == 'Previous Year Papers'
                  ? NoteCategory.previousYearPapers
                  : NoteCategory.regular;

      final note = Note(
        id: '', // Generated by Supabase
        title: _titleController.text.trim(),
        subject: _selectedSubject ?? '',
        semester: _selectedSemester ?? '',
        branch: _selectedBranch ?? profile.branch,
        college: profile.college,
        description: _descriptionController.text.trim(),
        uploaderId: user.id,
        uploaderName: profile.name,
        uploaderAvatar: profile.avatarUrl,
        uploaderBranch: profile.branch,
        uploaderSemester: profile.semester,
        fileUrl: fileUrl,
        fileType: fileType,
        status: NoteStatus.pending,
        category: category,
        uploadDate: DateTime.now(),
      );

      await service.uploadNote(note);

      if (!mounted) return;
      setState(() => _isUploading = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Notes Submitted!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
              const SizedBox(height: 8),
              Text(
                'Your notes are pending review.\nThey will appear in the feed once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Lexend', color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text('Done', style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF136DEC))),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    }
  }
}

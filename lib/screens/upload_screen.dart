import 'package:flutter/material.dart';
import '../config/college_config.dart';
import '../models/note.dart';
import '../services/firebase_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  String? _selectedSubject;
  String? _selectedSemester;
  String? _selectedBranch;
  String? _selectedFileType;
  String? _selectedCategory;
  String _selectedLinkType = 'Google Drive';
  bool _isUploading = false;

  static const List<Map<String, dynamic>> _linkTypes = [
    {'name': 'Google Drive', 'icon': Icons.drive_file_move_outlined, 'color': Color(0xFF4285F4)},
    {'name': 'Dropbox', 'icon': Icons.cloud_outlined, 'color': Color(0xFF0061FF)},
    {'name': 'Direct URL', 'icon': Icons.link, 'color': Color(0xFF136DEC)},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
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
                      _buildLinkSection(),
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
              'Share Notes',
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

  // ─── Link Input Section ────────────────────────────────────────

  Widget _buildLinkSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF136DEC).withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF136DEC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.link,
                  size: 22,
                  color: Color(0xFF136DEC),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add File Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Share via Google Drive, Dropbox, or direct URL',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Link type selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _linkTypes.map((type) {
                final isSelected = _selectedLinkType == type['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLinkType = type['name'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (type['color'] as Color).withOpacity(0.1)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? (type['color'] as Color).withOpacity(0.4)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? type['color'] as Color
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type['name'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontFamily: 'Lexend',
                              color: isSelected
                                  ? type['color'] as Color
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Link input field
          TextFormField(
            controller: _linkController,
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a file link';
              }
              final uri = Uri.tryParse(value.trim());
              if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                return 'Please enter a valid URL (e.g. https://...)';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: _getLinkHint(),
              hintStyle: TextStyle(
                fontFamily: 'Lexend',
                color: Colors.grey[400],
                fontSize: 13,
              ),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              prefixIcon: Icon(
                Icons.link,
                color: Colors.grey[400],
                size: 20,
              ),
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),

          // Hint text
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _getLinkTip(),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Lexend',
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLinkHint() {
    switch (_selectedLinkType) {
      case 'Google Drive':
        return 'https://drive.google.com/file/d/...';
      case 'Dropbox':
        return 'https://www.dropbox.com/s/...';
      default:
        return 'https://example.com/notes.pdf';
    }
  }

  String _getLinkTip() {
    switch (_selectedLinkType) {
      case 'Google Drive':
        return 'Make sure the file sharing is set to "Anyone with the link"';
      case 'Dropbox':
        return 'Use a shared link — change ?dl=0 to ?dl=1 for direct download';
      default:
        return 'Paste any publicly accessible URL to your file';
    }
  }

  // ─── Shared Form Widgets ───────────────────────────────────────

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

  // ─── Publish Logic ─────────────────────────────────────────────

  Future<void> _publishNotes() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubject == null ||
        _selectedSemester == null ||
        _selectedBranch == null ||
        _selectedFileType == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all note details')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final service = FirebaseService.instance;
      final user = service.currentUser;
      final profile = service.currentProfile;
      if (user == null || profile == null) throw Exception('Not logged in');

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
        id: '', // Generated by Firestore
        title: _titleController.text.trim(),
        subject: _selectedSubject ?? '',
        semester: _selectedSemester ?? '',
        branch: _selectedBranch ?? profile.branch,
        college: profile.college,
        description: _descriptionController.text.trim(),
        uploaderId: user.uid,
        uploaderName: profile.name,
        uploaderAvatar: profile.avatarUrl,
        uploaderBranch: profile.branch,
        uploaderSemester: profile.semester,
        fileUrl: _linkController.text.trim(),
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

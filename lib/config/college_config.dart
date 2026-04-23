/// College configuration for single-college launch.
/// Structured to support future multi-college expansion.
class CollegeConfig {
  static const String defaultCollegeId = 'rcoem';
  static const String defaultCollegeName = 'RCOEM, Nagpur';

  static const List<Map<String, String>> colleges = [
    {'id': 'rcoem', 'name': 'RCOEM, Nagpur'},
    // Future colleges can be added here
  ];

  /// Get college name from ID. Returns default name if not found.
  static String getCollegeName(String? collegeId) {
    if (collegeId == null || collegeId.isEmpty) return defaultCollegeName;
    final college = colleges.firstWhere(
      (c) => c['id'] == collegeId,
      orElse: () => {'name': defaultCollegeName},
    );
    return college['name'] ?? defaultCollegeName;
  }

  static const List<String> branches = [
    'CSE',
    'ECE',
    'ME',
    'CE',
    'EE',
    'IT',
  ];

  static const List<String> semesters = [
    '1st Sem',
    '2nd Sem',
    '3rd Sem',
    '4th Sem',
    '5th Sem',
    '6th Sem',
    '7th Sem',
    '8th Sem',
  ];

  static const List<String> subjects = [
    'Computer Science',
    'Mathematics',
    'Physics',
    'Electronics',
    'Mechanical',
    'Data Structures',
    'Operating Systems',
    'Database Management',
    'Computer Networks',
    'Software Engineering',
    'Digital Electronics',
    'Signals & Systems',
    'Engineering Drawing',
    'Thermodynamics',
    'Strength of Materials',
    'Chemistry',
    'English',
  ];

  static const List<String> noteFileTypes = [
    'PDF',
    'Image',
    'Document',
  ];

  static const List<String> noteCategories = [
    'Regular Notes',
    'Short Notes',
    'Important Questions',
    'Previous Year Papers',
  ];
}

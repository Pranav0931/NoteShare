import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSubject;
  String? _selectedSemester;
  String? _selectedBranch;

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

  // Sample search results
  final List<Note> _searchResults = [
    Note(
      id: '1',
      title: 'Data Structures and Algorithms Complete Notes',
      subject: 'Computer Science',
      semester: '3rd Sem',
      branch: 'CSE',
      uploaderName: 'Rahul Sharma',
      rating: 4.8,
      downloadCount: 234,
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Object Oriented Programming - Java',
      subject: 'Computer Science',
      semester: '3rd Sem',
      branch: 'CSE',
      uploaderName: 'Priya Patel',
      rating: 4.6,
      downloadCount: 198,
      uploadDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Note(
      id: '3',
      title: 'Database Management Systems',
      subject: 'Computer Science',
      semester: '4th Sem',
      branch: 'CSE',
      uploaderName: 'Amit Kumar',
      rating: 4.7,
      downloadCount: 267,
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildSearchBar(),
            _buildFilters(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: _onNavTap,
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on search
        break;
      case 2:
        Navigator.pushNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
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
              'Search Notes',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for notes...',
            hintStyle: TextStyle(
              fontFamily: 'Lexend',
              color: Colors.grey[400],
            ),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: Icon(Icons.close, color: Colors.grey[400]),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FilterDropdown(
                  label: 'Subject',
                  value: _selectedSubject,
                  items: _subjects,
                  onChanged: (value) => setState(() => _selectedSubject = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDropdown(
                  label: 'Semester',
                  value: _selectedSemester,
                  items: _semesters,
                  onChanged: (value) => setState(() => _selectedSemester = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterDropdown(
            label: 'Branch',
            value: _selectedBranch,
            items: _branches,
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No notes found',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Lexend',
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final note = _searchResults[index];
        return NoteCard(
          note: note,
          onTap: () {
            Navigator.pushNamed(context, '/note-details', arguments: note);
          },
        );
      },
    );
  }
}

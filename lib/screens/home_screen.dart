import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Computer Science',
    'Mathematics',
    'Physics',
    'Electronics',
  ];

  // Sample data
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Data Structures and Algorithms Complete Notes',
      subject: 'Computer Science',
      semester: '3rd Sem',
      branch: 'CSE',
      uploaderName: 'Rahul Sharma',
      rating: 4.8,
      downloadCount: 234,
      reviewCount: 45,
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: '2',
      title: 'Calculus II - Integration Techniques',
      subject: 'Mathematics',
      semester: '2nd Sem',
      branch: 'All',
      uploaderName: 'Priya Patel',
      rating: 4.5,
      downloadCount: 189,
      reviewCount: 32,
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Note(
      id: '3',
      title: 'Operating Systems - Process Management',
      subject: 'Computer Science',
      semester: '4th Sem',
      branch: 'CSE',
      uploaderName: 'Amit Kumar',
      rating: 4.9,
      downloadCount: 312,
      reviewCount: 67,
      isSaved: true,
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Note(
      id: '4',
      title: 'Digital Electronics - Logic Gates',
      subject: 'Electronics',
      semester: '3rd Sem',
      branch: 'ECE',
      uploaderName: 'Sneha Gupta',
      rating: 4.3,
      downloadCount: 156,
      reviewCount: 28,
      uploadDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(child: _buildNotesList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentNavIndex = index);
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.pushNamed(context, '/search');
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning! 👋',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Explore Notes',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          Container(
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
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return CustomFilterChip(
            label: filter,
            isSelected: _selectedFilter == filter,
            onTap: () => setState(() => _selectedFilter = filter),
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    final filteredNotes = _selectedFilter == 'All'
        ? _notes
        : _notes.where((n) => n.subject == _selectedFilter).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return NoteCard(
          note: note,
          onTap: () {
            Navigator.pushNamed(context, '/note-details', arguments: note);
          },
          onSave: () {
            setState(() {
              final noteIndex = _notes.indexWhere((n) => n.id == note.id);
              if (noteIndex != -1) {
                _notes[noteIndex] = note.copyWith(isSaved: !note.isSaved);
              }
            });
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/bottom_nav_bar.dart';
import '../config/college_config.dart';
import '../services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _error;

  final List<String> _filters = [
    'All',
    ...CollegeConfig.subjects.take(6),
  ];

  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = SupabaseService.instance;
      final profile = service.currentProfile;
      final college = profile?.college ?? CollegeConfig.defaultCollegeId;
      _notes = await service.getNotes(college: college);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  Future<void> _toggleSave(Note note) async {
    try {
      final service = SupabaseService.instance;
      final userId = service.currentUser?.id;
      if (userId == null) return;

      final idx = _notes.indexWhere((n) => n.id == note.id);
      if (idx == -1) return;

      if (note.isSaved) {
        await service.unsaveNote(note.id, userId);
      } else {
        await service.saveNote(note.id, userId);
      }
      setState(() {
        _notes[idx] = note.copyWith(isSaved: !note.isSaved);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update saved notes')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildExamSurvivalBanner(),
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
        Navigator.pushReplacementNamed(context, '/search');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/leaderboard');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
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

  Widget _buildExamSurvivalBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/exam-survival'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B35), Color(0xFFFF8F65)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_fire_department, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exam Survival Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quick revision notes & previous papers',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Lexend',
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF136DEC)));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Failed to load notes', style: TextStyle(fontFamily: 'Lexend', color: Colors.grey[500])),
            const SizedBox(height: 8),
            TextButton(onPressed: _loadNotes, child: const Text('Retry', style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF136DEC)))),
          ],
        ),
      );
    }

    final filteredNotes = _selectedFilter == 'All'
        ? _notes
        : _notes.where((n) => n.subject == _selectedFilter).toList();

    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('No notes yet', style: TextStyle(fontSize: 16, fontFamily: 'Lexend', color: Colors.grey[500])),
            const SizedBox(height: 4),
            Text('Be the first to upload!', style: TextStyle(fontSize: 13, fontFamily: 'Lexend', color: Colors.grey[400])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      color: const Color(0xFF136DEC),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return NoteCard(
            note: note,
            onTap: () {
              Navigator.pushNamed(context, '/note-details', arguments: note);
            },
            onSave: () => _toggleSave(note),
          );
        },
      ),
    );
  }
}

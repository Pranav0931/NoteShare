import 'dart:async';
import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_chip.dart';
import '../widgets/bottom_nav_bar.dart';
import '../config/college_config.dart';
import '../services/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _selectedSubject;
  String? _selectedSemester;
  String? _selectedBranch;
  bool _isLoading = false;
  List<Note> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    try {
      final service = SupabaseService.instance;
      final college = service.currentProfile?.college ?? CollegeConfig.defaultCollegeId;
      _results = await service.getNotes(
        college: college,
        subject: _selectedSubject,
        semester: _selectedSemester,
        branch: _selectedBranch,
        keyword: _searchController.text.trim().isNotEmpty ? _searchController.text.trim() : null,
      );
      _hasSearched = true;
    } catch (_) {
      _results = [];
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _performSearch);
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
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                  icon: Icon(Icons.close, color: Colors.grey[400]),
                );
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: (_) => _scheduleSearch(),
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
                  items: CollegeConfig.subjects,
                  onChanged: (value) { setState(() => _selectedSubject = value); _performSearch(); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilterDropdown(
                  label: 'Semester',
                  value: _selectedSemester,
                  items: CollegeConfig.semesters,
                  onChanged: (value) { setState(() => _selectedSemester = value); _performSearch(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterDropdown(
            label: 'Branch',
            value: _selectedBranch,
            items: CollegeConfig.branches,
            onChanged: (value) { setState(() => _selectedBranch = value); _performSearch(); },
          ),
          if (_selectedSubject != null || _selectedSemester != null || _selectedBranch != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSubject = null;
                    _selectedSemester = null;
                    _selectedBranch = null;
                  });
                  _performSearch();
                },
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                    color: Color(0xFF136DEC),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF136DEC)));
    }

    if (_results.isEmpty && _hasSearched) {
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
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final note = _results[index];
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

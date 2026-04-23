import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/filter_chip.dart';
import '../config/college_config.dart';
import '../services/firebase_service.dart';

class ExamSurvivalScreen extends StatefulWidget {
  const ExamSurvivalScreen({super.key});

  @override
  State<ExamSurvivalScreen> createState() => _ExamSurvivalScreenState();
}

class _ExamSurvivalScreenState extends State<ExamSurvivalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSemester;
  String? _selectedBranch;

  final List<String> _tabs = [
    'Most Downloaded',
    'Short Notes',
    'Important Q',
    'Prev. Papers',
  ];

  List<Note> _mostDownloaded = [];
  List<Note> _shortNotes = [];
  List<Note> _importantQuestions = [];
  List<Note> _previousYearPapers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final service = FirebaseService.instance;
      final college = service.currentProfile?.college ?? CollegeConfig.defaultCollegeId;

      final results = await Future.wait([
        service.getExamSurvivalNotes(college: college, branch: _selectedBranch, semester: _selectedSemester),
        service.getNotesByCategory(NoteCategory.shortNotes, college),
        service.getNotesByCategory(NoteCategory.importantQuestions, college),
        service.getNotesByCategory(NoteCategory.previousYearPapers, college),
      ]);

      _mostDownloaded = results[0];
      _shortNotes = results[1];
      _importantQuestions = results[2];
      _previousYearPapers = results[3];
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Note> _getNotesForTab(int index) {
    List<Note> notes;
    switch (index) {
      case 0:
        notes = _mostDownloaded;
        break;
      case 1:
        notes = _shortNotes;
        break;
      case 2:
        notes = _importantQuestions;
        break;
      case 3:
        notes = _previousYearPapers;
        break;
      default:
        notes = _mostDownloaded;
    }
    return _filterNotes(notes);
  }

  List<Note> _filterNotes(List<Note> notes) {
    return notes.where((note) {
      if (_selectedBranch != null && note.branch != _selectedBranch) return false;
      if (_selectedSemester != null && note.semester != _selectedSemester) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildBanner(),
            _buildQuickFilters(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                  : _buildTabView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'Could not load exam notes',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 16,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
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
              'Exam Survival Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lexend',
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_fire_department, size: 22, color: Color(0xFFFF6B35)),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8F65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Revision Hub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find the best notes, short summaries &\nprevious year papers in one place.',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lexend',
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: FilterDropdown(
              label: 'Branch',
              value: _selectedBranch,
              items: CollegeConfig.branches,
              onChanged: (v) {
                setState(() => _selectedBranch = v);
                _loadData();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilterDropdown(
              label: 'Semester',
              value: _selectedSemester,
              items: CollegeConfig.semesters,
              onChanged: (v) {
                setState(() => _selectedSemester = v);
                _loadData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: const Color(0xFFFF6B35),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lexend',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontFamily: 'Lexend',
        ),
        dividerColor: Colors.transparent,
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: List.generate(_tabs.length, (index) {
        final notes = _getNotesForTab(index);
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 56, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'No notes found',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Lexend',
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Try changing filters',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lexend',
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: notes.length,
          itemBuilder: (context, i) {
            return NoteCard(
              note: notes[i],
              onTap: () => Navigator.pushNamed(context, '/note-details', arguments: notes[i]),
            );
          },
        );
      }),
    );
  }
}

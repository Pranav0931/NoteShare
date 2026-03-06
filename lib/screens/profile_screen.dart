import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import '../widgets/user_avatar.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample user data
  final _userName = 'Rahul Sharma';
  final _university = 'RCOEM, Nagpur';
  final _uploadCount = 23;
  final _downloadCount = 156;
  final _rating = 4.8;

  // Sample uploaded notes
  final List<Note> _uploadedNotes = [
    Note(
      id: '1',
      title: 'Data Structures Complete Notes',
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
      title: 'Operating Systems Guide',
      subject: 'Computer Science',
      semester: '4th Sem',
      branch: 'CSE',
      uploaderName: 'Rahul Sharma',
      rating: 4.6,
      downloadCount: 189,
      uploadDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // Sample saved notes
  final List<Note> _savedNotes = [
    Note(
      id: '3',
      title: 'Calculus II - Integration',
      subject: 'Mathematics',
      semester: '2nd Sem',
      branch: 'All',
      uploaderName: 'Priya Patel',
      rating: 4.5,
      downloadCount: 156,
      isSaved: true,
      uploadDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Note(
      id: '4',
      title: 'Digital Electronics Notes',
      subject: 'Electronics',
      semester: '3rd Sem',
      branch: 'ECE',
      uploaderName: 'Amit Kumar',
      rating: 4.7,
      downloadCount: 198,
      isSaved: true,
      uploadDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildProfileInfo(),
            _buildStats(),
            const SizedBox(height: 16),
            _buildTabBar(),
            Expanded(child: _buildTabView()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
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
        Navigator.pushNamed(context, '/search');
        break;
      case 2:
        Navigator.pushNamed(context, '/upload');
        break;
      case 3:
        Navigator.pushNamed(context, '/leaderboard');
        break;
      case 4:
        // Already on profile
        break;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lexend',
                color: Color(0xFF1A1A1A),
              ),
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
              icon: const Icon(Icons.settings_outlined),
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          LargeUserAvatar(
            name: _userName,
            size: 80,
            onEdit: () {},
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.school_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _university,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lexend',
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF136DEC)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Lexend',
                        color: Color(0xFF136DEC),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Uploads', _uploadCount.toString(), Icons.upload_file),
          _buildDivider(),
          _buildStatItem('Downloads', _downloadCount.toString(), Icons.download),
          _buildDivider(),
          _buildStatItem('Rating', _rating.toStringAsFixed(1), Icons.star),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF136DEC).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF136DEC), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Lexend',
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
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
        labelColor: const Color(0xFF136DEC),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Lexend',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontFamily: 'Lexend',
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Uploaded'),
          Tab(text: 'Saved'),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotesList(_uploadedNotes),
        _buildNotesList(_savedNotes),
      ],
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No notes yet',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Lexend',
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return NoteCard(
          note: notes[index],
          onTap: () {
            Navigator.pushNamed(context, '/note-details', arguments: notes[index]);
          },
        );
      },
    );
  }
}

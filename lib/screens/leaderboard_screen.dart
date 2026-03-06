import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/user_avatar.dart';
import '../widgets/bottom_nav_bar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Sample leaderboard data
  final List<LeaderboardEntry> _leaderboard = [
    LeaderboardEntry(
      rank: 1,
      user: User(
        id: '1',
        name: 'Priya Patel',
        email: 'priya@email.com',
        university: 'IIT Delhi',
        uploadCount: 45,
        points: 2450,
      ),
      points: 2450,
    ),
    LeaderboardEntry(
      rank: 2,
      user: User(
        id: '2',
        name: 'Rahul Sharma',
        email: 'rahul@email.com',
        university: 'RCOEM Nagpur',
        uploadCount: 38,
        points: 2180,
      ),
      points: 2180,
    ),
    LeaderboardEntry(
      rank: 3,
      user: User(
        id: '3',
        name: 'Amit Kumar',
        email: 'amit@email.com',
        university: 'NIT Trichy',
        uploadCount: 34,
        points: 1920,
      ),
      points: 1920,
    ),
    LeaderboardEntry(
      rank: 4,
      user: User(
        id: '4',
        name: 'Sneha Gupta',
        email: 'sneha@email.com',
        university: 'BITS Pilani',
        uploadCount: 29,
        points: 1650,
      ),
      points: 1650,
    ),
    LeaderboardEntry(
      rank: 5,
      user: User(
        id: '5',
        name: 'John Doe',
        email: 'john@email.com',
        university: 'VIT Vellore',
        uploadCount: 25,
        points: 1420,
      ),
      points: 1420,
    ),
    LeaderboardEntry(
      rank: 6,
      user: User(
        id: '6',
        name: 'Jane Smith',
        email: 'jane@email.com',
        university: 'IIIT Hyderabad',
        uploadCount: 22,
        points: 1280,
      ),
      points: 1280,
    ),
    LeaderboardEntry(
      rank: 7,
      user: User(
        id: '7',
        name: 'Mike Johnson',
        email: 'mike@email.com',
        university: 'DTU Delhi',
        uploadCount: 20,
        points: 1150,
      ),
      points: 1150,
    ),
    LeaderboardEntry(
      rank: 8,
      user: User(
        id: '8',
        name: 'Sara Williams',
        email: 'sara@email.com',
        university: 'NIT Warangal',
        uploadCount: 18,
        points: 1020,
      ),
      points: 1020,
    ),
    LeaderboardEntry(
      rank: 9,
      user: User(
        id: '9',
        name: 'Alex Brown',
        email: 'alex@email.com',
        university: 'IIIT Bangalore',
        uploadCount: 16,
        points: 920,
      ),
      points: 920,
    ),
    LeaderboardEntry(
      rank: 10,
      user: User(
        id: '10',
        name: 'Emily Davis',
        email: 'emily@email.com',
        university: 'NIT Surathkal',
        uploadCount: 15,
        points: 850,
      ),
      points: 850,
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
            _buildTopThree(),
            Expanded(child: _buildLeaderboardList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
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
        // Already on leaderboard
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Top Contributors',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopThree() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF136DEC),
            const Color(0xFF136DEC).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF136DEC).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_leaderboard.length > 1)
            _buildTopUser(_leaderboard[1], isFirst: false),
          if (_leaderboard.isNotEmpty)
            _buildTopUser(_leaderboard[0], isFirst: true),
          if (_leaderboard.length > 2)
            _buildTopUser(_leaderboard[2], isFirst: false),
        ],
      ),
    );
  }

  Widget _buildTopUser(LeaderboardEntry entry, {required bool isFirst}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 32,
            ),
          ),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getRankColor(entry.rank),
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: isFirst ? 36 : 28,
                backgroundColor: Colors.white,
                child: Text(
                  entry.user.name[0],
                  style: TextStyle(
                    fontSize: isFirst ? 24 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF136DEC),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${entry.rank}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          entry.user.name.split(' ')[0],
          style: TextStyle(
            fontSize: isFirst ? 14 : 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Lexend',
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${entry.points} pts',
            style: TextStyle(
              fontSize: isFirst ? 14 : 12,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  Widget _buildLeaderboardList() {
    final remainingEntries = _leaderboard.skip(3).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: remainingEntries.length,
      itemBuilder: (context, index) {
        return _buildLeaderboardCard(remainingEntries[index]);
      },
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          UserAvatar(name: entry.user.name, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.user.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.user.university,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Lexend',
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF136DEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${entry.points} pts',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
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

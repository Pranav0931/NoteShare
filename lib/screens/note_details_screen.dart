import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/user_avatar.dart';

class NoteDetailsScreen extends StatefulWidget {
  const NoteDetailsScreen({super.key});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  bool _isSaved = false;

  // Sample reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'John Doe',
      'rating': 5.0,
      'comment': 'Excellent notes! Very well organized and easy to understand.',
      'date': '2 days ago',
    },
    {
      'name': 'Jane Smith',
      'rating': 4.0,
      'comment': 'Good content but could use more examples.',
      'date': '5 days ago',
    },
    {
      'name': 'Mike Johnson',
      'rating': 5.0,
      'comment': 'Helped me ace my exam! Highly recommended.',
      'date': '1 week ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final note = ModalRoute.of(context)?.settings.arguments as Note? ??
        Note(
          id: '1',
          title: 'Data Structures and Algorithms Complete Notes',
          subject: 'Computer Science',
          semester: '3rd Sem',
          branch: 'CSE',
          description: 'Comprehensive notes covering all DSA topics including arrays, linked lists, trees, graphs, sorting, and searching algorithms.',
          uploaderName: 'Rahul Sharma',
          rating: 4.8,
          downloadCount: 234,
          reviewCount: 45,
          uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPreview(),
                    _buildNoteInfo(note),
                    _buildUploaderSection(note),
                    _buildActionButtons(note),
                    _buildRatingSection(note),
                    _buildReviewsList(),
                  ],
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
              'Note Details',
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.share_outlined, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 200,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Lexend',
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View Full Document',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  color: Color(0xFF136DEC),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteInfo(Note note) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF136DEC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Lexend',
                    color: Color(0xFF136DEC),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.semester,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Lexend',
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            note.description.isNotEmpty 
                ? note.description 
                : 'Comprehensive notes covering all key topics from the syllabus. Well-organized with diagrams and examples.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploaderSection(Note note) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          UserAvatar(name: note.uploaderName, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.uploaderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded ${_formatDate(note.uploadDate)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lexend',
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF136DEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'Lexend',
                color: Color(0xFF136DEC),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${diff.inDays ~/ 7} week(s) ago';
  }

  Widget _buildActionButtons(Note note) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136DEC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.download, size: 20),
                label: Text(
                  'Download (${note.downloadCount})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _isSaved = !_isSaved);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _isSaved ? const Color(0xFF136DEC) : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: _isSaved ? const Color(0xFF136DEC) : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(Note note) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peer Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    note.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < note.rating.floor()
                            ? Icons.star
                            : (index < note.rating ? Icons.star_half : Icons.star_border),
                        color: Colors.amber[600],
                        size: 20,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${note.reviewCount} reviews',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Lexend',
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.7),
                    _buildRatingBar(4, 0.2),
                    _buildRatingBar(3, 0.05),
                    _buildRatingBar(2, 0.03),
                    _buildRatingBar(1, 0.02),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Lexend',
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                  color: Color(0xFF1A1A1A),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Write Review',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    color: Color(0xFF136DEC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(name: review['name'], radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[600]),
                  const SizedBox(width: 4),
                  Text(
                    review['rating'].toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

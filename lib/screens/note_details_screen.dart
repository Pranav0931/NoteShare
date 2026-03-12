import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/note.dart';
import '../widgets/user_avatar.dart';
import '../services/supabase_service.dart';

class NoteDetailsScreen extends StatefulWidget {
  const NoteDetailsScreen({super.key});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  bool _isSaved = false;
  bool _isDownloading = false;
  List<Review> _reviews = [];
  bool _loadingReviews = true;
  Note? _note;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_note == null) {
      _note = ModalRoute.of(context)?.settings.arguments as Note? ??
          Note(
            id: '1',
            title: 'Data Structures and Algorithms Complete Notes',
            subject: 'Computer Science',
            semester: '3rd Sem',
            branch: 'CSE',
            description: 'Comprehensive notes covering all DSA topics.',
            uploaderName: 'Rahul Sharma',
            rating: 4.8,
            downloadCount: 234,
            reviewCount: 45,
            uploadDate: DateTime.now().subtract(const Duration(days: 2)),
          );
      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      final service = SupabaseService.instance;
      final userId = service.currentUser?.id;

      // Check if saved
      if (userId != null) {
        _isSaved = await service.isNoteSaved(_note!.id, userId);
      }

      // Load reviews
      _reviews = await service.getReviews(_note!.id);
    } catch (_) {}
    if (mounted) setState(() => _loadingReviews = false);
  }

  Future<void> _handleDownload() async {
    final service = SupabaseService.instance;
    final userId = service.currentUser?.id;
    if (userId == null || _note == null) return;

    setState(() => _isDownloading = true);
    try {
      await service.recordDownload(_note!.id, userId);
      setState(() {
        _note = _note!.copyWith(downloadCount: _note!.downloadCount + 1);
      });

      if (_note!.fileUrl != null && _note!.fileUrl!.isNotEmpty && mounted) {
        final uri = Uri.parse(_note!.fileUrl!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed')),
        );
      }
    }
    if (mounted) setState(() => _isDownloading = false);
  }

  Future<void> _handleSave() async {
    final service = SupabaseService.instance;
    final userId = service.currentUser?.id;
    if (userId == null || _note == null) return;

    try {
      if (_isSaved) {
        await service.unsaveNote(_note!.id, userId);
      } else {
        await service.saveNote(_note!.id, userId);
      }
      setState(() => _isSaved = !_isSaved);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final note = _note ?? (ModalRoute.of(context)?.settings.arguments as Note? ??
        Note(
          id: '1',
          title: 'Data Structures and Algorithms Complete Notes',
          subject: 'Computer Science',
          semester: '3rd Sem',
          branch: 'CSE',
          description: 'Comprehensive notes covering all DSA topics.',
          uploaderName: 'Rahul Sharma',
          rating: 4.8,
          downloadCount: 234,
          reviewCount: 45,
          uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        ));

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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getFileTypeIcon(note.fileType),
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      note.fileType.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
                  'Uploaded by ${note.uploaderName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (note.uploaderBranch.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF136DEC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          note.uploaderBranch,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lexend',
                            color: Color(0xFF136DEC),
                          ),
                        ),
                      ),
                    if (note.uploaderSemester.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        note.uploaderSemester,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Lexend',
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '\u2022 ${_formatDate(note.uploadDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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

  IconData _getFileTypeIcon(NoteFileType fileType) {
    switch (fileType) {
      case NoteFileType.pdf:
        return Icons.picture_as_pdf;
      case NoteFileType.image:
        return Icons.image;
      case NoteFileType.document:
        return Icons.description;
    }
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
                onPressed: _isDownloading ? null : _handleDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF136DEC),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download, size: 20),
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
              onPressed: _handleSave,
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
                onPressed: _showWriteReviewDialog,
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
          if (_loadingReviews)
            const Center(child: CircularProgressIndicator())
          else if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No reviews yet. Be the first!',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    color: Colors.grey[500],
                  ),
                ),
              ),
            )
          else
            ..._reviews.map((review) => _buildReviewCard(review)),
        ],
      ),
    );
  }

  void _showWriteReviewDialog() {
    double selectedRating = 5;
    final commentController = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Write a Review', style: TextStyle(fontFamily: 'Lexend')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return IconButton(
                    icon: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber[600],
                      size: 32,
                    ),
                    onPressed: () => setDialogState(() => selectedRating = i + 1.0),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      try {
                        final service = SupabaseService.instance;
                        final userId = service.currentUser?.id;
                        final profile = service.currentProfile;
                        if (userId == null || _note == null) return;

                        await service.addReview(Review(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          noteId: _note!.id,
                          reviewerId: userId,
                          reviewerName: profile?.name ?? 'Anonymous',
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                          date: DateTime.now(),
                        ));

                        if (ctx.mounted) Navigator.pop(ctx);
                        // Reload reviews
                        final reviews = await service.getReviews(_note!.id);
                        setState(() => _reviews = reviews);
                      } catch (_) {
                        setDialogState(() => submitting = false);
                      }
                    },
              child: submitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
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
              UserAvatar(name: review.reviewerName, radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                      ),
                    ),
                    Text(
                      _formatDate(review.date),
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
                    review.rating.toStringAsFixed(1),
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
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Lexend',
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

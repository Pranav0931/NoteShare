import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/supabase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Note> _pendingNotes = [];
  bool _isLoading = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _loadPendingNotes();
  }

  Future<void> _loadPendingNotes() async {
    if (!SupabaseService.instance.isAdmin) {
      if (mounted) {
        setState(() {
          _hasAccess = false;
          _pendingNotes = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasAccess = true;
    });
    try {
      _pendingNotes = await SupabaseService.instance.getPendingNotes();
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _moderate(Note note, NoteStatus status) async {
    try {
      await SupabaseService.instance.moderateNote(note.id, status);
      setState(() => _pendingNotes.remove(note));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == NoteStatus.approved
                  ? '✓ "${note.title}" approved'
                  : '✗ "${note.title}" rejected',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action failed. Try again.')),
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : !_hasAccess
                      ? _buildUnauthorizedState()
                      : _pendingNotes.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadPendingNotes,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                itemCount: _pendingNotes.length,
                                itemBuilder: (context, i) =>
                                    _buildPendingCard(_pendingNotes[i]),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${_pendingNotes.length} pending review${_pendingNotes.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Lexend',
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF136DEC).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 22,
              color: Color(0xFF136DEC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green[300]),
          const SizedBox(height: 16),
          const Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending notes to review',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthorizedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Access denied',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lexend',
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Admin role is required to moderate notes.',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Lexend',
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
          // Status badge + file type
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Lexend',
                    color: Colors.amber,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.fileType.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Lexend',
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(note.uploadDate),
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Lexend',
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Lexend',
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),

          // Subject + meta
          Row(
            children: [
              Text(
                '${note.subject} • ${note.semester} • ${note.branch}',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Lexend',
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Uploader info
          Text(
            'Uploaded by ${note.uploaderName}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Lexend',
              color: Colors.grey[600],
            ),
          ),

          if (note.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Lexend',
                color: Colors.grey[500],
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () => _moderate(note, NoteStatus.rejected),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.close, size: 18, color: Colors.red),
                    label: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () => _moderate(note, NoteStatus.approved),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text(
                      'Approve',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'today';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays ~/ 7}w ago';
  }
}

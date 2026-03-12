import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';
import '../models/user.dart' as app;

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  /// Cached current user profile (loaded after login).
  app.User? _currentProfile;
  app.User? get currentProfile => _currentProfile;
  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  // ─── Authentication ───────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    final response = await _client.auth.signUp(email: email, password: password);
    return response;
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      await loadCurrentProfile();
    }
    return response;
  }

  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.noteshare://login-callback/',
      );
      
      // Wait a moment for the session to be established
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Try to load the current user's profile
      await loadCurrentProfile();
    } catch (e) {
      print('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    _currentProfile = null;
    await _client.auth.signOut();
  }

  // ─── User Profile ─────────────────────────────────────────────

  /// Load and cache the current user's profile.
  Future<app.User?> loadCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    _currentProfile = await getUserProfile(user.id);
    return _currentProfile;
  }

  Future<void> upsertUserProfile(app.User user) async {
    try {
      // Use the server-side function for safer insertion
      await _client.rpc('create_user_profile', params: {
        'user_id': user.id,
        'user_name': user.name,
        'user_email': user.email,
        'user_college': user.college,
        'user_branch': user.branch,
        'user_semester': user.semester,
      });
      if (user.id == currentUser?.id) {
        _currentProfile = user;
      }
    } catch (e) {
      print('Error creating user profile: $e');
      // Fallback to direct upsert if RPC fails
      try {
        await _client.from('users').upsert(user.toMap());
        if (user.id == currentUser?.id) {
          _currentProfile = user;
        }
      } catch (fallbackError) {
        print('Fallback upsert also failed: $fallbackError');
        rethrow;
      }
    }
  }

  Future<app.User?> getUserProfile(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return app.User.fromMap(data);
  }

  Future<void> updateUserCollege({
    required String userId,
    required String college,
    required String branch,
    required String semester,
  }) async {
    await _client.from('users').update({
      'college': college,
      'branch': branch,
      'semester': semester,
    }).eq('id', userId);
    await loadCurrentProfile();
  }

  /// Check if the current user has completed college setup.
  bool get hasCompletedSetup =>
      _currentProfile != null &&
      _currentProfile!.college.isNotEmpty &&
      _currentProfile!.branch.isNotEmpty &&
      _currentProfile!.semester.isNotEmpty;

  // ─── Notes ────────────────────────────────────────────────────

  Future<List<Note>> getNotes({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? keyword,
    NoteStatus status = NoteStatus.approved,
  }) async {
    var query = _client.from('notes').select().eq('status', status.name);

    if (college != null && college.isNotEmpty) {
      query = query.eq('college', college);
    }
    if (branch != null && branch.isNotEmpty) {
      query = query.eq('branch', branch);
    }
    if (semester != null && semester.isNotEmpty) {
      query = query.eq('semester', semester);
    }
    if (subject != null && subject.isNotEmpty) {
      query = query.eq('subject', subject);
    }

    final data = await query.order('upload_date', ascending: false);

    List<Note> notes = (data as List).map((e) => Note.fromMap(e)).toList();

    if (keyword != null && keyword.isNotEmpty) {
      final lower = keyword.toLowerCase();
      notes = notes
          .where((n) =>
              n.title.toLowerCase().contains(lower) ||
              n.description.toLowerCase().contains(lower) ||
              n.subject.toLowerCase().contains(lower))
          .toList();
    }

    return notes;
  }

  Future<List<Note>> getExamSurvivalNotes({
    required String college,
    String? branch,
    String? semester,
  }) async {
    var query = _client
        .from('notes')
        .select()
        .eq('status', NoteStatus.approved.name)
        .eq('college', college);

    if (branch != null) query = query.eq('branch', branch);
    if (semester != null) query = query.eq('semester', semester);

    final data = await query.order('download_count', ascending: false).limit(50);
    return (data as List).map((e) => Note.fromMap(e)).toList();
  }

  Future<List<Note>> getNotesByCategory(NoteCategory category, String college) async {
    final data = await _client
        .from('notes')
        .select()
        .eq('status', NoteStatus.approved.name)
        .eq('college', college)
        .eq('category', category.name)
        .order('download_count', ascending: false)
        .limit(20);
    return (data as List).map((e) => Note.fromMap(e)).toList();
  }

  Future<Note?> getNoteById(String noteId) async {
    final data = await _client
        .from('notes')
        .select()
        .eq('id', noteId)
        .maybeSingle();
    if (data == null) return null;
    return Note.fromMap(data);
  }

  Future<void> uploadNote(Note note) async {
    await _client.from('notes').insert(note.toMap());
    // Update the user's upload count
    if (currentUser != null) {
      await _client.rpc('increment_upload_count', params: {'user_id_param': currentUser!.id});
      await loadCurrentProfile();
    }
  }

  Future<List<Note>> getUserNotes(String userId) async {
    final data = await _client
        .from('notes')
        .select()
        .eq('uploader_id', userId)
        .order('upload_date', ascending: false);
    return (data as List).map((e) => Note.fromMap(e)).toList();
  }

  Future<List<Note>> getPendingNotes() async {
    final data = await _client
        .from('notes')
        .select()
        .eq('status', NoteStatus.pending.name)
        .order('upload_date', ascending: false);
    return (data as List).map((e) => Note.fromMap(e)).toList();
  }

  Future<void> moderateNote(String noteId, NoteStatus status) async {
    await _client.from('notes').update({'status': status.name}).eq('id', noteId);
  }

  // ─── File Storage ─────────────────────────────────────────────

  Future<String> uploadFile(String path, Uint8List fileBytes, String contentType) async {
    await _client.storage.from('notes-files').uploadBinary(
      path,
      fileBytes,
      fileOptions: FileOptions(contentType: contentType),
    );
    return _client.storage.from('notes-files').getPublicUrl(path);
  }

  // ─── Downloads ────────────────────────────────────────────────

  Future<void> recordDownload(String noteId, String userId) async {
    await _client.from('downloads').insert({
      'note_id': noteId,
      'user_id': userId,
      'download_date': DateTime.now().toIso8601String(),
    });
    await _client.rpc('increment_download_count', params: {'note_id_param': noteId});
  }

  Future<List<Note>> getDownloadedNotes(String userId) async {
    final data = await _client
        .from('downloads')
        .select('note_id, notes(*)')
        .eq('user_id', userId)
        .order('download_date', ascending: false);
    return (data as List)
        .where((e) => e['notes'] != null)
        .map((e) => Note.fromMap(e['notes'] as Map<String, dynamic>))
        .toList();
  }

  // ─── Saved Notes ──────────────────────────────────────────────

  Future<void> saveNote(String noteId, String userId) async {
    await _client.from('saved_notes').insert({
      'note_id': noteId,
      'user_id': userId,
      'saved_date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unsaveNote(String noteId, String userId) async {
    await _client
        .from('saved_notes')
        .delete()
        .eq('note_id', noteId)
        .eq('user_id', userId);
  }

  Future<bool> isNoteSaved(String noteId, String userId) async {
    final data = await _client
        .from('saved_notes')
        .select('id')
        .eq('note_id', noteId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  Future<List<Note>> getSavedNotes(String userId) async {
    final data = await _client
        .from('saved_notes')
        .select('note_id, notes(*)')
        .eq('user_id', userId);
    return (data as List)
        .where((e) => e['notes'] != null)
        .map((e) => Note.fromMap(e['notes'] as Map<String, dynamic>))
        .toList();
  }

  // ─── Leaderboard ──────────────────────────────────────────────

  Future<List<app.LeaderboardEntry>> getLeaderboard(String college) async {
    final data = await _client
        .from('users')
        .select()
        .eq('college', college)
        .order('points', ascending: false)
        .limit(20);

    int rank = 0;
    return (data as List).map((e) {
      rank++;
      final user = app.User.fromMap(e);
      return app.LeaderboardEntry(
        rank: rank,
        user: user,
        points: user.points,
        totalDownloadsReceived: user.downloadCount,
        communityScore: user.communityScore,
      );
    }).toList();
  }

  // ─── Reviews ──────────────────────────────────────────────────

  Future<void> addReview(Review review) async {
    await _client.from('reviews').insert(review.toMap());
    // Update note's review count and average rating
    final reviews = await getReviews(review.noteId);
    final avgRating = reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;
    await _client.from('notes').update({
      'review_count': reviews.length,
      'rating': double.parse(avgRating.toStringAsFixed(1)),
    }).eq('id', review.noteId);
  }

  Future<List<Review>> getReviews(String noteId) async {
    final data = await _client
        .from('reviews')
        .select()
        .eq('note_id', noteId)
        .order('date', ascending: false);
    return (data as List).map((e) => Review.fromMap(e)).toList();
  }
}

import 'dart:developer' as developer;
// import 'dart:typed_data';  // Re-enable with Firebase Storage
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';  // Re-enable with Blaze plan
import 'package:google_sign_in/google_sign_in.dart';
import '../models/note.dart';
import '../models/user.dart' as app;

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  FirebaseService._();

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Firebase Storage — disabled on Spark (free) plan.
  // Uncomment when upgrading to Blaze plan:
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  static const bool storageEnabled = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Cached current user profile (loaded after login).
  app.User? _currentProfile;
  app.User? get currentProfile => _currentProfile;
  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  // ─── Authentication ───────────────────────────────────────────

  fb_auth.User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  /// Provides an auth state stream compatible with screen listeners.
  /// Emits events whenever the user signs in or out.
  Stream<fb_auth.User?> get authStateChanges => _auth.authStateChanges();

  Future<fb_auth.UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Store display name
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<fb_auth.UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      await loadCurrentProfile();
    }
    return credential;
  }

  Future<fb_auth.UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      developer.log('Google sign-in error', error: e, name: 'FirebaseService');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Check if there's an active session and load profile if so.
  Future<bool> checkAndLoadSession() async {
    final user = currentUser;
    if (user != null) {
      await loadCurrentProfile();
      return true;
    }
    return false;
  }

  Future<void> signOut() async {
    _currentProfile = null;
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── User Profile ─────────────────────────────────────────────

  /// Load and cache the current user's profile.
  Future<app.User?> loadCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    _currentProfile = await getUserProfile(user.uid);
    return _currentProfile;
  }

  Future<void> upsertUserProfile(app.User user) async {
    try {
      await _db.collection('users').doc(user.id).set(
        user.toMap(),
        SetOptions(merge: true),
      );
      if (user.id == currentUser?.uid) {
        _currentProfile = user;
      }
    } catch (e) {
      developer.log('Error creating user profile', error: e, name: 'FirebaseService');
      rethrow;
    }
  }

  Future<app.User?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return app.User.fromMap(data);
  }

  Future<void> updateUserCollege({
    required String userId,
    required String college,
    required String branch,
    required String semester,
  }) async {
    await _db.collection('users').doc(userId).update({
      'college': college,
      'branch': branch,
      'semester': semester,
    });
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
    Query query = _db.collection('notes').where('status', isEqualTo: status.name);

    if (college != null && college.isNotEmpty) {
      query = query.where('college', isEqualTo: college);
    }
    if (branch != null && branch.isNotEmpty) {
      query = query.where('branch', isEqualTo: branch);
    }
    if (semester != null && semester.isNotEmpty) {
      query = query.where('semester', isEqualTo: semester);
    }
    if (subject != null && subject.isNotEmpty) {
      query = query.where('subject', isEqualTo: subject);
    }

    query = query.orderBy('upload_date', descending: true);

    final snapshot = await query.get();
    List<Note> notes = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Note.fromMap(data);
    }).toList();

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
    Query query = _db
        .collection('notes')
        .where('status', isEqualTo: NoteStatus.approved.name)
        .where('college', isEqualTo: college);

    if (branch != null) query = query.where('branch', isEqualTo: branch);
    if (semester != null) query = query.where('semester', isEqualTo: semester);

    query = query.orderBy('download_count', descending: true).limit(50);

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Note.fromMap(data);
    }).toList();
  }

  Future<List<Note>> getNotesByCategory(NoteCategory category, String college) async {
    final snapshot = await _db
        .collection('notes')
        .where('status', isEqualTo: NoteStatus.approved.name)
        .where('college', isEqualTo: college)
        .where('category', isEqualTo: category.name)
        .orderBy('download_count', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return Note.fromMap(data);
    }).toList();
  }

  Future<Note?> getNoteById(String noteId) async {
    final doc = await _db.collection('notes').doc(noteId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = doc.id;
    return Note.fromMap(data);
  }

  Future<void> uploadNote(Note note) async {
    final docRef = note.id.isNotEmpty
        ? _db.collection('notes').doc(note.id)
        : _db.collection('notes').doc();

    final data = note.toMap();
    if (note.id.isEmpty) {
      data['id'] = docRef.id;
    }
    await docRef.set(data);

    // Increment upload count for the user
    if (currentUser != null) {
      await _db.collection('users').doc(currentUser!.uid).update({
        'upload_count': FieldValue.increment(1),
        'points': FieldValue.increment(10),
      });
      await loadCurrentProfile();
    }
  }

  Future<List<Note>> getUserNotes(String userId) async {
    final snapshot = await _db
        .collection('notes')
        .where('uploader_id', isEqualTo: userId)
        .orderBy('upload_date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Note.fromMap(data);
    }).toList();
  }

  Future<List<Note>> getPendingNotes() async {
    final snapshot = await _db
        .collection('notes')
        .where('status', isEqualTo: NoteStatus.pending.name)
        .orderBy('upload_date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Note.fromMap(data);
    }).toList();
  }

  Future<void> moderateNote(String noteId, NoteStatus status) async {
    await _db.collection('notes').doc(noteId).update({'status': status.name});
  }

  // ─── File Storage (disabled — Spark plan) ─────────────────────
  //
  // To re-enable Firebase Storage:
  //   1. Upgrade to Blaze plan in Firebase Console
  //   2. Uncomment firebase_storage + file_picker in pubspec.yaml
  //   3. Uncomment _storage field above
  //   4. Uncomment this method
  //   5. Set storageEnabled = true
  //
  // Future<String> uploadFile(String path, Uint8List fileBytes, String contentType) async {
  //   final ref = _storage.ref().child(path);
  //   final metadata = SettableMetadata(contentType: contentType);
  //   await ref.putData(fileBytes, metadata);
  //   return await ref.getDownloadURL();
  // }

  // ─── Downloads ────────────────────────────────────────────────

  Future<void> recordDownload(String noteId, String userId) async {
    await _db.collection('downloads').add({
      'note_id': noteId,
      'user_id': userId,
      'download_date': DateTime.now().toIso8601String(),
    });
    // Increment download count on the note
    await _db.collection('notes').doc(noteId).update({
      'download_count': FieldValue.increment(1),
    });
  }

  Future<List<Note>> getDownloadedNotes(String userId) async {
    final downloadSnapshot = await _db
        .collection('downloads')
        .where('user_id', isEqualTo: userId)
        .orderBy('download_date', descending: true)
        .get();

    final noteIds = downloadSnapshot.docs
        .map((doc) => doc.data()['note_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    if (noteIds.isEmpty) return [];

    // Firestore 'whereIn' supports max 30 items per query
    final List<Note> notes = [];
    for (var i = 0; i < noteIds.length; i += 30) {
      final batch = noteIds.sublist(i, i + 30 > noteIds.length ? noteIds.length : i + 30);
      final snapshot = await _db
          .collection('notes')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      notes.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Note.fromMap(data);
      }));
    }

    return notes;
  }

  // ─── Saved Notes ──────────────────────────────────────────────

  Future<void> saveNote(String noteId, String userId) async {
    final docId = '${userId}_$noteId';
    await _db.collection('saved_notes').doc(docId).set({
      'note_id': noteId,
      'user_id': userId,
      'saved_date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unsaveNote(String noteId, String userId) async {
    final docId = '${userId}_$noteId';
    await _db.collection('saved_notes').doc(docId).delete();
  }

  Future<bool> isNoteSaved(String noteId, String userId) async {
    final docId = '${userId}_$noteId';
    final doc = await _db.collection('saved_notes').doc(docId).get();
    return doc.exists;
  }

  Future<List<Note>> getSavedNotes(String userId) async {
    final savedSnapshot = await _db
        .collection('saved_notes')
        .where('user_id', isEqualTo: userId)
        .get();

    final noteIds = savedSnapshot.docs
        .map((doc) => doc.data()['note_id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    if (noteIds.isEmpty) return [];

    final List<Note> notes = [];
    for (var i = 0; i < noteIds.length; i += 30) {
      final batch = noteIds.sublist(i, i + 30 > noteIds.length ? noteIds.length : i + 30);
      final snapshot = await _db
          .collection('notes')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      notes.addAll(snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Note.fromMap(data);
      }));
    }

    return notes;
  }

  // ─── Leaderboard ──────────────────────────────────────────────

  Future<List<app.LeaderboardEntry>> getLeaderboard(String college) async {
    final snapshot = await _db
        .collection('users')
        .where('college', isEqualTo: college)
        .orderBy('points', descending: true)
        .limit(20)
        .get();

    int rank = 0;
    return snapshot.docs.map((doc) {
      rank++;
      final data = doc.data();
      data['id'] = doc.id;
      final user = app.User.fromMap(data);
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
    final data = review.toMap();
    if (review.id.isEmpty) {
      data.remove('id');
    }
    await _db.collection('reviews').add(data);
  }

  Future<List<Review>> getReviews(String noteId) async {
    final snapshot = await _db
        .collection('reviews')
        .where('note_id', isEqualTo: noteId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Review.fromMap(data);
    }).toList();
  }
}

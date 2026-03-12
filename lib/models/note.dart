enum NoteFileType { pdf, image, document }

enum NoteStatus { pending, approved, rejected }

enum NoteCategory { regular, shortNotes, importantQuestions, previousYearPapers }

class Note {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String branch;
  final String college;
  final String description;
  final String uploaderId;
  final String uploaderName;
  final String uploaderAvatar;
  final String uploaderBranch;
  final String uploaderSemester;
  final double rating;
  final int downloadCount;
  final int reviewCount;
  final bool isSaved;
  final DateTime uploadDate;
  final String? fileUrl;
  final String? previewUrl;
  final NoteFileType fileType;
  final NoteStatus status;
  final NoteCategory category;

  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.semester,
    required this.branch,
    this.college = '',
    this.description = '',
    this.uploaderId = '',
    required this.uploaderName,
    this.uploaderAvatar = '',
    this.uploaderBranch = '',
    this.uploaderSemester = '',
    this.rating = 0.0,
    this.downloadCount = 0,
    this.reviewCount = 0,
    this.isSaved = false,
    required this.uploadDate,
    this.fileUrl,
    this.previewUrl,
    this.fileType = NoteFileType.pdf,
    this.status = NoteStatus.approved,
    this.category = NoteCategory.regular,
  });

  Note copyWith({
    String? id,
    String? title,
    String? subject,
    String? semester,
    String? branch,
    String? college,
    String? description,
    String? uploaderId,
    String? uploaderName,
    String? uploaderAvatar,
    String? uploaderBranch,
    String? uploaderSemester,
    double? rating,
    int? downloadCount,
    int? reviewCount,
    bool? isSaved,
    DateTime? uploadDate,
    String? fileUrl,
    String? previewUrl,
    NoteFileType? fileType,
    NoteStatus? status,
    NoteCategory? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      semester: semester ?? this.semester,
      branch: branch ?? this.branch,
      college: college ?? this.college,
      description: description ?? this.description,
      uploaderId: uploaderId ?? this.uploaderId,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
      uploaderBranch: uploaderBranch ?? this.uploaderBranch,
      uploaderSemester: uploaderSemester ?? this.uploaderSemester,
      rating: rating ?? this.rating,
      downloadCount: downloadCount ?? this.downloadCount,
      reviewCount: reviewCount ?? this.reviewCount,
      isSaved: isSaved ?? this.isSaved,
      uploadDate: uploadDate ?? this.uploadDate,
      fileUrl: fileUrl ?? this.fileUrl,
      previewUrl: previewUrl ?? this.previewUrl,
      fileType: fileType ?? this.fileType,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'semester': semester,
      'branch': branch,
      'college': college,
      'description': description,
      'uploader_id': uploaderId,
      'uploader_name': uploaderName,
      'uploader_avatar': uploaderAvatar,
      'uploader_branch': uploaderBranch,
      'uploader_semester': uploaderSemester,
      'rating': rating,
      'download_count': downloadCount,
      'review_count': reviewCount,
      'upload_date': uploadDate.toIso8601String(),
      'file_url': fileUrl,
      'preview_url': previewUrl,
      'file_type': fileType.name,
      'status': status.name,
      'category': category.name,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      semester: map['semester'] ?? '',
      branch: map['branch'] ?? '',
      college: map['college'] ?? '',
      description: map['description'] ?? '',
      uploaderId: map['uploader_id'] ?? '',
      uploaderName: map['uploader_name'] ?? '',
      uploaderAvatar: map['uploader_avatar'] ?? '',
      uploaderBranch: map['uploader_branch'] ?? '',
      uploaderSemester: map['uploader_semester'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      downloadCount: map['download_count'] ?? 0,
      reviewCount: map['review_count'] ?? 0,
      uploadDate: DateTime.tryParse(map['upload_date'] ?? '') ?? DateTime.now(),
      fileUrl: map['file_url'],
      previewUrl: map['preview_url'],
      fileType: NoteFileType.values.firstWhere(
        (e) => e.name == (map['file_type'] ?? 'pdf'),
        orElse: () => NoteFileType.pdf,
      ),
      status: NoteStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => NoteStatus.pending,
      ),
      category: NoteCategory.values.firstWhere(
        (e) => e.name == (map['category'] ?? 'regular'),
        orElse: () => NoteCategory.regular,
      ),
    );
  }
}

class Review {
  final String id;
  final String noteId;
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    this.noteId = '',
    this.reviewerId = '',
    required this.reviewerName,
    this.reviewerAvatar = '',
    required this.rating,
    required this.comment,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_avatar': reviewerAvatar,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      noteId: map['note_id'] ?? '',
      reviewerId: map['reviewer_id'] ?? '',
      reviewerName: map['reviewer_name'] ?? '',
      reviewerAvatar: map['reviewer_avatar'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class Download {
  final String id;
  final String noteId;
  final String userId;
  final DateTime downloadDate;

  Download({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.downloadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'download_date': downloadDate.toIso8601String(),
    };
  }

  factory Download.fromMap(Map<String, dynamic> map) {
    return Download(
      id: map['id'] ?? '',
      noteId: map['note_id'] ?? '',
      userId: map['user_id'] ?? '',
      downloadDate: DateTime.tryParse(map['download_date'] ?? '') ?? DateTime.now(),
    );
  }
}

class SavedNote {
  final String id;
  final String noteId;
  final String userId;
  final DateTime savedDate;

  SavedNote({
    required this.id,
    required this.noteId,
    required this.userId,
    required this.savedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'note_id': noteId,
      'user_id': userId,
      'saved_date': savedDate.toIso8601String(),
    };
  }

  factory SavedNote.fromMap(Map<String, dynamic> map) {
    return SavedNote(
      id: map['id'] ?? '',
      noteId: map['note_id'] ?? '',
      userId: map['user_id'] ?? '',
      savedDate: DateTime.tryParse(map['saved_date'] ?? '') ?? DateTime.now(),
    );
  }
}

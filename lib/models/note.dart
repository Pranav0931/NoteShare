class Note {
  final String id;
  final String title;
  final String subject;
  final String semester;
  final String branch;
  final String description;
  final String uploaderName;
  final String uploaderAvatar;
  final double rating;
  final int downloadCount;
  final int reviewCount;
  final bool isSaved;
  final DateTime uploadDate;
  final String? fileUrl;
  final String? previewUrl;

  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.semester,
    required this.branch,
    this.description = '',
    required this.uploaderName,
    this.uploaderAvatar = '',
    this.rating = 0.0,
    this.downloadCount = 0,
    this.reviewCount = 0,
    this.isSaved = false,
    required this.uploadDate,
    this.fileUrl,
    this.previewUrl,
  });

  Note copyWith({
    String? id,
    String? title,
    String? subject,
    String? semester,
    String? branch,
    String? description,
    String? uploaderName,
    String? uploaderAvatar,
    double? rating,
    int? downloadCount,
    int? reviewCount,
    bool? isSaved,
    DateTime? uploadDate,
    String? fileUrl,
    String? previewUrl,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      semester: semester ?? this.semester,
      branch: branch ?? this.branch,
      description: description ?? this.description,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatar: uploaderAvatar ?? this.uploaderAvatar,
      rating: rating ?? this.rating,
      downloadCount: downloadCount ?? this.downloadCount,
      reviewCount: reviewCount ?? this.reviewCount,
      isSaved: isSaved ?? this.isSaved,
      uploadDate: uploadDate ?? this.uploadDate,
      fileUrl: fileUrl ?? this.fileUrl,
      previewUrl: previewUrl ?? this.previewUrl,
    );
  }
}

class Review {
  final String id;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.reviewerName,
    this.reviewerAvatar = '',
    required this.rating,
    required this.comment,
    required this.date,
  });
}

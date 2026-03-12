class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String college;
  final String branch;
  final String semester;
  final int uploadCount;
  final int downloadCount;
  final double rating;
  final int points;
  final int rank;
  final int communityScore;
  final String role; // 'student' or 'admin'

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.college = '',
    this.branch = '',
    this.semester = '',
    this.uploadCount = 0,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.points = 0,
    this.rank = 0,
    this.communityScore = 0,
    this.role = 'student',
  });

  bool get isAdmin => role == 'admin';

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? college,
    String? branch,
    String? semester,
    int? uploadCount,
    int? downloadCount,
    double? rating,
    int? points,
    int? rank,
    int? communityScore,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      uploadCount: uploadCount ?? this.uploadCount,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      points: points ?? this.points,
      rank: rank ?? this.rank,
      communityScore: communityScore ?? this.communityScore,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'college': college,
      'branch': branch,
      'semester': semester,
      'upload_count': uploadCount,
      'download_count': downloadCount,
      'rating': rating,
      'points': points,
      'rank': rank,
      'community_score': communityScore,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      college: map['college'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? '',
      uploadCount: map['upload_count'] ?? 0,
      downloadCount: map['download_count'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      points: map['points'] ?? 0,
      rank: map['rank'] ?? 0,
      communityScore: map['community_score'] ?? 0,
      role: map['role'] ?? 'student',
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final User user;
  final int points;
  final int totalDownloadsReceived;
  final int communityScore;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.points,
    this.totalDownloadsReceived = 0,
    this.communityScore = 0,
  });
}

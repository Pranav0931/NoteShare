class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String university;
  final int uploadCount;
  final int downloadCount;
  final double rating;
  final int points;
  final int rank;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl = '',
    this.university = '',
    this.uploadCount = 0,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.points = 0,
    this.rank = 0,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? university,
    int? uploadCount,
    int? downloadCount,
    double? rating,
    int? points,
    int? rank,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      university: university ?? this.university,
      uploadCount: uploadCount ?? this.uploadCount,
      downloadCount: downloadCount ?? this.downloadCount,
      rating: rating ?? this.rating,
      points: points ?? this.points,
      rank: rank ?? this.rank,
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final User user;
  final int points;

  LeaderboardEntry({
    required this.rank,
    required this.user,
    required this.points,
  });
}

class Posts {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final String? nickname;
  final DateTime createdAt;
  final String? username;
  final int totalLiked;
  final int totalComment;
  final bool isLikedByMe;
  final bool isBookmarked;

  Posts({
    required this.id,
    required this.userId,
    required this.username,
    required this.nickname,
    required this.content,
    required this.totalLiked,
    required this.totalComment,
    required this.images,
    required this.createdAt,
    this.isLikedByMe = false,
    this.isBookmarked = false
  });
  factory Posts.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? userData,
    isLikedByMe = false,
    isBookmarked = false
  }) {
    return Posts(
      id: id,
      userId: data['user_id'],
      nickname: userData != null ? userData['nickname'] as String? : null,
      username: userData != null ? userData['username'] as String? : null,
      content: data['content'] ?? '',
      totalLiked: data['total_liked'] ?? 0,
      totalComment: data['total_comment'] ?? 0,
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      isLikedByMe: isLikedByMe,
      isBookmarked: isBookmarked
    );
  }

   Posts copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? images,
    String? nickname,
    String? username,
    DateTime? createdAt,
    int? totalLiked,
    int? totalComment,
    bool? isLikedByMe,
    bool? isBookmarked
  }) {
    return Posts(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      images: images ?? this.images,
      nickname: nickname ?? this.nickname,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      totalLiked: totalLiked ?? this.totalLiked,
      totalComment: totalComment ?? this.totalComment,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isBookmarked: isBookmarked ?? this.isBookmarked
    );
  }
}

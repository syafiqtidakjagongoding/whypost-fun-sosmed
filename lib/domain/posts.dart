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
  });
  factory Posts.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? userData,
    isLikedByMe = false,
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
      isLikedByMe: isLikedByMe
    );
  }
}

/// Model sederhana untuk User Data
class AppUser {
  final String uid;
  final String? email;
  final String username;
  final String nickname;
  final bool isGuest;

  AppUser({
    required this.uid,
    this.email,
    required this.username,
    required this.nickname,
    required this.isGuest,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      email: data['email'] ?? "",
      username: data['username'],
      nickname: data['nickname'],
      isGuest: data['is_guest'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'nickname': nickname,
      'is_guest': isGuest,
    };
  }
}

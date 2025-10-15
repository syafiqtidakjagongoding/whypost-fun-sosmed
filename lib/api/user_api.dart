import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapp/domain/posts.dart';
import '../domain/users.dart';

Future<AppUser?> fetchUserDataByName() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    // Belum login
    return null;
  }

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!doc.exists) {
    return null;
  }

  final data = doc.data()!;


  return AppUser.fromFirestore(doc.id, data);
}

Future<List<Posts>> fetchPostsByUserId(String userid) async {
  try {
    // 1️⃣ Ambil semua post
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('user_id', isEqualTo: userid)
        .orderBy('created_at', descending: true)
        .get();

    // 3️⃣ Ambil data user untuk userId tersebut
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userid)
        .get();

    // Map userId -> userData
    final userMap = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

    // 4️⃣ Gabungkan post + user info
    final posts = snapshot.docs.map((doc) {
      final data = doc.data();
      final userId = data['user_id'] as String;
      final userData = userMap[userId]; // bisa null kalau user dihapus
      return Posts.fromFirestore(doc.id, data, userData: userData);
    }).toList();

    return posts;
  } catch (e) {
    print('❌ Gagal fetch posts: $e');
    return [];
  }
}

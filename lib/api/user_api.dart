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

  return AppUser.fromFirestore(data);
}

Future<List<Posts>> fetchPostsByUserId(String userId) async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Ambil post & user data secara paralel
    final results = await Future.wait([
      firestore
          .collection('posts')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get(),
      firestore.collection('users').where('uid', isEqualTo: userId).get(),
    ]);

    final postSnapshot = results[0];
    final userSnapshot = results[1];

    // Buat map userId → data user
    final userMap = {
      for (var doc in userSnapshot.docs) doc.data()['uid']: doc.data(),
    };

    // Gabungkan post + user info
    return postSnapshot.docs.map((doc) {
      final data = doc.data();
      final uid = data['user_id'] as String;
      return Posts.fromFirestore(doc.id, data, userData: userMap[uid]);
    }).toList();
  } catch (e) {
    print('❌ Gagal fetch posts: $e');
    return [];
  }
}

Future<bool> checkIsLiked(String userId, String postId) async {
  try {
    final docId = '${userId}_$postId'; // 🔸 kombinasi unik
    final likeRef = FirebaseFirestore.instance
        .collection('like_post')
        .doc(docId);

    final docSnap = await likeRef.get();

    if (docSnap.exists) {
      print('✅ Post $postId sudah di-like oleh user $userId');
      return true;
    } else {
      print('ℹ️ Post $postId belum di-like oleh user $userId');
      return false;
    }
  } catch (e) {
    print('❌ Gagal like post: $e');
    rethrow;
  }
}

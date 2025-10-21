import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

Stream<List<Posts>> streamPostsByUserId(String userId) {
  final firestore = FirebaseFirestore.instance;

  // 🔸 Listen realtime ke posts milik user tertentu
  final postStream = firestore
      .collection('posts')
      .where('user_id', isEqualTo: userId)
      .orderBy('created_at', descending: true)
      .snapshots();

  // 🔸 Ambil user data sekali saja
  final userFuture = firestore
      .collection('users')
      .where('uid', isEqualTo: userId)
      .get();

  // 🔸 Transform stream ke List<Posts>
  return postStream.asyncMap((postSnapshot) async {
    // Ambil data user
    final userSnapshot = await userFuture;
    final userMap = {
      for (var doc in userSnapshot.docs) doc.data()['uid']: doc.data(),
    };

    // 🔹 Ambil semua postId untuk cek like
    final postIds = postSnapshot.docs.map((doc) => doc.id).toList();

    // 🔹 Ambil semua like user ini terhadap post2 tersebut
    final likeSnapshot = await firestore
        .collection('like_post')
        .where(
          FieldPath.documentId,
          whereIn: postIds.map((id) => '${userId}_$id').toList(),
        ) // cek semua
        .get();
    final bookmarksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .where(FieldPath.documentId, whereIn: postIds)
        .get();

    final bookmarkedPostIds = bookmarksSnapshot.docs
        .map((doc) => doc.id)
        .toSet();
    // Buat set untuk cepat ngecek like
    final likedIds = likeSnapshot.docs
        .map((doc) => doc.id.split('_').last)
        .toSet();

    // 🔹 Gabungkan post + user + like info
    return postSnapshot.docs.map((doc) {
      final data = doc.data();
      final uid = data['user_id'] as String;
      final isLikedByMe = likedIds.contains(doc.id);
      final isBookmarked = bookmarkedPostIds.contains(doc.id);
      return Posts.fromFirestore(
        doc.id,
        data,
        userData: userMap[uid],
        isLikedByMe: isLikedByMe,
        isBookmarked: isBookmarked,
      );
    }).toList();
  });
}

// 🔸 Ganti dengan Firestore
final userPosttreamProvider = StreamProvider.family<List<Posts>, String>((
  ref,
  userInThisDevice,
) async* {
  final firestore = FirebaseFirestore.instance;

  // 1️⃣ Stream data post realtime
  final postsStream = firestore
      .collection('posts')
      .where('user_id', isEqualTo: userInThisDevice)
      .orderBy('created_at', descending: true)
      .snapshots();

  await for (final snapshot in postsStream) {
    if (snapshot.docs.isEmpty) {
      yield [];
      continue;
    }

    // 2️⃣ Ambil semua userId unik dari post
    final userIds = snapshot.docs
        .map((doc) => doc['user_id'] as String)
        .toSet()
        .toList();

    // 3️⃣ Ambil data user terkait (1x per snapshot)
    final usersSnapshot = await firestore
        .collection('users')
        .where('uid', whereIn: userIds)
        .get();

    final userMap = {
      for (var doc in usersSnapshot.docs) doc.data()['uid']: doc.data(),
    };

    // 4️⃣ Ambil semua postId
    final postIds = snapshot.docs.map((doc) => doc.id).toList();

    // 5️⃣ Ambil semua like milik user ini
    final likesSnapshot = await firestore
        .collection('like_post')
        .where(
          FieldPath.documentId,
          whereIn: postIds.map((id) => '${userInThisDevice}_$id').toList(),
        )
        .get();

    final likedPostIds = likesSnapshot.docs
        .map((doc) => doc.id.split('_').last)
        .toSet(); // ambil id post dari documentId

    final bookmarksSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userInThisDevice)
        .collection('bookmarks')
        .where(FieldPath.documentId, whereIn: postIds)
        .get();

    final bookmarkedPostIds = bookmarksSnapshot.docs
        .map((doc) => doc.id)
        .toSet();

    // 6️⃣ Gabungkan semua data ke model Posts
    final posts = snapshot.docs.map((doc) {
      final data = doc.data();
      final userId = data['user_id'] as String;
      final userData = userMap[userId];

      final isLikedByMe = likedPostIds.contains(doc.id);
      final isBookmarked = bookmarkedPostIds.contains(doc.id);

      return Posts.fromFirestore(
        doc.id,
        data,
        userData: userData,
        isLikedByMe: isLikedByMe,
        isBookmarked: isBookmarked,
      );
    }).toList();

    print("Fetching");
    // 7️⃣ Emit hasilnya ke stream
    yield posts;
  }
});
